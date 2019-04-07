defmodule CollatzConjecture do

  defguardp is_natural_number(number) when is_integer(number) and number > 0
  defguardp is_even(number) when rem(number, 2) == 0

  @doc """ 
  calc/1 takes an integer and returns the number of steps required to get the
  number to 1 when following the rules:
    - if number is odd, multiply with 3 and add 1
    - if number is even, divide by 2
  """
  @spec calc(number :: pos_integer) :: pos_integer

  def calc(number) when is_natural_number(number), do: do_calc(number)
  def calc(_), do: raise FunctionClauseError

  defp do_calc(number, step_count \\ 0)
  
  defp do_calc(1, step_count), do: step_count

  defp do_calc(number, step_count) when is_even(number),
    do: do_calc(div(number, 2), step_count+1)

  defp do_calc(number, step_count),
    do: do_calc(((number * 3) + 1), step_count+1)
end
