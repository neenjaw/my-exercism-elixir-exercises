defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t(), [String.t()]) :: [String.t()]
  def match(base, candidates) do
    base_length    = String.length(base)
    base_downcased = String.downcase(base)
    base_sorted    = sort_string(base_downcased)
    
    candidates
    |> Enum.filter(&filter_by_length(&1, base_length))
    |> Enum.map(&create_candidate_tuple)
    |> Enum.filter(&filter_if_not_anagram(&1, base_downcased, base_sorted))
    |> Enum.map(fn {candidate, _, _} -> candidate end)
  end

  defp sort_string(string) do
    string
    |> to_charlist
    |> Enum.sort
    |> to_string
  end
  
  defp filter_by_length(candidate, matching_length) do
    matching_length == String.length(candidate)
  end

  defp create_candidate_tuple(candidate) do
    candidate_downcased = String.downcase(candidate)

    {candidate, candidate_downcased, sort_string(candidate_downcased)} 
  end
  
  defp filter_if_not_anagram({_, candidate_downcased, candidate_sorted}, base_downcased, base_sorted) do
    (candidate_downcased != base_downcased) and (candidate_sorted == base_sorted)
  end
end
