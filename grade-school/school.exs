defmodule School do
  @moduledoc """
  Simulate students in a school.

  Each student is in a grade.
  """

  @doc """
  Add a student to a particular grade in school.
  """
  @spec add(map, String.t(), integer) :: map
  def add(db, name, grade) do
    {_, result_map} =
      Map.get_and_update(db, grade, fn
        nil          -> {nil, [name]}
        student_list -> {student_list, Enum.sort([name | student_list])}
      end)

    result_map
  end

  @doc """
  Return the names of the students in a particular grade.
  """
  @spec grade(map, integer) :: [String.t()]
  def grade(db, grade) do
    Map.get(db, grade, [])
  end

  @doc """
  Sorts the school by grade and name.
  """
  @spec sort(map) :: [{integer, [String.t()]}]
  def sort(db) do
    Map.keys(db)
    |> Enum.sort
    |> Enum.map(fn k -> {k, Map.get(db, k)} end)
  end
end
