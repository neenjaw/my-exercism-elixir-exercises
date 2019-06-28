defmodule RNATranscription do
  @doc """
  Transcribes a character list representing DNA nucleotides to RNA

  ## Examples

  iex> RNATranscription.to_rna('ACTG')
  'UGAC'
  """
  @spec to_rna([char]) :: [char]
  def to_rna(dna) do
    Enum.map(dna, fn
      ?A -> ?U
      ?C -> ?G
      ?T -> ?A
      ?G -> ?C
    end)
  end

  # Non-performant:
  #
  # def to_rna(dna) do
  #   mapper = fn
  #     ?A -> ?U
  #     ?C -> ?G
  #     ?T -> ?A
  #     ?G -> ?C
  #   end

  #   Enum.reduce(dna, [], fn nuc, acc -> acc ++ [mapper.(nuc)] end)
  # end

end
