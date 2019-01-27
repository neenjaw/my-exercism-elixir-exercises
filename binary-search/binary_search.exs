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
    search(numbers, 0, (tuple_size(numbers)-1), key)
  end
  
  def search({},  _, _, _), do: :not_found
  def search({e}, _, _, e), do: {:ok, e}
  def search({_}, _, _, _), do: :not_found
  
  def search(t, first_index, last_index, goal) when first_index <= last_index do
    midpoint = (div (last_index - first_index), 2) + first_index
    e = elem t, midpoint
    
    # IO.inspect(t)
    # IO.puts("elem: #{e}, first: #{first_index}, last: #{last_index}, midpoint: #{midpoint}, goal: #{goal}\n")

    cond do
      goal == e -> {:ok, e}
      goal < e  -> search(t, first_index, midpoint-1, goal)
      goal > e  -> search(t, midpoint+1, last_index, goal)
    end
  end
  def search(_t, first_index, last_index, _goal) when first_index > last_index, do: :not_found
end
