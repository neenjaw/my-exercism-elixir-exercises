defmodule Transpose do
  @doc """
  Given an input text, output it transposed.

  Rows become columns and columns become rows. See https://en.wikipedia.org/wiki/Transpose.

  If the input has rows of different lengths, this is to be solved as follows:
    * Pad to the left with spaces.
    * Don't pad to the right.

  ## Examples
  iex> Transpose.transpose("ABC\nDE")
  "AD\nBE\nC"

  iex> Transpose.transpose("AB\nDEF")
  "AD\nBE\n F"
  """

  @spec transpose(String.t()) :: String.t()
  def transpose(input) do
    input_strings =
      input
      |> String.split("\n")

    max_str_length =
      input_strings
      |> Enum.reduce(0, fn str, max ->
        len = String.length(str)

        if len > max do
          len
        else
          max
        end
      end)

    input_strings
    |> Enum.map(fn str ->
      str
      |> String.pad_trailing(max_str_length)
      |> String.graphemes()
    end)
    |> Enum.zip
    |> Enum.map(fn row ->
      row
      |> Tuple.to_list()
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> String.trim_trailing()
  end
end
