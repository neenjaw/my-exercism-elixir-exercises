defmodule Phone do
  @ignored " +.-()" |> String.graphemes
  @digits "0123456789" |> String.graphemes
  @ndigits "23456789" |> String.graphemes
  @nplaces [10, 7]

  @err_number "0000000000"
  
  @doc """
  Remove formatting from a phone number.

  Returns "0000000000" if phone number is not valid
  (10 digits or "1" followed by 10 digits)

  ## Examples

  iex> Phone.number("212-555-0100")
  "2125550100"

  iex> Phone.number("+1 (212) 555-0100")
  "2125550100"

  iex> Phone.number("+1 (212) 055-0100")
  "0000000000"

  iex> Phone.number("(212) 555-0100")
  "2125550100"

  iex> Phone.number("867.5309")
  "0000000000"
  """
  @spec number(String.t()) :: String.t()
  def number(raw) do
    # @phone_regex
    # |> Regex.run(raw, capture: :all_names)

    raw
    |> String.graphemes
    |> filter_numbers
    |> case do
      :error -> @err_number
      {l, n} -> validate_number(l,n)
    end
  end

  # private function to filter the list of strings to only numbers
  defp filter_numbers(raw, acc \\ [], acc_count \\ 0)
  
  # base cases
  defp filter_numbers(_raw, _acc, acc_count) when acc_count > 11, do: :error
  defp filter_numbers([], _acc, acc_count) when acc_count < 10, do: :error
  defp filter_numbers([], acc, acc_count), do: {acc |> Enum.reverse, acc_count} 
  
  # recursive cases
  defp filter_numbers([c|rest], acc, acc_count) when c in @ignored, do: filter_numbers(rest, acc, acc_count)
  defp filter_numbers([c|rest], acc, acc_count) when c in @digits, do: filter_numbers(rest, [c|acc], acc_count+1)

  # if no match, assume an illegal character, throw error
  defp filter_numbers(_raw, _acc, _acc_count), do: :error

  # private function to validate the list of numbers if it is a phone number
  defp validate_number(l, p), do: validate_number(l, p, l)

  # base cases
  defp validate_number([], 0, number), do: number |> Enum.join
  defp validate_number(_, 0, _), do: @err_number

  # validate the country code
  defp validate_number(["1"| rest], 11, number), do: validate_number(rest, 10, Enum.drop(number, 1))
  # error if invalid country code
  defp validate_number([ _ |_rest], 11, _number), do: @err_number

  # recursive cases
  defp validate_number([d|rest], p, number) when d in @ndigits and p in @nplaces, do: validate_number(rest, p-1, number)
  defp validate_number([d|rest], p, number)  when d in @digits and p not in @nplaces, do: validate_number(rest, p-1, number)

  # if no match to previous functions then assume there's an invalid digit
  defp validate_number(_,_,_), do: @err_number


  @doc """
  Extract the area code from a phone number

  Returns the first three digits from a phone number,
  ignoring long distance indicator

  ## Examples

  iex> Phone.area_code("212-555-0100")
  "212"

  iex> Phone.area_code("+1 (212) 555-0100")
  "212"

  iex> Phone.area_code("+1 (012) 555-0100")
  "000"

  iex> Phone.area_code("867.5309")
  "000"
  """
  @spec area_code(String.t()) :: String.t()
  def area_code(raw) do
    raw 
    |> number 
    |> String.slice(0..2)
  end

  @doc """
  Pretty print a phone number

  Wraps the area code in parentheses and separates
  exchange and subscriber number with a dash.

  ## Examples

  iex> Phone.pretty("212-555-0100")
  "(212) 555-0100"

  iex> Phone.pretty("212-155-0100")
  "(000) 000-0000"

  iex> Phone.pretty("+1 (303) 555-1212")
  "(303) 555-1212"

  iex> Phone.pretty("867.5309")
  "(000) 000-0000"
  """
  @spec pretty(String.t()) :: String.t()
  def pretty(raw) do
    ph_number = raw |> number

    area_code = ph_number |> String.slice(0..2)
    first = ph_number |> String.slice(3..5)
    second = ph_number |> String.slice(6..10)

    "(#{area_code}) #{first}-#{second}"
  end
end