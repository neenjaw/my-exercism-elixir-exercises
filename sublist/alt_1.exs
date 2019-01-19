defmodule Sublist do
  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """
  def compare(a, b) do
    cond do
      a == b           -> :equal
      is_sublist?(a,b) -> :sublist
      is_sublist?(b,a) -> :superlist
      true             -> :unequal
    end
  end

  defp is_sublist?(a, []) do
    false
  end
  defp is_sublist?(a, b) do
    :lists.prefix(a, b) || is_sublist?(a, tl(b))
  end
end
