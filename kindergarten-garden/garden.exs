defmodule Garden do
  @default_names [
    :alice,
    :bob,
    :charlie,
    :david,
    :eve,
    :fred,
    :ginny,
    :harriet,
    :ileana,
    :joseph,
    :kincaid,
    :larry
  ]

  @plant_map %{
    "V" => :violets,
    "R" => :radishes,
    "C" => :clover,
    "G" => :grass
  }

  @doc """
    Accepts a string representing the arrangement of cups on a windowsill and a
    list with names of students in the class. The student names list does not
    have to be in alphabetical order.

    It decodes that string into the various gardens for each student and returns
    that information in a map.
  """

  @spec info(String.t(), list) :: map
  def info(info_string, student_names \\ @default_names) do
    sorted_names = student_names |> Enum.sort

    # create an empty tuple for each name
    garden_map =
      sorted_names |> Enum.reduce(%{}, fn n, map -> Map.put(map, n, {}) end)

    # split the string by line, then parse each line
    info_string
    |> String.split("\n")
    |> Enum.reduce(garden_map, &parse_garden_row(&1, &2, sorted_names))
  end

  defp parse_garden_row(row, garden_map, names) do
    row
    |> String.graphemes
    |> Enum.chunk_every(2)
    |> Enum.zip(names)
    |> Enum.reduce(garden_map, &add_to_garden(&1, &2))
  end

  defp add_to_garden({pair, name}, garden_map) do
    pair
    |> Enum.reduce(garden_map, fn plant, gmap ->
      plant_atom = Map.get(@plant_map, plant)

      {_, result_map} =
        Map.get_and_update(gmap, name, fn
          nil -> {nil, {plant_atom}} # nil should never occur since the names were seeded
          student_plants -> {student_plants, Tuple.append(student_plants, plant_atom)}
        end)

      result_map
    end)
  end
end


