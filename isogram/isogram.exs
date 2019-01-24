defmodule Isogram do
  @doc """
  Determines if a word or sentence is an isogram
  """
  @spec isogram?(String.t()) :: boolean
  def isogram?(sentence) do
    just_letters = sentence
    |> String.downcase
    |> String.replace(~r/[^\w]/, "")

    uniq_letter_count = just_letters
    |> String.graphemes
    |> MapSet.new
    |> MapSet.size == String.length(just_letters)
  end
end
