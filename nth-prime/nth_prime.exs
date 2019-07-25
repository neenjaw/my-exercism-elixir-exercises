defmodule Prime do
  @doc """
  Generates the nth prime.
  """
  @spec nth(non_neg_integer) :: non_neg_integer
  def nth(1), do: 2
  def nth(2), do: 3
  def nth(3), do: 5
  def nth(4), do: 7
  def nth(n), do: calc_nth(n)

  defp calc_nth(n, acc \\ 5, i \\ 11)
  
  defp calc_nth(n, n, i) do
    i
  end
  
  defp calc_nth(n, acc, i) when acc < n do
    cond do
      prime?(i+1) -> 
        calc_nth(n, acc+1, i+1)
        
      true -> 
        calc_nth(n, acc, i+1)
    end
  end

  defp prime?(i, n \\ 2)
  defp prime?(i, n) when n < i and rem(i, n) == 0, do: false
  defp prime?(i, n) when n < i, do: is_prime(i, n+1)
  defp prime?(i, i), do: true
end
