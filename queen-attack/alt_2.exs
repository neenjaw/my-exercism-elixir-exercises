# Solution by Chris Eyre
# Nice list comprehension and use of min_max for can_attack

defmodule Queens do
  @type t :: %Queens{black: {integer, integer}, white: {integer, integer}}
  defstruct black: nil, white: nil

  @doc """
  Creates a new set of Queens
  """
  @spec new() :: Queens.t()
  @spec new({integer, integer}, {integer, integer}) :: Queens.t()
  def new(white \\ {0, 3}, black \\ {7, 3}) do
    if white == black, do: raise ArgumentError
    %Queens{white: white, black: black}
  end

  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(queens) do
    for row <- 0..7, col <- 0..7, into: "" do
      "#{symbol(queens, row, col)}#{seperator(col)}"
    end
    |> String.trim()
  end

  defp symbol(%Queens{white: {r, c}}, r, c), do: "W"
  defp symbol(%Queens{black: {r, c}}, r, c), do: "B"
  defp symbol(_, _, _), do: "_"

  defp seperator(7), do: "\n"
  defp seperator(_), do: " "

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%Queens{white: {r, _wc}, black: {r, _bc}}) do
    true
  end

  def can_attack?(%Queens{white: {_wr, c}, black: {_br, c}}) do
    true
  end

  # Diagon Alley
  def can_attack?(%Queens{white: {a, b}, black: {c, d}}) do
    {maxr, minr} = Enum.min_max([a, c])
    {maxc, minc} = Enum.min_max([b, d])
    maxr - minr == maxc - minc
  end

  def can_attack?(_) do
    false
  end
end