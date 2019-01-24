defmodule AllYourBase do
  @doc """
  Given a number in base a, represented as a sequence of digits, converts it to base b,
  or returns nil if either of the bases are less than 2
  """
  @spec convert(list, integer, integer) :: list
  # handle obvious error cases
  def convert([], _, _), do: nil
  def convert(_, base_a, _) when base_a < 2, do: nil
  def convert(_, _, base_b) when base_b < 2, do: nil
  # handle zero case
  def convert([0], _, _), do: [0]
  # no conversion neccessary
  def convert(digits, base, base), do: digits
  # simplify logic if to or from base 10
  def convert(digits, 10, base_b), do: from_base_ten(digits, base_b)
  def convert(digits, base_a, 10), do: to_base_ten(digits, base_a)
  # from any base to any base
  def convert(digits, base_a, base_b) do 
    to_base_ten(digits, base_a)
    |> from_base_ten(base_b)
  end

  # Converts a base-x number represented by a list of integers 0-base to the base-10
  def to_base_ten(digits, base) do
    digits 
    |> Enum.reverse 
    |> to_base_ten(base, 0, 0) 
  end

  defp to_base_ten([], _base, _place, acc), do: Integer.digits(acc)
  defp to_base_ten([h | _t], base, _place, _acc) when h >= base or h < 0, do: nil
  defp to_base_ten([h | t], base, place, acc) do
    to_base_ten(t, base, (place + 1), ((h * (pow base, place)) + acc))
  end

  # Converts a base-10 number represented by a list of integers 0-9 to the specified base
  def from_base_ten([0], _base), do: [0]
  def from_base_ten(digits, base) do
    Integer.undigits(digits) 
    |> from_base_ten(base, [])
    |> case do
      [] -> [0]
      d  -> d  
    end
  end

  defp from_base_ten(number, _base, _digits) when number < 0, do: nil
  defp from_base_ten(0, _base, digits), do: digits
  defp from_base_ten(number, base, digits) do
    Integer.floor_div(number, base)
    |> from_base_ten(base, [Integer.mod(number, base)|digits])
  end

  # Integer power function
  def  pow(n, k), do: pow(n, k, 1)        
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end
