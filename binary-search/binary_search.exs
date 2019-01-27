defmodule BinarySearch do
  @doc """
    Searches for a key in the tuple using the binary search algorithm.
    It returns :not_found if the key is not in the tuple.
    Otherwise returns {:ok, index}.

    ## Examples

      iex> BinarySearch.search({}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 2)
      :not_found

      iex> BinarySearch.search({1, 3, 5}, 5)
      {:ok, 2}

  """
  @spec search(tuple, integer) :: {:ok, integer} | :not_found
  def search(numbers, key) do
    last_index = tuple_size(numbers)-1
    search(numbers, 0, last_index, key)
  end
  
  # Function definitions to match edge cases
  defp search({},  _, _, _), do: :not_found
  defp search({e}, _, _, e), do: {:ok, 0}
  defp search({_}, _, _, _), do: :not_found
  
  # either find the match at the midpoint, or constrain the search and try again
  defp search(t, first_index, last_index, goal) when first_index <= last_index do
    midpoint = (div (last_index - first_index), 2) + first_index
    e = elem t, midpoint
    
    cond do
      goal == e -> {:ok, midpoint}
      goal < e  -> search(t, first_index, midpoint-1, goal)
      goal > e  -> search(t, midpoint+1, last_index, goal)
    end
  end
  # if the indexes create a "negative" search area, means that the key does not exist in the tuple
  defp search(_t, first_index, last_index, _goal) when first_index > last_index, do: :not_found
end
