defmodule PrimeFactors do

  defguardp is_factor(dividend, divisor) when rem(dividend, divisor) == 0

  @doc """
  Compute the prime factors for 'number'.

  The prime factors are prime numbers that when multiplied give the desired
  number.

  The prime factors of 'number' will be ordered lowest to highest.
  """
  @spec factors_for(pos_integer) :: [pos_integer]
  def factors_for(number) do
    do_factors_for(number)
  end

  defp do_factors_for(dividend, divisor \\ 2, factors \\ [])

  defp do_factors_for(1, _, _), do: [] 
  defp do_factors_for(num, num, factors), do: [num | factors] |> Enum.reverse

  defp do_factors_for(dividend, divisor, factors) when is_factor(dividend, divisor) do
    quotient = div(dividend, divisor)

    do_factors_for(quotient, divisor, [divisor | factors])
  end

  defp do_factors_for(dividend, divisor, factors) do
    next_divisor = 
      case divisor do
        2 -> 3
        _ -> divisor + 2
      end

    do_factors_for(dividend, next_divisor, factors)
  end
end
