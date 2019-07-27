defmodule Hamming do
  @doc """
  Returns number of differences between two strands of DNA, known as the Hamming Distance.

  ## Examples

  iex> Hamming.hamming_distance('AAGTCATA', 'TAGCGATC')
  {:ok, 4}
  """
  @spec hamming_distance([char], [char]) :: {:ok, non_neg_integer} | {:error, String.t()}
  def hamming_distance(strand1, strand2), do: count_mutations(strand1, strand2)

  defp count_mutations(strand1, strand2, acc \\ 0)

  # Base case
  defp count_mutations([], [], acc), do: {:ok, acc}

  # Function not defined for character lists of unequal length
  defp count_mutations([], _, _acc), do: {:error, "Lists must be the same length"}
  defp count_mutations(_, [], _acc), do: {:error, "Lists must be the same length"}

  # Recursive cases
  defp count_mutations([n|strand1], [n|strand2], acc), do: count_mutations(strand1, strand2, acc)
  defp count_mutations([_|strand1], [_|strand2], acc), do: count_mutations(strand1, strand2, acc+1)
end
