defmodule Sublist do
  @doc """
  Returns whether the first list is a sublist or a superlist of the second list
  and if not whether it is equal or unequal to the second list.
  """

  # trivial cases
  def compare(l, l) when is_list(l), do: :equal
  def compare([], l) when is_list(l), do: :sublist
  def compare(l, []) when is_list(l), do: :superlist
  
  def compare(a, b) do
    length_a = length(a)
    length_b = length(b)

    # the traverse fn assumes that the first list is less than or equal to
    # the second list, therefore, using the lengths, reverse the order
    # of the lists if needed
    cond do
      length_a <= length_b -> {:fwd, (traverse(a, b, length_a, length_b))}
      true                 -> {:rev, (traverse(b, a, length_b, length_a))}
    end
    |> case do
      {:rev, :sublist} -> :superlist # if reversed, then reverse the sublist atom
      {_, x}           -> x
    end
  end

  # if there a is longer than the remainder of b
  defp traverse(_a, _b, length_a, length_b) when length_a > length_b, do: :unequal
  # recursive step
  defp traverse(a, [b|rest], length_a, length_b) do
    [b|rest]
    |> Enum.take(length_a)
    |> (fn
        ^a -> :sublist
        _  -> traverse(a, rest, length_a, (length_b - 1))
      end).()
  end
end
