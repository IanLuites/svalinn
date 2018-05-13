defmodule Svalinn.Encodings.Base64 do
  @behaviour Svalinn.Encoding

  @impl Svalinn.Encoding
  def encode(data), do: {:ok, Base.encode64(data, padding: false)}

  @impl Svalinn.Encoding
  def decode(data) do
    with :error <- Base.decode64(data, padding: false) do
      {:error, :decoding_failed}
    end
  end
end
