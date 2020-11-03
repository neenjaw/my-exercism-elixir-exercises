defmodule RotationalCipher do
  @upper ?A..?Z
  @lower ?a..?z

  @upper_offset @upper |> Enum.to_list() |> hd
  @lower_offset @lower |> Enum.to_list() |> hd

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

  defp do_rotate(char, shift) when char in @lower do
    rem(char - @lower_offset + shift, 26) + @lower_offset
  end
  defp do_rotate(char, shift) when char in @upper do
    rem(char - @upper_offset + shift, 26) + @upper_offset
  end
  defp do_rotate(char, _shift), do: char
end
