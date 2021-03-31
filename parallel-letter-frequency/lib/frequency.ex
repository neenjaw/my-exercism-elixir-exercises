defmodule Frequency do
  @ignored_graphemes [" " | ~w(1 2 3 4 5 6 7 8 9 0 . , ; ' " : \( \) { } [ ] ?)]

  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency(texts, workers) do
    Stream.flat_map(texts, &String.split(&1, "\n", trim: true))
    |> Task.async_stream(&make_letter_map(&1), max_concurrency: workers)
    |> Stream.map(fn {:ok, r} -> r end)
    |> Enum.reduce(%{}, &Map.merge(&2, &1, fn _k, v1, v2 -> v1 + v2 end))
  end

  @spec make_letter_map(String.t()) :: map
  def make_letter_map(string) do
    string
    |> String.downcase()
    |> String.graphemes()
    |> Enum.reduce(%{}, &graphemes_frequencies/2)
  end

  defp graphemes_frequencies(grapheme, map) when grapheme in @ignored_graphemes, do: map

  defp graphemes_frequencies(grapheme, map) do
    Map.update(map, grapheme, 1, &(&1 + 1))
  end
end
