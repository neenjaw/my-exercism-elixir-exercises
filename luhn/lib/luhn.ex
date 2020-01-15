defmodule Luhn do
  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean
  def valid?(number) do
    number =
      number
      |> String.replace(" ", "")
      |> String.graphemes()

    state = %{
      digit_count: 0,
      sum: 0,
      double_digit?: length(number) |> rem(2) == 0
    }

    with %{digit_count: c, sum: s} <- Enum.reduce_while(number, state, &reduce_luhn/2) do
      c > 1 and rem(s, 10) == 0
    else
      _ -> false
    end
  end

  def reduce_luhn(digit, state) do
    with {digit, ""} <- Integer.parse(digit),
         digit <- (if state.double_digit?, do: digit * 2, else: digit),
         digit <- (if digit > 9, do: digit - 9, else: digit),
         sum <- state.sum + digit,
         digit_count <- state.digit_count + 1,
         double_digit? <- not state.double_digit? do
      {:cont, %{digit_count: digit_count, sum: sum, double_digit?: double_digit?}}
    else
      _ -> {:halt, {:error, "invalid number"}}
    end
  end
end
