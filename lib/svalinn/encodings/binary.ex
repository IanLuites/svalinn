defmodule Svalinn.Encodings.Binary do
  @behaviour Svalinn.Encoding

  @impl Svalinn.Encoding
  def encode(data), do: {:ok, data}
  @impl Svalinn.Encoding
  def decode(data), do: {:ok, data}
end
