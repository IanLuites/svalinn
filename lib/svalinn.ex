defmodule Svalinn do
  @on_load :preload_tokens
  @default_encoding Svalinn.Encodings.Binary
  @version 1

  import Svalinn.Util, only: [prefix: 1, prefix: 2]
  import Svalinn.Encoder, only: [encode: 3]
  import Svalinn.Decoder, only: [decode: 3]

  defprotocol Tokenize do
    @doc ~S"""

    """
    @spec token(map) :: map
    def token(data)
  end

  @doc ~S"""
  Encode a structure or token.
  """
  @spec encode(map, Keyword.t()) :: {:ok, any} | {:error, atom}
  def encode(token, opts \\ []) do
    version = opts[:version] || @version
    encoding = opts[:encoding] || @default_encoding

    with {:ok, prefix} <- prefix(version, encoding),
         {:ok, token} <- prepare_token(token),
         {:ok, packed} <- encode(version, token, opts),
         {:ok, data} <- encoding.encode(packed) do
      {:ok, prefix <> data}
    end
  end

  @doc ~S"""
  Decode a token.
  """
  @spec decode(map, Keyword.t()) :: {:ok, any} | {:error, atom}
  def decode(token, opts \\ []) do
    with <<prefix::binary-1, data::binary>> <- token,
         {:ok, version, encoding} <- prefix(prefix),
         {:ok, packed} <- encoding.decode(data),
         {:ok, token} <- decode(version, packed, opts),
         {:ok, data} <- load_token(token, opts) do
      {:ok, data}
    end
  end

  @spec prepare_token(map) :: map | {:error, :invalid_token}
  defp prepare_token(token) do
    types = Application.fetch_env!(:svalinn, :types)
    module = token.__struct__

    cond do
      types[module] ->
        {:ok, %{type: types[module], data: module.__token_parse__(token)}}

      Tokenize.impl_for(token) ->
        with {:ok, data} <- Tokenize.token(token), do: prepare_token(data)

      :invalid ->
        {:error, :invalid_token}
    end
  end

  @spec load_token(map, Keyword.t()) :: any
  defp load_token(%{"type" => type, "data" => data}, opts) do
    types = Application.fetch_env!(:svalinn, :reverse_types)

    with {type, defaults} <- Map.get(types, type, {:error, :invalid_type}) do
      type.__token_load__(data, Keyword.merge(defaults, opts))
    end
  end

  @doc false
  @spec preload_tokens :: :ok
  def preload_tokens do
    types =
      :svalinn
      |> Application.get_env(:tokens, [])
      |> Enum.map(fn {k, v} ->
        type = to_string(k)
        value = if is_atom(v), do: v, else: elem(v, 0)

        case String.split(type, "@", parts: 2) do
          [a, b] -> {a, String.to_integer(b), value}
          _ -> {type, nil, value}
        end
      end)
      |> Enum.group_by(&elem(&1, 2))
      |> Enum.map(fn {_, values} ->
        {type, version, value} =
          values
          |> Enum.sort_by(&elem(&1, 1))
          |> List.last()

        if is_nil(version), do: {value, type}, else: {value, "#{type}@#{version}"}
      end)
      |> Enum.into(%{})

    reverse_types =
      :svalinn
      |> Application.get_env(:tokens, [])
      |> Enum.map(fn {k, v} -> {to_string(k), v} end)
      |> Enum.into(%{})

    Application.put_env(:svalinn, :types, types, persistent: true)
    Application.put_env(:svalinn, :reverse_types, reverse_types, persistent: true)

    :ok
  end
end
