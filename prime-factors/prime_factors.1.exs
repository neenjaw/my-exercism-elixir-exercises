defmodule PrimeFactors do

  defguardp is_factor(dividend, divisor) when rem(dividend, divisor) == 0

  defguardp is_even(number) when rem(number, 2) == 0
  defguardp is_odd(number) when rem(number, 2) == 1

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

  defp do_factors_for(dividend, divisor \\ 3, factors \\ [])

  defp do_factors_for(1, _, _), do: []

  defp do_factors_for(dividend, divisor, factors)
    when divisor >= dividend,
    do: [dividend | factors] |> Enum.sort

  defp do_factors_for(dividend, divisor, factors)
    when is_even(dividend), 
    do: do_factors_for_even(div(dividend, 2), divisor, [2 | factors])

  defp do_factors_for(dividend, divisor, factors)
    when is_odd(dividend),
    do: do_factors_for_odd(dividend, divisor, factors)
    
  defp do_factors_for_odd(dividend, divisor, factors) when is_factor(dividend, divisor) do
    quotient = div(dividend, divisor)
    
    if is_even(quotient) do
      do_factors_for_even(quotient, divisor, [divisor | factors])
    else
      do_factors_for_odd(quotient, divisor, [divisor | factors])
    end 
  end

  defp do_factors_for_odd(dividend, divisor, factors),
    do: do_factors_for(dividend, divisor+2, factors)

  defp do_factors_for_even(dividend, divisor, factors) do
    case rem(dividend, 2) do
      0 -> do_factors_for_even(div(dividend, 2), divisor, [2, factors])
      1 -> do_factors_for_odd(dividend, divisor, factors)
    end
  end

end
