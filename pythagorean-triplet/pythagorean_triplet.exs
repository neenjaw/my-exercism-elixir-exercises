defmodule Triplet do
  @doc """
  Calculates sum of a given triplet of integers.
  """
  @spec sum([non_neg_integer]) :: non_neg_integer
  def sum(triplet) do
    Enum.sum(triplet)
  end

  @doc """
  Calculates product of a given triplet of integers.
  """
  @spec product([non_neg_integer]) :: non_neg_integer
  def product(triplet) do
    Enum.reduce(triplet, fn a, b -> a * b end)
  end

  @doc """
  Determines if a given triplet is pythagorean. That is, do the squares of a and b add up to the square of c?
  """
  @spec pythagorean?([non_neg_integer]) :: boolean
  def pythagorean?([a, b, c]) do
    (a*a) + (b*b) == (c*c)
  end

  @doc """
  Generates a list of pythagorean triplets from a given min (or 1 if no min) to a given max.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: [list(non_neg_integer)]
  def generate(min \\ 1, max) do
    # b is always 1 more than a so that it can't have duplicate entries like {3,4,5} and {4,3,5}
    for a <- min..max,
        b <- min..max,
        c <- min..max,
        a < b,
        b < c,
        pythagorean?([a,b,c])
    do
      [a,b,c]
    end
  end

  @doc """
  Generates a list of pythagorean triplets from a given min to a given max, whose values add up to a given sum.
  """
  @spec generate(non_neg_integer, non_neg_integer, non_neg_integer) :: [list(non_neg_integer)]
  def generate(min, max, sum) do
    generate(min, max)
    |> Enum.filter(fn t -> Triplet.sum(t) == sum end)
  end
end
