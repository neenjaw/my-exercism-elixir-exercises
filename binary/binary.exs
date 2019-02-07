defmodule Binary do
  @doc """
  Convert a string containing a binary number to an integer.

  On errors returns 0.
  """
  @spec to_decimal(String.t()) :: non_neg_integer
  def to_decimal(string) do
    n_places = String.length(string)

    string
    |> String.graphemes
    |> Enum.reduce({:next, 0, n_places}, fn
      "1", {:next, sum, n} -> {:next, (sum + pow(2, n-1)), (n-1)}
      "0", {:next, sum, n} -> {:next, sum, (n-1)}
       _ , _               -> {:err}
    end)
    |> case do
      {:next, converted, _} -> converted
      {:err} -> 0
    end
  end

  # Integer power function
  def  pow(n, k), do: pow(n, k, 1)        
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end
