defmodule Svalinn.Encoding do
  @callback encode(binary) :: {:ok, any} | {:error, :encoding_failed}
  @callback decode(any) :: {:ok, binary} | {:error, :decoding_failed}
end
