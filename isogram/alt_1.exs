defmodule Isogram do
  @doc """
  Determines if a word or sentence is an isogram
  """
  @spec isogram?(String.t) :: boolean
  def isogram?(sentence) do
    words = Regex.scan(~r/\w/u, sentence)
    Enum.uniq(words) == words
  end
end