defmodule ProteinTranslation do
  @doc """
  Given an RNA string, return a list of proteins specified by codons, in order.
  """
  @spec of_rna(String.t()) :: {atom, list(String.t())}
  def of_rna(rna) do
    amino_chain = rna
      |> Stream.unfold(&String.split_at(&1, 3)) # stream the rna
      |> Enum.take_while(&(&1 != "")) # stop when empty string
      |> Enum.map(&of_codon(&1)) # get the codons

    cond do
      Enum.any?(amino_chain, fn {x, _} -> x == :error end) -> {:error, "invalid RNA"} # if any errors, abort
      true -> Enum.map(amino_chain, fn {_, amino} -> amino end) # get the amino
                |> Enum.split_while(fn x -> x != "STOP" end) # split when hit stop marker
                |> (fn {x, _} -> x end).() # take the first list
                |> Enum.join(" ")
                |> (fn x -> {:ok, ~w(#{x})} end).() # formulate the response
    end
  end


  @doc """
  Given a codon, return the corresponding protein

  UGU -> Cysteine
  UGC -> Cysteine
  UUA -> Leucine
  UUG -> Leucine
  AUG -> Methionine
  UUU -> Phenylalanine
  UUC -> Phenylalanine
  UCU -> Serine
  UCC -> Serine
  UCA -> Serine
  UCG -> Serine
  UGG -> Tryptophan
  UAU -> Tyrosine
  UAC -> Tyrosine
  UAA -> STOP
  UAG -> STOP
  UGA -> STOP
  """
  @spec of_codon(String.t()) :: {atom, String.t()}
  def of_codon(codon) do
    amino = 
      cond do
        codon in ["UGU", "UGC"]               -> "Cysteine"
        codon in ["UUA", "UUG"]               -> "Leucine"
        codon in ["AUG"]                      -> "Methionine"
        codon in ["UUU", "UUC"]               -> "Phenylalanine"
        codon in ["UCU", "UCC", "UCA", "UCG"] -> "Serine"
        codon in ["UGG"]                      -> "Tryptophan"
        codon in ["UAU", "UAC"]               -> "Tyrosine"
        codon in ["UAA", "UAG", "UGA"]        -> "STOP"
        true -> :error
      end
    
    case amino do
      :error -> {:error, "invalid codon"}
      _ ->      {:ok, amino}
    end
  end
end
