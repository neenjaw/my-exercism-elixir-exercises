defmodule ArmstrongNumber do 
  @moduledoc """
  Provides a way to validate whether or not a number is an Armstrong number
  """

  defguardp is_natural_number(number) when is_integer(number) and number > 0

  @spec valid?(integer) :: boolean
  def valid?(number) when is_natural_number(number) do
    digits = 
      number
      |> Integer.digits

    number_of_digits =
      length(digits)

    digits
    |> Stream.map(fn n -> pow(n, number_of_digits) end)
    |> Enum.sum
    |> case do
      ^number -> true
      _number -> false  
    end
  end

  
  # Integer power function
  defp pow(number, c), do: pow(number, c, 1)

  defp pow(_number, 0,     acc), do: acc
  defp pow(number,  c, acc), do: pow(number, c - 1, number * acc)
end
