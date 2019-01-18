defmodule Raindrops do
  @factors [3,5,7]
  @messages %{
    3 => 'Pling',
    5 => 'Plang',
    7 => 'Plong'
    }

  @doc """
  Returns a string based on raindrop factors.

  - If the number contains 3 as a prime factor, output 'Pling'.
  - If the number contains 5 as a prime factor, output 'Plang'.
  - If the number contains 7 as a prime factor, output 'Plong'.
  - If the number does not contain 3, 5, or 7 as a prime factor,
    just pass the number's digits straight through.
  """
  @spec convert(pos_integer) :: String.t()
  def convert(number) do
  @factors
  |> Enum.filter(&(Integer.mod(number, &1) == 0))
  |> Enum.map(&Map.get(@messages, &1))
  |> Enum.join()
  |> (fn
      ""  -> Integer.to_string(number)
      str -> str
    end).()
  end
end
