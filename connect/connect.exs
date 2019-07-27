defmodule Connect.Board do
  @moduledoc """
  A submodules for Connect which is a struct that represents the
  board of a HexConnect game.

  The 'mapset' attribute stores each space of the board as a tuple:
  {space_content, x_position, y_position}
  """

  @enforce_keys [:mapset, :height, :width]
  defstruct [:mapset, :height, :width]

  @type t :: %__MODULE__{
    mapset: MapSet.t(),
    height: pos_integer,
    width: pos_integer
  }

  @spec create([String.t()]) :: Connect.Board.t()
  def create(board_str_list) do
    width = board_str_list |> hd |> String.length
    height = length(board_str_list)

    board_map =
      board_to_map(board_str_list)

    board_tuple_list =
      for col <- 0..(width - 1),
          row <- 0..(height - 1)
      do
        {board_map[row][col], col, row}
      end

    board_mapset =
      MapSet.new(board_tuple_list)

    %Connect.Board{mapset: board_mapset, height: height, width: width}
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
end

defmodule Connect do
  alias Connect.Board, as: Board

  # @blank ?.
  @white ?O
  @black ?X
  @teams [@black, @white]

  @doc """
  Calculates the winner (if any) of a board
  using ?O as the white player
  and ?X as the black player
  """
  @spec result_for([String.t()]) :: :none | :black | :white
  def result_for(board) do
    board
    |> Board.create()
    |> check_teams_for_result(@teams)
  end

  @doc """
  Check the result for each team on the board given the %Connect.Board{} and list
  of teams supplied.
  """
  def check_teams_for_result(_board_mapset, []), do: :none

  def check_teams_for_result(board = %Board{}, [team | teams]) do
    with {:ok, team_mapset}             <- filter_mapset_for_team(board.mapset, team),
         {:ok, starting_points}         <- filter_starting_points_to_list(team_mapset, team),
         {:function, fn_traverse_done?} <- {:function, get_traverse_done_fn(board, team)},
         {:traverse, true}              <- {:traverse, traverse_possible?(team_mapset, starting_points, fn_traverse_done?)}
    do
      case team do
        @white -> :white
        @black -> :black
      end
    else
      {:no_starting_points, _e} ->
        check_teams_for_result(board, teams)

      {:traverse, false} ->
        check_teams_for_result(board, teams)
    end
  end

  @doc """
  Take the current option as the starting point for the next step in the path from
  the start to the end, if the traversal is complete in `do_traverse_possible?/3`
  if it is, then return the result, if not try the alternatives, if alternatives
  exhausted then no traversal is possible by this path, so return false
  """
  def traverse_possible?(_, [], _), do: false
  def traverse_possible?(team_mapset, [point | alternate_points], fn_traverse_done?) do
    mapset_without_current =
      MapSet.delete(team_mapset, point)

    result =
      do_traverse_possible?(mapset_without_current, point, fn_traverse_done?)

    case result do
      false ->
        traverse_possible?(team_mapset, alternate_points, fn_traverse_done?)

      _ ->
        true
    end
  end

  def do_traverse_possible?(mapset, current, fn_traverse_done?) do
    with {:traverse_done, false}     <- {:traverse_done, fn_traverse_done?.(current)},
         {:ok, next_points}           <- find_next_points(mapset, current)
    do
      traverse_possible?(mapset, next_points, fn_traverse_done?)
    else
      {:traverse_done, true} -> true

      {:no_path, _} -> false
    end
  end

  @doc """
  Filter a MapSet for a specific team
  """
  def filter_mapset_for_team(mapset, team) do
    team_mapset =
      mapset
      |> Enum.filter(fn
        {^team, _, _} -> true
        _team_point  -> false
      end)
      |> MapSet.new()

    {:ok, team_mapset}
  end

  @doc """
  Filter the MapSet of points to a list of starting points depending
  on which team is supplied to the function.

  For white, all points which are on the first row (y index of 0) are returned

  For black, all points which are on the first column (x index of 0) are returned
  """
  def filter_starting_points_to_list(mapset, team) do
    starting_points =
      do_filter_starting_points(MapSet.to_list(mapset), team)

    case starting_points do
      [] -> {:no_starting_points, "Team '#{[team]}' doesn't have any starting points"}
      _  -> {:ok, starting_points}
    end
  end

  defp do_filter_starting_points(points, team, list \\ [])
  defp do_filter_starting_points([], _, list), do: list

  # @white team starting points
  defp do_filter_starting_points([point = {@white, _, 0} | rest], @white, list),
    do: do_filter_starting_points(rest, @white, [point | list])

  defp do_filter_starting_points([_point | rest], @white, list),
    do: do_filter_starting_points(rest, @white, list)

  # @black team starting points
  defp do_filter_starting_points([point = {@black, 0, _} | rest], @black, list),
    do: do_filter_starting_points(rest, @black, [point | list])

  defp do_filter_starting_points([_point | rest], @black, list),
    do: do_filter_starting_points(rest, @black, list)

  @doc """
  Return an anonymous function with allows you to check if a point is
  at the end based on the team.
  """
  def get_traverse_done_fn(board = %Board{}, @white) do
    last_row_index = board.height - 1

    fn
      {@white, _x, ^last_row_index} -> true
      _board_position_tuple        -> false
    end
  end

  def get_traverse_done_fn(board = %Board{}, @black) do
    last_col_index = board.width - 1

    fn
      {@black, ^last_col_index, _y} -> true
      _board_position_tuple        -> false
    end
  end

  @index_mutations_for_lookaround [{-1,0}, {-1,1}, {0,-1}, {0,1}, {1,-1}, {1,0}]

  # Get the next adjacent space or else return error
  #
  # In the MapSet, {team,x,y} is connected to:
  # previous row: {team, x-1, y},   {team, x-1, y+1},
  # current row:  {team, x,   y-1}, {team, x,   y+1},
  # next row:     {team, x+1, y-1}, {team, x+1, y}
  defp find_next_points(mapset, _current = {team, x, y}) do
    @index_mutations_for_lookaround
    |> Enum.map(fn {a, b} -> {team, x+a, y+b} end)
    |> Enum.filter(fn point -> MapSet.member?(mapset, point) end)
    |> case do
      [] -> {:no_path, "There is no path for '#{[team]}' from {#{x}, #{y}} to another point"}
      points -> {:ok, points}
    end
  end
end

# Was using this module for debugging in iex
defmodule MyTest do
  def remove_spaces(rows) do
    Enum.map(rows, &String.replace(&1, " ", ""))
  end

  def x() do
    [
      ". X X . .",
      " X . X . X",
      "  . X . X .",
      "   . X X . .",
      "    O O O O O"
    ]
    |> remove_spaces()
    |> Connect.result_for()
  end
end
