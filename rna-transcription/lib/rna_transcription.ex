defmodule RnaTranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RNATranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna(charlist) :: charlist
  def to_rna(dna) do
    Enum.map(dna, fn
      ?A -> ?U
      ?C -> ?G
      ?T -> ?A
      ?G -> ?C
    end)
  end

  # def to_rna(dna) do
  #   dna
  #     |> Enum.map(&complement/1)
  # end

  # def complement(?A), do: ?U
  # def complement(?C), do: ?G
  # def complement(?T), do: ?A
  # def complement(?G), do: ?C
end
