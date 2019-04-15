defmodule Squares do
  @moduledoc """
  Calculate sum of squares, square of sum, difference between two sums from 1 to a given end number.
  """

  @doc """
  Calculate sum of squares from 1 to a given end number.
  """
  @spec sum_of_squares(pos_integer) :: pos_integer
  def sum_of_squares(number) when number > 0 do
    1..number
    |> Stream.map(fn n -> n*n end)
    |> Enum.reduce(fn n, acc -> n + acc end)
  end

  @doc """
  Calculate square of sum from 1 to a given end number.
  """
  @spec square_of_sum(pos_integer) :: pos_integer
  def square_of_sum(number) when number > 0 do
    1..number
    |> Enum.sum()
    |> (fn n -> n * n end).()
  end

  @doc """
  Calculate difference between sum of squares and square of sum from 1 to a given end number.
  """
  @spec difference(pos_integer) :: pos_integer
  def difference(number) do
    %{count: c, sum: sum, squares: sum_of_squares} =
      %{count: 1, sum: 1, squares: 1}
      |> Stream.iterate(fn %{count: c, sum: m, squares: q} ->
        next = c + 1

        %{count: next, sum: (m + next), squares: (q + (next * next))}
      end)
      |> Stream.take(number)
      |> Enum.to_list
      |> List.last

    square_of_sums = (sum * sum)

    square_of_sums - sum_of_squares
  end
end
