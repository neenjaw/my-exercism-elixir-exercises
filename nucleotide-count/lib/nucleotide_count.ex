defmodule NucleotideCount do
  @nucleotides [?A, ?C, ?G, ?T]

  @doc """
  Counts individual nucleotides in a DNA strand.

  ## Examples

  iex> NucleotideCount.count('AATAA', ?A)
  4

  iex> NucleotideCount.count('AATAA', ?T)
  1
  """
  @spec count(charlist(), char()) :: non_neg_integer()
  def count(strand, nucleotide) do
    {_, count} = histogram(strand) |> Map.fetch(nucleotide)
    count
  end

  @doc """
  Returns a summary of counts by nucleotide.

  ## Examples

  iex> NucleotideCount.histogram('AATAA')
  %{?A => 4, ?T => 1, ?C => 0, ?G => 0}
  """
  @spec histogram([char]) :: map
  def histogram(strand) do
    make_histogram(%{?A => 0, ?T => 0, ?C => 0, ?G => 0}, strand)
  end

  defp make_histogram(histo_map, []), do: histo_map
  defp make_histogram(histo_map, [nucleotide | strand]) do
    Map.update(histo_map, nucleotide, 0, &(&1 + 1))
      |> make_histogram(strand)
  end
end
