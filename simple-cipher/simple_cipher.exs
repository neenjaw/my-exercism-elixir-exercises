


defmodule SimpleCipher do

  @start ?a
  @end ?z

  defguardp is_encodable(c) when c in @start..@end

  @doc """
  Given a `plaintext` and `key`, encode each character of the `plaintext` by
  shifting it by the corresponding letter in the alphabet shifted by the number
  of letters represented by the `key` character, repeating the `key` if it is
  shorter than the `plaintext`.

  For example, for the letter 'd', the alphabet is rotated to become:

  defghijklmnopqrstuvwxyzabc

  You would encode the `plaintext` by taking the current letter and mapping it
  to the letter in the same position in this rotated alphabet.

  abcdefghijklmnopqrstuvwxyz
  defghijklmnopqrstuvwxyzabc

  "a" becomes "d", "t" becomes "w", etc...

  Each letter in the `plaintext` will be encoded with the alphabet of the `key`
  character in the same position. If the `key` is shorter than the `plaintext`,
  repeat the `key`.

  Example:

  plaintext = "testing"
  key = "abc"

  The key should repeat to become the same length as the text, becoming
  "abcabca". If the key is longer than the text, only use as many letters of it
  as are necessary.
  """
  def encode(plaintext, key) do
    cipher_stream = 
      create_cipher_stream(key)

    plaintext 
    |> String.codepoints
    |> Stream.transform(cipher_stream, &cipher_transform(&1, &2, &encode_codepoint/2))
    |> Enum.to_list
    |> to_string
  end
  
  def create_cipher_stream(key) do
    key
    |> String.codepoints
    |> Stream.filter(fn
       c when c in ?a..?z -> true
         _ -> false
       end)
    |> Stream.map(&(?a - &1))
    |> Stream.cycle
  end
  
  def cipher_transform(c, c_stream, t_fun) 
    when is_encodeable(c) do

    shift =
      c_stream 
      |> Stream.take(1) 
      |> Enum.to_list 
      |> List.first
             
    next_c_stream =
      Stream.drop(c_stream, 1)
         
    {
      [t_fun.(c, shift)],
      next_c_stream
    }
  end
           
  def cipher_transform(c, c_stream) do
    {[c], c_stream}
  end
  
  def encode_codepoint(codepoint, shift) do
    rem((codepoint - @start + shift), 26) + @start
  end
 
  def decode_codepoint(codepoint, shift) do
    case rem((codepoint - @start - shift), 26) do
      c when c < 0 -> 
        c + 26 + @start
        
      c ->
        c + @start
    end
  end
  

  @doc """
  Given a `ciphertext` and `key`, decode each character of the `ciphertext` by
  finding the corresponding letter in the alphabet shifted by the number of
  letters represented by the `key` character, repeating the `key` if it is
  shorter than the `ciphertext`.

  The same rules for key length and shifted alphabets apply as in `encode/2`,
  but you will go the opposite way, so "d" becomes "a", "w" becomes "t",
  etc..., depending on how much you shift the alphabet.
  """
  def decode(ciphertext, key) do
  
  cipher_stream = 
    create_cipher_stream(key)

    plaintext 
    |> String.codepoints
    |> Stream.transform(cipher_stream, &cipher_transform(&1, &2, &decode_codepoint/2))
    |> Enum.to_list
    |> to_string
  end
end
