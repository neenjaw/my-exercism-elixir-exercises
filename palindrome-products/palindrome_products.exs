defmodule Palindromes do
  @doc """
  Generates all palindrome products from an optionally given min factor (or 1) to a given max factor.
  """
  @spec generate(non_neg_integer, non_neg_integer) :: map
  def generate(max_factor, min_factor \\ 1) do
    range = min_factor..max_factor

    palendrome_map =
      for a <- range,
          b <- range,
          a <= b,
          p = a*b,
          r = (Integer.digits(p) |> Enum.reverse() |> Integer.undigits()),
          p == r
      do
        {a,b,p}
      end
      |> Enum.reduce(%{}, fn {a,b,p}, map ->
        Map.update(map, p, [[a,b]], &(if [a,b] not in &1, do: [[a,b] | &1], else: &1))
      end)

    {min_palendrome, max_palendrome} =
      palendrome_map
      |> Map.keys()
      |> Enum.sort()
      |> Enum.min_max()

    %{}
    |> Map.put(min_palendrome, palendrome_map[min_palendrome])
    |> Map.put(max_palendrome, palendrome_map[max_palendrome])
  end
end
