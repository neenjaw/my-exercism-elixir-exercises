defmodule Roman do
  @doc """
  Convert the number to a roman number.
  """
  @spec numerals(pos_integer) :: String.t()
  def numerals(number) when number == 0, :do "nulla"
  def numerals(number) when number > 0 and number < 4000 do
    [thousand, hundred, ten, one] =
      number
      |> Integer.to_string()
      |> String.pad_leading(4, "0")
      |> String.graphemes()

    rthousand = get_roman_value(thousand, "M")
    rhundred  = get_roman_value(hundred, "C", "D", "M")
    rten      = get_roman_value(ten, "X", "L", "C")
    rone      = get_roman_value(one, "I", "V", "X")
    
    "#{rthousand}#{rhundred}#{rten}#{rone}"
  end

  defp get_roman_value(n, current, half_next \\ "", next \\ "") do
    case n do
      "0" -> ""
      "1" -> current
      "2" -> current <> current
      "3" -> current <> current <> current
      "4" -> current <> half_next
      "5" -> half_next
      "6" -> half_next <> current
      "7" -> half_next <> current <> current
      "8" -> half_next <> current <> current <> current
      "9" -> current <> next
    end
  end 
end
