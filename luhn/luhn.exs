defmodule Luhn do
  @numbers ~w/0 1 2 3 4 5 6 7 8 9/

  @doc """
  Checks if the given number is valid via the luhn formula
  """
  @spec valid?(String.t()) :: boolean
  def valid?(number) do
    number
    |> clean_and_reverse_number
    |> case do
      :error -> false

      [_]    -> false

      number_list ->
        luhn_sum =
          number_list
          |> double_every_second_number()
          |> subtract_nine_if_over_nine()
          |> Enum.sum()

        # check if evenly divisible by 10
        rem(luhn_sum, 10) == 0
    end
  end

  defp clean_and_reverse_number(number) do
    with {:list, number_string_list} <- {:list, number |> String.graphemes},
         {:ok, cleaned_number_string_list} <- number_string_list |> do_clean_number
    do
      cleaned_number_string_list
      |> Enum.map(fn n -> String.to_integer(n) end)
    else
      {:error, _} -> :error
    end
  end

  defp do_clean_number(number, acc \\ [])
  defp do_clean_number([],             acc),                    do: {:ok, acc}
  defp do_clean_number([g   |  rest],  acc) when g in @numbers, do: do_clean_number(rest, [g | acc])
  defp do_clean_number([" " |  rest],  acc),                    do: do_clean_number(rest, acc)
  defp do_clean_number([_   | _rest], _acc),                    do: {:error, "Invalid Character"}

  defp double_every_second_number(list, double_flag \\ false, acc \\ [])
  defp double_every_second_number([], _, acc), do: acc
  defp double_every_second_number([i | rest], true,  acc), do: double_every_second_number(rest, false, [i*2 | acc])
  defp double_every_second_number([i | rest], false, acc), do: double_every_second_number(rest, true,  [i | acc])

  defp subtract_nine_if_over_nine(number_list) do
    number_list
    |> Enum.map(&do_subtract_nine_if_over_nine(&1))
  end

  defp do_subtract_nine_if_over_nine(number) when number > 9, do: number - 9
  defp do_subtract_nine_if_over_nine(number), do: number
end
