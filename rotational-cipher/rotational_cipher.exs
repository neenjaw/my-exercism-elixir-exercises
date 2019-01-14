defmodule RotationalCipher do
  @doc """
  Given a plaintext and amount to shift by, return a rotated string.

  Example:
  iex> RotationalCipher.rotate("Attack at dawn", 13)
  "Nggnpx ng qnja"
  """
  @spec rotate(text :: String.t(), shift :: integer) :: String.t()
  def rotate(text, shift) do
    rotate(String.codepoints(text), shift, [])
      |> Enum.join()
  end

  defp rotate([], _shift, acc), do: Enum.reverse(acc)
  defp rotate([letter | text], shift, acc) do 
    # << letter_value :: utf8 >> = letter

    rotated_letter = 
      cond do
        letter_in_range(%{start: "a", end: "z", letter: letter}) -> shift_letter(letter, shift, "a")
        letter_in_range(%{start: "A", end: "Z", letter: letter}) -> shift_letter(letter, shift, "A")
        true -> letter
      end

    rotate(text, shift, [rotated_letter | acc])
  end

  def letter_in_range(%{start: << s :: utf8 >>, end: << e :: utf8 >>, letter: << l :: utf8 >>}) do
    cond do
      (s <= l) and (l <= e) -> true
      true -> false
    end
  end

  def shift_letter(<<index :: utf8>>, shift, first_letter_of_range) do
    << offset :: utf8 >> = first_letter_of_range

    << (rem((index - offset + shift), 26) + offset) :: utf8 >>
  end
end
