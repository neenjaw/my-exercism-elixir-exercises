defmodule Binary do
  @doc """
  Convert a string containing a binary number to an integer.

  On errors returns 0.
  """
  @spec to_decimal(String.t()) :: non_neg_integer
  def to_decimal(string) do
    string
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce_while(0, fn
      {"1",  n} , sum -> {:cont, (sum + pow(2, n))}
      {"0", _n} , sum -> {:cont, sum}
       _ , _          -> {:halt, 0}
    end)
  end

  # Integer power function
  defp  pow(n, k), do: pow(n, k, 1)
  defp pow(_, 0, acc), do: acc
  defp pow(n, k, acc), do: pow(n, k - 1, n * acc)
end
