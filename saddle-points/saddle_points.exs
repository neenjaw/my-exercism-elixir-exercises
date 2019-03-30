defmodule Matrix do
  @doc """
  Parses an integer matrix from a string representation.
    "\n" delimits each matrix row
    " "  delimits each matrix column

  This does not check for unequal rows/columns
  """
  def parse(str) do
    row_delimiter = "\n"
    column_delimiter = " "

    # Split the string into rows
    str
    |> String.split(row_delimiter)
    |> Enum.map(fn str_row -> 
      # Split each row to columns and convert to integer
      str_row
      |> String.split(column_delimiter)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  @doc """
  Take a matrix and transpose row -> columns, columns -> rows
  """
  def transpose(matrix) when is_list(matrix) do
    matrix
    |> Enum.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule SaddlePoints do
  @doc """
  Parses a string representation of a matrix
  to a list of rows
  """
  @spec rows(String.t()) :: [[integer]]
  def rows(str) do
    # Get the matrix in the row-dominant form
    str 
    |> Matrix.parse
  end

  @doc """
  Parses a string representation of a matrix
  to a list of columns
  """
  @spec columns(String.t()) :: [[integer]]
  def columns(str) do
    # Get the matrix in row-dominant form
    str
    |> Matrix.parse
    |> Matrix.transpose
  end

  @doc """
  Calculates all the saddle points from a string
  representation of a matrix
  """
  @spec saddle_points(String.t()) :: [{integer, integer}]
  def saddle_points(str) do
    matrix_rows = Matrix.parse(str)
    matrix_columns = Matrix.transpose(matrix_rows)

    row_max_coordinates = 
      matrix_rows
      |> find_row_maximums
      |> filter_matrix_to_match_coordinates

    column_min_coordinates = 
      matrix_columns
      |> find_column_minimums
      |> filter_matrix_to_match_coordinates
      |> Enum.map(fn {v, column_index, row_index} -> {v, row_index, column_index} end)

    for coordinate = {_, x, y} <- row_max_coordinates,
        (coordinate in column_min_coordinates) do
      {x, y}
    end
    |> Enum.sort()
  end

  defp find_row_maximums(matrix) do
    Enum.map(matrix, fn row -> {Enum.max(row), row} end)
  end

  defp find_column_minimums(matrix) do
    Enum.map(matrix, fn column -> {Enum.min(column), column} end)
  end

  def filter_matrix_to_match_coordinates(row_match_tuple, row_index \\ 0, acc \\ [])
  def filter_matrix_to_match_coordinates([], _, acc), do: acc
  def filter_matrix_to_match_coordinates([{match, row} | next], row_index, acc) do
    next_acc = 
      row
      |> Stream.zip(get_index_stream())
      |> Stream.filter(fn {value, _} -> value == match end)
      |> Stream.map(fn {v, column_index} -> {v, row_index, column_index} end)
      |> Enum.to_list()
      |> Kernel.++(acc)

    filter_matrix_to_match_coordinates(next, row_index+1, next_acc)
  end 

  # Return a stream of indexes for zipping.
  defp get_index_stream() do
    Stream.iterate(0, &(&1 + 1))
  end
end
