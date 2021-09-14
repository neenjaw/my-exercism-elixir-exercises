defmodule SgfParsing do
  alias SgfParsing.Sgf
  alias SgfParsing.Lexer

  @doc """
  Parse a string into a Smart Game Format tree
  """
  @spec parse(encoded :: String.t()) :: {:ok, Sgf.t()} | {:error, String.t()}
  def parse(encoded) do
    Lexer.parse(encoded)
  end
end
