defmodule FlattenArray do
  @doc """
  Accept a list and return the list
  flattened without nil values.

  ## Examples

  iex> FlattenArray.flatten([1, [2], 3, nil])
      [1,2,3]

  iex> FlattenArray.flatten([nil, nil])
      []

  """

  @spec flatten(list) :: list
  def flatten(list) do
    flatten(list, []) |> Enum.reverse
  end

  defp flatten([], acc), do: acc
  defp flatten([nil|rest], acc), do: flatten(rest, acc)
  defp flatten([e|rest], acc) when is_list(e) do
    sublist_acc = flatten(e,acc)
    flatten(rest, sublist_acc)
  end
  defp flatten([e|rest], acc), do: flatten(rest, [e|acc])
end
