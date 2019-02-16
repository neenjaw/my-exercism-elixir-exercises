defmodule PascalsTriangle do
  @doc """
  Calculates the rows of a pascal triangle
  with the given height

  Creates a range from 1..num, which represents each row, then
  calls Enum.reduce/3 to create an array where each element is an array
  representing a row. Each row is created based on the result of the
  row preceeding it, which makes Enum.reduce/3 a useful function to 
  accumulate the result of preceeding rows
  """
  @spec rows(integer) :: [[integer]]
  def rows(num) do
    1..num
    |> Enum.reduce([], fn n, previous_rows ->
      [ get_row(n, previous_rows) | previous_rows ]
    end)
    |> Enum.reverse
  end

  @doc """
  Private function to create the n'th row of pascal's triangle
  based off of the result of the n-1'th row.

  Enum.reduce/3 through the last row generated, using 0 as the 
  first value when calculating the next row's first element. While the row
  is constructed in reverse, the property of pascal's triangle states
  that each row is palendromic, so we don't have to reverse it.
  """
  defp get_row(1, _), do: [1]
  defp get_row(_row, [prev_row | _rest]) do
    prev_row
    |> Enum.reduce({0, []}, fn p_row_n, {p_row_nmo, new_row} ->
      {p_row_n, [(p_row_n + p_row_nmo) | new_row]}
    end)
    |> (fn {last_n, new_row} ->
      [last_n | new_row]
    end).()
  end
end
