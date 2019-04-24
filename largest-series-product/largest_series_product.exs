defmodule Series do
  @doc """
  Finds the largest product of a given number of consecutive numbers in a given string of numbers.
  """
  @spec largest_product(String.t(), non_neg_integer) :: non_neg_integer
  def largest_product(_number_string, size)
    when size < 0, do: raise ArgumentError, "Size cannot be negative"
  def largest_product(_number_string, 0),
    do: 1
  def largest_product(number_string, size) do
    if size > String.length(number_string),
      do: raise ArgumentError, "Can't make a series longer than the number of digits"

    number_string
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(size, 1, :discard)
    |> Enum.map(fn chunk -> product_of(chunk) end)
    |> Enum.max()
  end

  defp product_of(chunk, product \\ 1)
  defp product_of([], product), do: product
  defp product_of([h | t], product), do: product_of(t, (product * h))
end
