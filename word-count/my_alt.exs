defmodule Words do
  @doc """
  Count the number of words in the sentence.

  Words are compared case-insensitively.
  """
  @spec count(String.t()) :: map
  def count(sentence) do
    # Break the sentence up by all characters that are:
    #   - non-unicode word characters
    #   - non hyphens
    #   - underscores
    String.split(sentence, ~r{([^\w-]|_)+}u, trim: true)
      |> get_word_map(%{})
  end

  @spec get_word_map(list(String.t()), map) :: map
  defp get_word_map([], word_map), do: word_map
  defp get_word_map([first_word | next_words], word_map) do
    downcase_word = String.downcase(first_word)
    updated_map = Map.update(word_map, downcase_word, 1, &(&1 + 1))
    get_word_map(next_words, updated_map)
  end
end
