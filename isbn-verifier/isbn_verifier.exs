defmodule ISBNVerifier do

  defguard is_isbn_digit(d)
    when (is_integer(d) and d >= 0 and d <= 9) or (d in ~w(0 1 2 3 4 5 6 7 8 9))
  defguard is_isbn_last_digit(d)
    when is_isbn_digit(d) or d == "X"

  @doc """
    Checks if a string is a valid ISBN-10 identifier

    ## Examples

      iex> ISBNVerifier.isbn?("3-598-21507-X")
      true

      iex> ISBNVerifier.isbn?("3-598-2K507-0")
      false

  """
  @spec isbn?(String.t()) :: boolean
  def isbn?(isbn) do
    isbn
    |> check_isbn_format()
    |> case do
      {:ok, :isbn_10, isbn} -> check_isbn_10_digits(isbn)
      {:ok, :isbn_13, isbn} -> check_isbn_13_digits(isbn)
      _ -> false
    end
  end

  @doc """
    Checks the formatting of the isbn passed to it.
    Determines whether is ISBN-10 or ISBN-13
    Removes dashes from the the ISBN string for further processing
  """
  @spec check_isbn_format(String.t()) :: {:ok, :isbn_10, String.t()} | {:ok, :isbn_13, String.t()} | {:error, String.t()}
  def check_isbn_format(dirty_isbn) do
    dashes = "-"

    clean_isbn =
      String.replace(dirty_isbn, dashes, "")

    cond do
      match_isbn_10?(clean_isbn) -> {:ok, :isbn_10, clean_isbn}
      match_isbn_13?(clean_isbn) -> {:ok, :isbn_13, clean_isbn}
      true -> {:error, "not an isbn"}
    end
  end

  @doc """
    Takes a string representation of the ISBN without dashes and returns
    whether it matches the ISBN-10 format
  """
  @spec match_isbn_10?(String.t()) :: boolean
  def match_isbn_10?(str) do
    isbn_10 = ~r/\d{9}[\dX]/u

    String.length(str) == 10 and String.match?(str, isbn_10)
  end

  @doc """
    Takes a string representation of the ISBN without dashes and returns
    whether it matches the ISBN-13 format
  """
  @spec match_isbn_13?(String.t()) :: boolean
  def match_isbn_13?(str) do
    isbn_13 = ~r/\d{13}/u

    String.length(str) == 13 and String.match?(str, isbn_13)
  end

  @doc """
    Takes a string representation of the ISBN-10 without dashes and returns
    whether the ISBN-10 is valid based on the check digit
  """
  @spec check_isbn_10_digits(String.t()) :: boolean
  def check_isbn_10_digits(s) when is_binary(s), do: s |> String.graphemes() |> do_check_isbn_10_digits()

  defp do_check_isbn_10_digits(str_digits, place \\ 10, sum \\ 0)

  defp do_check_isbn_10_digits([], :end, sum), do: rem(sum, 11) == 0

  defp do_check_isbn_10_digits([d | rest], 1, sum) do
    digit =
      case d do
        "X" -> 10
         _  -> String.to_integer(d)
      end

    do_check_isbn_10_digits(rest, :end, (digit + sum))
  end

  defp do_check_isbn_10_digits([d | rest], place, sum) do
    digit = String.to_integer(d)

    do_check_isbn_10_digits(rest, place-1, ((digit * place) + sum))
  end

  @doc """
    Takes a string representation of the ISBN-13 without dashes and returns
    whether the ISBN-13 is valid based on the check digit calculation
  """
  @spec check_isbn_13_digits(String.t()) :: boolean
  def check_isbn_13_digits(s) when is_binary(s), do: s |> String.graphemes() |> do_check_isbn_13_digits()

  defp do_check_isbn_13_digits(str_digits, place \\ 1, sum \\ 0)

  defp do_check_isbn_13_digits([], :end, sum), do: rem(sum, 10) == 0

  defp do_check_isbn_13_digits([d | rest], place, sum) when rem(place, 2) == 1 do
    digit = String.to_integer(d)

    next_place =
      case place do
        p when p >= 13 -> :end
        _ -> place+1
      end

    do_check_isbn_13_digits(rest, next_place, (digit+sum))
  end

  defp do_check_isbn_13_digits([d | rest], place, sum) when rem(place, 2) == 0 do
    digit = String.to_integer(d)

    do_check_isbn_13_digits(rest, place+1, ((digit*3)+sum))
  end


  @doc """
    Takes a string representation of the ISBN-10 and creates an
    ISBN-13 representation with new check digit
  """
  @spec isbn_10_to_isbn_13(String.t()) :: boolean
  def isbn_10_to_isbn_13(isbn10) do
    with {:ok, :isbn_10, clean_isbn10} <- check_isbn_format(isbn10) do
      clean_isbn10
      |> String.split_at(-1)
      |> Kernel.elem(0)
      |> (&("978" <> &1)).()
      |> append_isbn_13_check_digit
    else
      _ -> {:error, "Unable to convert string to ISBN-13 format"}
    end
  end

  @doc """
    Takes a string representation of the ISBN-13 without dashes without
    the 13th check digit.

    returns a string result of the ISBN-13 with the check digit
  """
  @spec append_isbn_13_check_digit(String.t()) :: boolean
  def append_isbn_13_check_digit(s) when is_binary(s), do: s |> String.graphemes |> do_append_isbn_13_check_digit

  defp do_append_isbn_13_check_digit(digits, place \\ 1, sum \\ 0, acc \\ [])

  defp do_append_isbn_13_check_digit([], :end, sum, acc) do
    check_digit =
      (10 - rem(sum, 10))
      |> case do
        10 -> 0
        d  -> d
      end

    [check_digit | acc]
    |> Enum.reverse
    |> Integer.undigits
    |> Integer.to_string
  end

  defp do_append_isbn_13_check_digit([d | rest], place, sum, acc) when rem(place,2) == 1 do
    digit = String.to_integer(d)

    do_append_isbn_13_check_digit(rest, place+1, (digit + sum), [digit | acc])
  end

  defp do_append_isbn_13_check_digit([d | rest], place, sum, acc) when rem(place, 2) == 0 do
    digit = String.to_integer(d)

    next_place =
      case place do
        12 -> :end
        _  -> place + 1
      end

    do_append_isbn_13_check_digit(rest, next_place, ((digit*3)+sum), [digit | acc])
  end
end
