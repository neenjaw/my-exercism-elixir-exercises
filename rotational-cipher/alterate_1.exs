defmodule RotationalCipher do
  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    for << char <- text >>, into: "", do: << do_rotate(char, shift) >>
  end

  defp do_rotate(char, shift) when char in ?a..?z do
    rem(char - ?a + shift, 26) + ?a
  end
  defp do_rotate(char, shift) when char in ?A..?Z do
    rem(char - ?A + shift, 26) + ?A
  end
  defp do_rotate(char, _shift), do: char
end