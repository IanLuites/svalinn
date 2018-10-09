defmodule Svalinn.Encodings.URL do
  @behaviour Svalinn.Encoding

  @impl Svalinn.Encoding
  def encode(data),
    do:
      {:ok,
       data
       |> Base.encode64(padding: false)
       |> String.replace("+", "-")
       |> String.replace("/", "_")}

  @impl Svalinn.Encoding
  def decode(data) do
    data =
      data
      |> String.replace("-", "+")
      |> String.replace("_", "/")

    with :error <- Base.decode64(data, padding: false) do
      {:error, :decoding_failed}
    end
  end

  @spec to_binary(non_neg_integer) :: {:ok, binary} | {:error, :invalid_value}
  def to_binary(value) do
    cond do
      value <= 25 -> {:ok, <<?A + value>>}
      value <= 51 -> {:ok, <<?a + (value - 26)>>}
      value <= 61 -> {:ok, <<?0 + (value - 52)>>}
      value == 62 -> {:ok, <<?->>}
      value == 63 -> {:ok, <<?_>>}
      value == 64 -> {:ok, <<?.>>}
      value == 65 -> {:ok, <<?~>>}
      :value_out_of_range -> {:error, :invalid_value}
    end
  end

  @spec to_integer(binary) :: {:ok, non_neg_integer} | {:error, :invalid_value}
  def to_integer(<<value::size(8)>>) do
    unquote(
      {:case, [],
       [
         {:value, [], nil},
         [
           do:
             Enum.map(?A..?Z, &{:->, [], [[&1], {:ok, &1 - ?A}]}) ++
               Enum.map(?a..?z, &{:->, [], [[&1], {:ok, 26 + &1 - ?a}]}) ++
               Enum.map(?0..?9, &{:->, [], [[&1], {:ok, 52 + &1 - ?0}]}) ++
               [
                 {:->, [], [[?-], {:ok, 62}]},
                 {:->, [], [[?_], {:ok, 63}]},
                 {:->, [], [[?.], {:ok, 64}]},
                 {:->, [], [[?~], {:ok, 65}]},
                 {:->, [], [[{:_, [], nil}], {:error, :invalid_value}]}
               ]
         ]
       ]}
    )
  end

  def to_integer(_), do: {:error, :invalid_value}
end
