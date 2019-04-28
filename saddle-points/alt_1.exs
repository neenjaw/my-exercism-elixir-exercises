"""
Created by numberMumbler on exercism.io

Appreciated the use of the list comprehension
"""

defmodule SaddlePoints do
  @doc """
  Parses a string representation of a matrix
  to a list of rows
  """
  @spec rows(String.t()) :: [[integer]]
  def rows(str) do
    str
    |> String.split("\n")
    |> Enum.map(&String.split/1)
    |> Enum.map(fn values -> Enum.map(values, &String.to_integer/1) end)
  end

  @doc """
  Parses a string representation of a matrix
  to a list of columns
  """
  @spec columns(String.t()) :: [[integer]]
  def columns(str) do
    str
    |> rows()
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  @doc """
  Calculates all the saddle points from a string
  representation of a matrix
  """
  @spec saddle_points(String.t()) :: [{integer, integer}]
  def saddle_points(str) do
    row_maxes = rows(str) |> Enum.map(&Enum.max/1)
    col_mins = columns(str) |> Enum.map(&Enum.min/1)

    for row_value <- Enum.with_index(row_maxes),
        col_value <- Enum.with_index(col_mins),
        elem(row_value, 0) == elem(col_value, 0) do
      {elem(row_value, 1), elem(col_value, 1)}
    end
  end
end
