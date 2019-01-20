defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t, [String.t]) :: [String.t]
  def match(base, candidates) do
    Enum.filter candidates, fn(candidate) -> anagram?(base, candidate) end
  end

  defp anagram?(base, candidate) do
    different_word?(base, candidate) and same_letters?(base, candidate)
  end

  defp different_word?(word1, word2) do
    normalize(word1) != normalize(word2)
  end

  defp same_letters?(word1, word2) do
    identity(word1) == identity(word2)
  end

  defp identity(word) do
    word |> normalize |> String.to_char_list |> Enum.sort
  end

  defp normalize(word), do: String.downcase(word)
end