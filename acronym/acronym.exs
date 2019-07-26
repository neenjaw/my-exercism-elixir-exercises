defmodule Acronym do
  @doc """
  Generate an acronym from a string.
  "This is a string" => "TIAS"
  """
  @spec abbreviate(String.t()) :: String.t()
  def abbreviate(string) do
    match_first_letter_or_capital = ~r/^\w|[A-Z]/u

    string
    |> String.split()
    |> Enum.map(&Regex.scan(match_first_letter_or_capital, &1))
    |> List.flatten()
    |> Enum.join()
    |> String.upcase()
  end
end
