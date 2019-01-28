defmodule ETL do
  @doc """
  Transform an index into an inverted index.

  ## Examples

  iex> ETL.transform(%{"a" => ["ABILITY", "AARDVARK"], "b" => ["BALLAST", "BEAUTY"]})
  %{"ability" => "a", "aardvark" => "a", "ballast" => "b", "beauty" =>"b"}
  """
  @spec transform(map) :: map
  def transform(input) do
    input
    |> Map.to_list
    |> key_values_list_transform 
  end

  # Enumerate over the key-values and transform them to the new format
  defp key_values_list_transform(key_values_list) do
    key_values_list
    |> Enum.reduce(%{}, &key_values_transform(&1, &2))
  end

  # Enumerate over the values and create the new entry to put in the map
  defp key_values_transform({old_key, value_list}, map) do 
    value_list
    |> Enum.reduce(map, fn value, acc_map -> 
      new_key = value |> String.downcase

      Map.put(acc_map, new_key, old_key)
    end)
  end
end
