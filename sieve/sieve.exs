defmodule Sieve do
  @doc """
  Generates a list of primes up to a given limit.
  """
  @spec primes_to(non_neg_integer) :: [non_neg_integer]
  def primes_to(2), do: [2]
  def primes_to(limit) when limit > 2 do
    3..limit
    |> Enum.reduce([2], fn
      n, prime_list when rem(n,2) == 0 -> prime_list
      n, prime_list ->
        if prime?(n, prime_list) do
          [n | prime_list]
        else
          prime_list
        end
    end)
    |> Enum.reverse()
  end

  defp prime?(n, []), do: true
  defp prime?(n, [prime | primes]) do
    if rem(n, prime) == 0 do
      false
    else
      prime?(n, primes)
    end
  end
end
