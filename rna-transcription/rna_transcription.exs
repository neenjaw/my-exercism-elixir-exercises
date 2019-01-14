defmodule RNATranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RNATranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna([char]) :: [char]
  def to_rna(dna) do
    dna
      |> Enum.map(&complement(&1))
  end

  # def complement(?A), do: ?U
  # def complement(?C), do: ?G
  # def complement(?T), do: ?A
  # def complement(?G), do: ?C

  def complement(nucleotide) do
    case nucleotide do
      ?A -> ?U
      ?C -> ?G
      ?T -> ?A
      ?G -> ?C      
    end
  end
end
