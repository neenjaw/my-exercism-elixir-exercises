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

    row_max_values = get_row_maximums(matrix_rows)
    column_min_values = get_column_minimums(matrix_columns)

    # Take the row maximums, then keep only those that match column minimums
    row_max_values
    |> Enum.filter(fn [max: v, row: r, column: c] -> 
      # if there is a pattern match to pinned values, return a true for a saddlepoint
      Enum.any?(column_min_values, fn 
        [min: ^v, row: ^r, column: ^c] -> true
        _                              -> false 
      end)
    end)
    # Format the saddle points
    |> Enum.map(fn [max: _, row: r, column: c] -> {r, c} end)
    # Order them by increasing matrix positions
    |> Enum.sort()
  end

  defp get_row_maximums(matrix) do
    find_matching_values_by_row(matrix, :max, &Enum.max/1)
  end

  defp get_column_minimums(matrix) do
    find_matching_values_by_row(matrix, :min, &Enum.min/1)
    # transpose the columns and row labels since we are working with a transposed matrix
    |> Enum.map(fn [min: m, row: r, column: c] -> [min: m, row: c, column: r] end)
  end

  # Find matching row values based on the passed in function, place in a key-value list
  defp find_matching_values_by_row(matrix, label \\ :match, match_fx) do
    matrix
    |> Stream.zip(get_index_stream)
    |> Enum.reduce([], fn {row_values, row_idx}, acc -> 
    # Format the saddle points
      match_value = 
      # Order them by increasing matrix positions
        row_values
        |> match_fx.()

      # Based on the found match_value, look for more matches
      row_values
      |> Stream.zip(get_index_stream)
      |> Enum.reduce([], fn 
        {^match_value, column_idx}, match_acc -> [([{label, match_value}] ++ [row: row_idx, column: column_idx]) | match_acc]
        _,                          match_acc -> match_acc
      end)
      |> Kernel.++(acc)
    end)
  end

  # Return a stream of indexes for zipping.
  defp get_index_stream() do
    Stream.iterate(0, &(&1 + 1))
  end
end
