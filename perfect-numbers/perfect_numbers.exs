defmodule PerfectNumbers do

  defguard is_natural_number(number) when is_integer(number) and number > 0

  @doc """
  Determine the aliquot sum of the given `number`, by summing all the factors
  of `number`, aside from `number` itself.

  Based on this sum, classify the number as:

  :perfect if the aliquot sum is equal to `number`
  :abundant if the aliquot sum is greater than `number`
  :deficient if the aliquot sum is less than `number`
  """
  @spec classify(number :: integer) :: {:ok, atom} | {:error, String.t()}

  def classify(number) when is_natural_number(number) do
    classification =
      case do_aliquot_sum(number) do
        sum when sum == number -> :perfect
        sum when sum >  number -> :abundant
        sum when sum <  number -> :deficient
      end

    {:ok, classification}
  end
  def classify(_) do
    {:error, "Classification is only possible for natural numbers."}
  end

  defp do_aliquot_sum(target, current \\ 2, factors \\ [1])
  defp do_aliquot_sum(1, _, _), do: 0
  defp do_aliquot_sum(target, target, factors), do: Enum.sum(factors)
  defp do_aliquot_sum(target, current, factors) when rem(target, current) == 0 do
    do_aliquot_sum(target, current + 1, [current | factors])
  end
  defp do_aliquot_sum(target, current, factors) do
    do_aliquot_sum(target, current + 1, factors)
  end
end
