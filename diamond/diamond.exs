defmodule Diamond do

  defguardp is_letter(l) when l in ?A..?Z

  @offset ?A

  @doc """
  Given a letter, it prints a diamond starting with 'A',
  with the supplied letter at the widest point.
  """
  @spec build_shape(char) :: String.t()
  def build_shape(letter) when is_letter(letter) do
    # the number of row from top to the middle is equal to the difference
    difference = letter - @offset

    # determine the ranges for the spaces
    letter_range = @offset..letter

    side_range = difference..0

    middle_range_stepper = 
      fn
        0 -> 1
        i -> i + 2
      end

    middle_range = Stream.iterate(0, middle_range_stepper)

    # create a list of tuples consisting of the codepoint and spacing 
    top_rows =
      [letter_range, side_range, middle_range]
      |> Enum.zip

    # get the list of the bottom, minus the middle row
    bottom_rows = 
      top_rows
      |> Enum.reverse
      |> Enum.drop(1)

    diamond_rows =
      (top_rows ++ bottom_rows)
      |> Stream.map(&make_diamond_row/1)
      |> Enum.to_list

    Enum.join(diamond_rows, "\n") <> "\n"
  end


  defp make_diamond_row({letter, side_padding, 0}) do
    sides  = String.duplicate("\s", side_padding)

    sides <> <<letter>> <> sides
  end

  defp make_diamond_row({letter, side_padding, middle_padding}) do 
    sides  = String.duplicate("\s", side_padding)
    middle = String.duplicate("\s", middle_padding)

    sides <> <<letter>> <> middle <> <<letter>> <> sides
  end
end

