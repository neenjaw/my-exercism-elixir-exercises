defmodule Matrix do
  defstruct matrix: nil

  @doc """
  Convert an `input` string, with rows separated by newlines and values
  separated by single spaces, into a `Matrix` struct.
  """
  @spec from_string(input :: String.t()) :: %Matrix{}
  def from_string(input) do
    input
    |> String.split("\n")
    |> Enum.map(&(build_row(&1)))
  end

  defp build_row(row_string) do
    row_string
    |> String.split(" ")
    |> Enum.map(fn x -> String.to_integer(x) end)
  end

  @doc """
  Write the `matrix` out as a string, with rows separated by newlines and
  values separated by single spaces.
  """
  @spec to_string(matrix :: %Matrix{}) :: String.t()
  def to_string(matrix) do
    matrix
    |> Enum.reduce("", fn (x, acc) -> acc <> "\n" <> row_to_string(x) end)
    |> String.trim_leading()

  end

  defp row_to_string(row) do
    row
    |> Enum.reduce("", fn (x, acc) -> acc <> " " <> Integer.to_string(x) end)
    |> String.trim_leading()
  end

  @doc """
  Given a `matrix`, return its rows as a list of lists of integers.
  """
  @spec rows(matrix :: %Matrix{}) :: list(list(integer))
  def rows(matrix) do
    matrix
  end

  @doc """
  Given a `matrix` and `index`, return the row at `index`.
  """
  @spec row(matrix :: %Matrix{}, index :: integer) :: list(integer)
  def row(matrix, index) do
    matrix
    |> Enum.at(index)
  end

  @doc """
  Given a `matrix`, return its columns as a list of lists of integers.
  """
  @spec columns(matrix :: %Matrix{}) :: list(list(integer))
  def columns(matrix) do
    num_cols = matrix
    |> List.first()
    |> Enum.count()
    Enum.map(0..num_cols - 1, &(column(matrix, &1)))
  end

  @doc """
  Given a `matrix` and `index`, return the column at `index`.
  """
  @spec column(matrix :: %Matrix{}, index :: integer) :: list(integer)
  def column(matrix, index) do
    matrix
    |> Enum.map(&(Enum.at(&1, index)))
  end
end