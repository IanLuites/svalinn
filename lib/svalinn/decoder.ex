defmodule Svalinn.Decoder do
  import Svalinn.Util, only: [decrypt: 1]

  @spec decode(non_neg_integer, binary, Keyword.t()) :: {:ok, map}
  def decode(1, encrypted, _opts) do
    with {:ok, compressed} <- decrypt(encrypted),
         packed <- :zlib.uncompress(compressed),
         {:ok, unpacked} <- Msgpax.unpack(packed) do
      {:ok, unpacked}
    end
  end

  def decode(_, _, _), do: {:error, :invalid_version}
end
