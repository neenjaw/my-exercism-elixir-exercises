defmodule Minesweeper do
  @mine_char ?*
  @annotate_char ?\s

  @doc """
  Annotate empty spots next to mines with the number of mines next to them.
  """
  @spec annotate([String.t()]) :: [String.t()]
  def annotate([]), do: []
  def annotate(board) do
    height = length(board)
    width = board |> hd |> String.length

    # build a multi-dimensional map of the board to facilitate access/traversal
    board_map = board_to_map(board)

    # get the list of spaces to annotate
    spaces_to_annotate =
      for row    <- 0..(height-1),
          column <- 0..(width-1),
          board_map[row][column] == @annotate_char
      do
        {row, column}
      end

    # for each space, count the mines around it and put it in the map
    annotated_board_map =
      spaces_to_annotate
      |> Enum.reduce(board_map, fn {row, column}, map ->
        mine_count =
          map
          |> lookaround_sum({height, width}, {row, column})
          |> case do
            # If no mine, then don't place a number
            0 -> @annotate_char

            # place the sum of adjacent mines in the location
            sum ->
              sum
              |> Integer.to_char_list()
              |> List.first()
          end


        put_in(map[row][column], mine_count)
      end)

    # format the map to be returned
    annotated_board_map
    |> Map.to_list()
    |> Enum.sort()
    |> Enum.map(fn {_row, row_map} ->
      row_map
      |> Map.to_list()
      |> Enum.sort()
      |> Enum.map(fn {_col, col_val} -> col_val end)
      |> to_string()
    end)
  end

  @doc """
  Take a list of lists or a list of strings and convert it into a
  multidimensional map to take advantage of the Access functions
  """
  def board_to_map(rows, map \\ %{}, index \\ 0)

  def board_to_map([], map, _index), do: map

  def board_to_map([h|t], map, index) when is_binary(h) do
    h = to_charlist(h)

    board_to_map([h|t], map, index)
  end

  def board_to_map([h|t], map, index) do
    map = Map.put(map, index, board_to_map(h))

    board_to_map(t, map, index + 1)
  end

  def board_to_map(other, _, _), do: other

  @doc """
  Look around a position on the board and sum the number of mines surrounding
  """
  def lookaround_sum(map, {height, width}, {row, column}) do
    lookaround_coordinates =
      get_lookaround({row, column})

    lookaround_coordinates
    |> Enum.filter_map(&valid_coordinate?(&1, {height, width}), &mine?(map, &1))
    |> Enum.sum()
  end

  @doc """
  Builds a list of positions that look around the submitted position
  """
  def get_lookaround(position, current \\ :up_left, coordinates \\ [])

  def get_lookaround(_position, :end, coordinates), do: coordinates

  def get_lookaround({r,c}, :up_left,    coordinates), do: get_lookaround({r,c}, :up,         [{r-1, c-1} | coordinates])
  def get_lookaround({r,c}, :up,         coordinates), do: get_lookaround({r,c}, :up_right,   [{r-1, c}   | coordinates])
  def get_lookaround({r,c}, :up_right,   coordinates), do: get_lookaround({r,c}, :right,      [{r-1, c+1} | coordinates])
  def get_lookaround({r,c}, :right,      coordinates), do: get_lookaround({r,c}, :down_right, [{r,   c+1} | coordinates])
  def get_lookaround({r,c}, :down_right, coordinates), do: get_lookaround({r,c}, :down,       [{r+1, c+1} | coordinates])
  def get_lookaround({r,c}, :down,       coordinates), do: get_lookaround({r,c}, :down_left,  [{r+1, c}   | coordinates])
  def get_lookaround({r,c}, :down_left,  coordinates), do: get_lookaround({r,c}, :left,       [{r+1, c-1} | coordinates])
  def get_lookaround({r,c}, :left,       coordinates), do: get_lookaround({r,c}, :end,        [{r,   c-1} | coordinates])

  @doc """
  Check if the position is within the bounds of the board
  """
  def valid_coordinate?({row, column}, {height, width}) do
    valid_row? =
      0 <= row and row < height

    valid_column? =
      0 <= column and column < width

    valid_row? and valid_column?
  end

  @doc """
  If the current position is a *, then return 1, if not return 0
  """
  def mine?(map, {row, column}) do
    if map[row][column] == @mine_char do
      1
    else
      0
    end
  end
end
