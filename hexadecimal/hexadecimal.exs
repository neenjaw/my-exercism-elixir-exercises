defmodule Hexadecimal do
  @doc """
    Accept a string representing a hexadecimal value and returns the
    corresponding decimal value.
    It returns the integer 0 if the hexadecimal is invalid.
    Otherwise returns an integer representing the decimal value.

    ## Examples

      iex> Hexadecimal.to_decimal("invalid")
      0

      iex> Hexadecimal.to_decimal("af")
      175

  """

  @map_hex_to_dec %{
    "0" => 0,
    "1" => 1,
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "A" => 10,
    "B" => 11,
    "C" => 12,
    "D" => 13,
    "E" => 14,
    "F" => 15,
  }

  @spec to_decimal(String.t()) :: integer
  def to_decimal(hex) do
    grapheme_list = hex
    |> String.upcase
    |> String.graphemes

    grapheme_list
    |> Stream.zip((length(grapheme_list)-1)..0)
    |> Stream.map(fn {char, place} -> {Map.fetch(@map_hex_to_dec, char), place} end)
    |> Stream.map(fn 
      {:error, _} -> :error
      {{:ok, value}, place} -> value * pow(16, place)
    end)
    |> Enum.reduce(0, fn
      :error, _acc -> :error
      value,  acc  -> value + acc
    end)
    |> case do
      :error -> 0
      v -> v
    end 
  end

  defp pow(_v, 0), do: 1
  defp pow(v, p) when p > 0 do
    v * pow(v, p-1)
  end
end
