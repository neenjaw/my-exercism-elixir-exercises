defmodule Spiral do
  @doc """
  Given the dimension, return a square matrix of numbers in clockwise spiral order.
  """
  @spec matrix(dimension :: integer) :: list(list(integer))
  def matrix(0), do: []
  def matrix(1), do: [[1]]
  def matrix(dimension) do
    # Create a range of all the numbers to fill the spiral
    range =
      1..(dimension*dimension)

    # Create a list that counts down each side until it turns
    side_counts =
      (dimension - 1)..1
      |> Enum.flat_map(fn n -> [n, n] end)
      |> (fn l -> [dimension | l] end).()
      |> Enum.flat_map(fn side -> side..1 |> Enum.to_list() end)

    # Create the spiral matrix in the following steps
    # 1) make a tuple of the range and counts
    Enum.zip(range, side_counts)

    # 2) Enumerate the list, adding a coordinate to the tuple based on the previous element
    |> Enum.scan(:start, &add_coordinate/2)
    |> Enum.map(fn {e, _dir, _turn} -> e end)

    # 3) Group by the y coordinate, which returns a map
    |> Enum.group_by(&group_by_y_position/1, &drop_y_position/1)
    |> Map.to_list()

    # 4) for each row, order the row elements by x coordinate, then discard it.
    |> Enum.map(fn {_row, row_elements} ->
      row_elements
      |> Enum.sort_by(fn {_e, x} -> x end, &<=/2)
      |> Enum.map(fn {e, _x} -> e end)
    end)

    # 5) Final result is returned
  end

  defp add_coordinate({e, _count_down}, :start) do
    spiral_turns =
      [:down, :left, :up, :right]
      |> Stream.cycle()

    {{e, {0, 0}}, :right, spiral_turns}
  end

  defp add_coordinate({e, 1}, {{_, prev_coord}, direction, spiral_turns}) do
    next_direction =
      spiral_turns
      |> Stream.take(1)
      |> Enum.to_list()
      |> List.first()

    next_turns =
      spiral_turns
      |> Stream.drop(1)

    {{e, calc_coord(prev_coord, direction)}, next_direction, next_turns}
  end

  defp add_coordinate({e, _count_down}, {{_, prev_coord}, direction, spiral_turns}) do
    {{e, calc_coord(prev_coord, direction)}, direction, spiral_turns}
  end

  defp calc_coord({x,y}, :right), do: {x+1, y}
  defp calc_coord({x,y}, :down),  do: {x,   y+1}
  defp calc_coord({x,y}, :left),  do: {x-1, y}
  defp calc_coord({x,y}, :up),    do: {x,   y-1}

  defp group_by_y_position({_e, {_x, y}}), do: y

  defp drop_y_position({e, {x, _y}}), do: {e, x}
end
