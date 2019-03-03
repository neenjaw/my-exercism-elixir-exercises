defmodule Atbash do

  @alpha ~w/a b c d e f g h i j k l m n o p q r s t u v w x y z/
  @r_alpha @alpha |> Enum.reverse
  @cipher_key Enum.zip(@alpha, @r_alpha) |> Map.new

  @invalid_letters [" ", ".", ",", ";", ":", "(", ")", "[", "]", "{", "}", 
                    "<", ">", "?", "|", "\\", "'", "+", "-", "_", "="]

  @doc """
  Encode a given plaintext to the corresponding ciphertext

  ## Examples

  iex> Atbash.encode("completely insecure")
  "xlnko vgvob rmhvx fiv"
  """
  @spec encode(String.t()) :: String.t()
  def encode(plaintext) do
    plaintext
    |> String.downcase
    |> String.graphemes
    |> Enum.filter(&filter_nonletters(&1))
    |> Enum.map(fn g -> Map.get(@cipher_key, g, g) end)
    |> Enum.chunk_every(5)
    |> Enum.map_join(" ", fn w -> Enum.join(w) end)
  end

  @spec decode(String.t()) :: String.t()
  def decode(cipher) do
    cipher
    |> String.graphemes
    |> Enum.filter(&filter_nonletters(&1))
    |> Enum.map(fn g -> Map.get(@cipher_key, g, g) end)
    |> Enum.join    
  end

  defp filter_nonletters(g) when g in @invalid_letters, do: false
  defp filter_nonletters(_), do: true

end
