defmodule Grains do
  use Bitwise

  @squares 64

  @doc """
  Calculate two to the power of the input minus one.
  """
  @spec square(pos_integer) :: {atom, pos_integer}
  def square(number) when number not in 1..@squares, do: {:error, "The requested square must be between 1 and #{@squares} (inclusive)"}
  def square(number), do: {:ok, 1 <<< number - 1}

  @doc """
  Adds square of each number from 1 to 64.
  """
  @spec total :: {atom, pos_integer}
  def total, do: {:ok, (1 <<< @squares) - 1}
end