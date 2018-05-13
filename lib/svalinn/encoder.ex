defmodule Svalinn.Encoder do
  import Svalinn.Util, only: [encrypt: 1, decrypt: 1]

  @spec encode(non_neg_integer, binary, Keyword.t()) :: {:ok, binary}
  def encode(1, token, opts) do
    with {:ok, packed} <- Msgpax.pack(token),
         compressed <- :zlib.compress(packed),
         {:ok, encrypted} <- encrypt(compressed) do
      {:ok, encrypted}
    end
  end
end
