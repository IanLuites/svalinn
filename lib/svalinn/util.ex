defmodule Svalinn.Util do
  @encodings [
    Svalinn.Encodings.Binary,
    Svalinn.Encodings.URL,
    Svalinn.Encodings.Base64
  ]

  @iv_bytes 16
  import Svalinn.Encodings.URL, only: [to_integer: 1, to_binary: 1]

  @spec prefix(binary) :: {:ok, pos_integer, atom} | {:error, :invalid_prefix}
  def prefix(<<prefix::binary-1, _::binary>>), do: prefix(prefix)

  def prefix(prefix) do
    with {:ok, prefix} <- to_integer(prefix),
         <<_reserved::1, version::3, encoding::3>> <- <<prefix::size(7)>>,
         encoding when encoding != nil <- Enum.at(@encodings, encoding) do
      {:ok, version + 1, encoding}
    else
      _ -> {:error, :invalid_prefix}
    end
  end

  @spec prefix(pos_integer, atom) :: {:ok, binary} | {:error, :prefix_generation_failed}
  def prefix(version, encoding) do
    reserved = 0

    with encoding when encoding != nil <- Enum.find_index(@encodings, &(&1 == encoding)),
         <<prefix::size(7)>> <- <<reserved::1, version - 1::3, encoding::3>>,
         {:ok, prefix} <- to_binary(prefix) do
      {:ok, prefix}
    else
      _ -> {:error, :prefix_generation_failed}
    end
  end

  @spec encrypt(binary) :: {:ok, binary} | {:error, :encryption_failed}
  def encrypt(data) do
    iv = :crypto.strong_rand_bytes(@iv_bytes)
    crypto = :crypto.stream_init(:aes_ctr, secret(), iv)

    with {_state, encrypted} <- :crypto.stream_encrypt(crypto, data) do
      {:ok, iv <> encrypted}
    else
      _ -> {:error, :encryption_failed}
    end
  end

  @spec decrypt(binary) :: {:ok, binary} | {:error, :decryption_failed}
  def decrypt(data) do
    with <<iv::binary-@iv_bytes, w::binary>> <- data,
         crypto <- :crypto.stream_init(:aes_ctr, secret(), iv),
         {_state, decrypted} <- :crypto.stream_decrypt(crypto, w) do
      {:ok, decrypted}
    else
      _ -> {:error, :decryption_failed}
    end
  end

  @spec secret :: String.t()
  defp secret do
    :svalinn
    |> Application.get_env(:encryption, [])
    |> Keyword.get_lazy(:secret, fn -> raise "Need to set encryption key." end)
    |> Base.decode64!()
  end
end
