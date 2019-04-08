defmodule SimpleCipher do

  @range_start ?a
  @range_end ?z

  defguardp is_encodable(c) when c in @range_start..@range_end

  @doc """
  Given a `plaintext` and `key`, encode each character of the `plaintext` by
  shifting it by the corresponding letter in the alphabet shifted by the number
  of letters represented by the `key` character, repeating the `key` if it is
  shorter than the `plaintext`.
  """
  def encode(plaintext, key) do
    cipher_stream =
      create_cipher_stream(key)

    plaintext
    |> to_charlist
    |> Stream.concat([:end])
    |> Stream.transform(cipher_stream, fn c, c_stream ->
         cipher_transform(c, c_stream, &encode_codepoint/2)
       end)
    |> Enum.to_list
    |> to_string
  end

  defp create_cipher_stream(key) do
    key
    |> to_charlist
    |> Stream.filter(fn
        c when c in @range_start..@range_end -> true
        _ -> false
      end)
    |> Stream.map(&(&1 - @range_start))
    |> Stream.cycle
  end

  defp cipher_transform(c, c_stream, transform_fx) when is_encodable(c) do
    shift =
      c_stream
      |> Stream.take(1)
      |> Enum.to_list
      |> List.first

    next_c_stream =
      Stream.drop(c_stream, 1)

    {[transform_fx.(c, shift)], next_c_stream}
  end

  defp cipher_transform(:end, c_stream, _) do
    {:halt, c_stream}
  end

  defp cipher_transform(c, c_stream, _) do
    {[c], c_stream}
  end

  defp encode_codepoint(codepoint, shift) do
    rem((codepoint - @range_start + shift), 26) + @range_start
  end

  defp decode_codepoint(codepoint, shift) do
    case rem((codepoint - @range_start - shift), 26) do
      c when c < 0 ->
        c + 26 + @range_start

      c ->
        c + @range_start
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

    ciphertext
    |> to_charlist
    |> Stream.concat([:end])
    |> Stream.transform(cipher_stream, fn c, c_stream ->
         cipher_transform(c, c_stream, &decode_codepoint/2)
       end)
    |> Enum.to_list
    |> to_string
  end
end
