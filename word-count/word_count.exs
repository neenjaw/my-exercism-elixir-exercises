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
    split_by = ~r{[^[:alnum:]-]}u

    sentence
    |> String.downcase()
    |> String.split(split_by, trim: true)
    |> List.foldl(%{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
  end
end
