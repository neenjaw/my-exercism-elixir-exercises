if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("rna_transcription.exs", __DIR__)
end

ExUnit.start()
ExUnit.configure(exclude: :pending, trace: true)

defmodule RNATranscriptionTest do
  use ExUnit.Case

  # @tag :pending
  test "transcribes guanine to cytosine" do
    assert RNATranscription.to_rna('G') == 'C'
  end

  # @tag :pending
  test "transcribes cytosine to guanine" do
    assert RNATranscription.to_rna('C') == 'G'
  end

  # @tag :pending
  test "transcribes thymidine to adenine" do
    assert RNATranscription.to_rna('T') == 'A'
  end

  # @tag :pending
  test "transcribes adenine to uracil" do
    assert RNATranscription.to_rna('A') == 'U'
  end

  # @tag :pending
  test "it transcribes all dna nucleotides to rna equivalents" do
    assert RNATranscription.to_rna('ACGTGGTCTTAA') == 'UGCACCAGAAUU'
  end

  test "a very long strand to discover performance issues" do
    {dna_strand, rna_strand} =
      [{?A, ?U}, {?C, ?G}, {?T, ?A}, {?G, ?C}]
      |> Stream.cycle()
      |> Stream.take(27_000)
      |> Enum.unzip()

    assert RNATranscription.to_rna(dna_strand) == rna_strand
  end
end
