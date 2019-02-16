defmodule PascalsTriangle do
  @doc """
  Calculates the rows of a pascal triangle
  with the given height
  """
  @spec rows(integer) :: [[integer]]
  def rows(num) do
    Stream.iterate([1], &build_row/1)
    |> Enum.take(num)
  end

  defp build_row(previous) do
    Enum.chunk([0 | previous], 2, 1, [0])
    |> Enum.map(&Enum.sum/1)
  end
end