defmodule Pangram do
  @doc """
  Determines if a word or sentence is a pangram.
  A pangram is a sentence using every letter of the alphabet at least once.

  Returns a boolean.

    ## Examples

      iex> Pangram.pangram?("the quick brown fox jumps over the lazy dog")
      true

  """

  @spec pangram?(String.t()) :: boolean
  def pangram?(sentence) do
    alphabet = ~r/[a-z]/ui

    sentence
    |> String.downcase
    |> String.graphemes
    |> Enum.reduce(MapSet.new(), fn c, acc -> cond do
        Regex.match?(alphabet, c) -> MapSet.put(acc, c)
        true -> acc
      end
    end)
    |> (fn alphabet_set -> MapSet.size(alphabet_set) == 26 end).()
  end
end
