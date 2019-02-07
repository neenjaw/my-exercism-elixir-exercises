defmodule Binary do
  @doc """
  Convert a string containing a binary number to an integer.

  On errors returns 0.
  """
  @spec to_decimal(String.t) :: non_neg_integer
  def to_decimal(string) do
    if valid?(string) do
      String.codepoints(string)
      |> Enum.reverse
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index
      |> Enum.reduce(0,fn({num,index},acc) -> acc + (num * :math.pow(2,index)) end)
    else
      0
    end
  end

  defp valid?(string) do
    Regex.run(~r/[^01]/,string) == nil
  end
end