defmodule SumOfMultiples do
  @doc """
  Adds up all numbers from 1 to a given end number that are multiples of the factors provided.
  """
  @spec to(non_neg_integer, [non_neg_integer]) :: non_neg_integer
  def to(limit, factors) when limit >= 1 do
    Range.new(1, limit-1)
    |> Enum.filter(fn i ->
      Enum.any?(factors, fn j -> rem(i, j) == 0 end)    
    end)
    |> Enum.reduce(0, fn i, acc -> i + acc end)
  end
end
