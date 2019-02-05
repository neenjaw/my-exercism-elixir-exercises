defmodule Frequency do
  @chunk_size 1000

  defp chunk_text(text, acc) do
    case String.split_at(text, @chunk_size) do
      {chunk, ""} ->
        [chunk | acc]
      {chunk, rest} ->
        [chunk | chunk_text(rest, acc)]
    end
  end

  defp count_letters(text, acc) do
    case String.next_grapheme(text) do
      {grapheme, rest} ->
        if String.match?(grapheme, ~r/^\p{L}$/u) do
          count_letters(rest, Map.update(acc, String.downcase(grapheme), 1, fn count -> count + 1 end))
        else
          count_letters(rest, acc)
        end
      nil ->
        acc
    end
  end

  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency([], _), do: %{}

  def frequency(texts, 1) do
    texts = IO.iodata_to_binary(texts)
    [texts]
    |> Enum.reduce([], &chunk_text/2)
    |> Enum.map( &(count_letters(&1, %{})) )
    |> Enum.reduce(%{}, &(Map.merge(&1, &2, fn _k, v1, v2 -> v1 + v2 end)))
  end

  def frequency(texts, workers) do
    texts = IO.iodata_to_binary(texts)
    [texts]
    |> Enum.reduce([], &chunk_text/2)
    |> Task.async_stream(&(count_letters(&1, %{})), [max_concurrency: workers, ordered: false])
    |> Enum.map(fn {:ok, value} -> value end)
    |> Enum.reduce(%{}, &(Map.merge(&1, &2, fn _k, v1, v2 -> v1 + v2 end)))
  end
end