defmodule Grains do
  @doc """
  Calculate two to the power of the input minus one.
  """
  @spec square(pos_integer) :: pos_integer
  def square(number) when number < 1 or number > 64 do
    {:error, "The requested square must be between 1 and 64 (inclusive)"}
  end

  def square(number) do
    # return the amount of grains on the square
    {:ok, (elem count_to_square(number), 0)}
  end

  @doc """
  Adds square of each number from 1 to 64.
  """
  @spec total :: pos_integer
  def total do
    # return the sum of grains on the board
    {:ok, (elem count_to_square(64), 1)}
  end

  defp count_to_square(i \\ 1, i_max, square \\ 1, sum \\ 1)

  defp count_to_square(i, i_max, square, sum) when i >= i_max do
    {square, sum}
  end

  defp count_to_square(i, i_max, square, sum) do
    next_square = square*2
    count_to_square(i+1, i_max, next_square, sum+next_square)
  end
end
