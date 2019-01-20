defmodule Anagram do
  @doc """
  Returns all candidates that are anagrams of, but not equal to, 'base'.
  """
  @spec match(String.t(), [String.t()]) :: [String.t()]
  def match(base, candidates) do
    base_length = base |> String.length
    base_sorted = base |> sort_string
    base_downcase = base |> String.downcase
    
    candidates
    |> Enum.filter(fn c -> base_length == String.length(c) end)
    |> Enum.map(fn c -> {c, c |> String.downcase, c |> sort_string} end)
    |> Enum.filter(fn {c, d, s} -> (d != base_downcase) and (s == base_sorted) end)
    |> Enum.map(fn {c, _, _} -> c end)
  end

  defp sort_string(string) do
    string
    |> String.downcase
    |> to_charlist
    |> Enum.sort
    |> to_string
  end
end
