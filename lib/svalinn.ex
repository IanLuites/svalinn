defmodule Svalinn do
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

  def encode(token, opts \\ []) do
    version = opts[:version] || @version
    encoding = opts[:encoding] || @default_encoding

    with {:ok, prefix} <- prefix(version, encoding),
         token <- prepare_token(token),
         {:ok, packed} <- encode(version, token, opts),
         {:ok, data} <- encoding.encode(packed) do
      {:ok, prefix <> data}
    end
  end

  def decode(token, opts \\ []) do
    with <<prefix::binary-1, data::binary>> <- token,
         {:ok, version, encoding} <- prefix(prefix),
         {:ok, packed} <- encoding.decode(data),
         {:ok, token} <- decode(version, packed, opts) do
      {:ok, load_token(token)}
    end
  end

  @types :svalinn
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

  @reverse_types :svalinn
                 |> Application.get_env(:tokens, [])
                 |> Enum.map(fn {k, v} -> {to_string(k), v} end)
                 |> Enum.into(%{})

  defp prepare_token(token) do
    module = token.__struct__

    cond do
      @types[module] -> %{type: @types[module], data: module.__token_parse__(token)}
      Tokenize.impl_for(token) -> prepare_token(Tokenize.token(token))
      :invalid -> raise "This data can't be converted to a token."
    end
  end

  defp load_token(%{"type" => type, "data" => data}) do
    {type, opts} = @reverse_types[type]
    type.__token_load__(data, opts)
  end
end
