defmodule Queens do
  alias Queens, as: Q

  @type t :: %Queens{black: {integer, integer}, white: {integer, integer}}
  defstruct black: {7,3},
            white: {0,3}

  @board_size 8

  defguard is_coordinate(coordinate) 
    when is_tuple(coordinate) 
    and tuple_size(coordinate) == 2
    and (elem(coordinate, 0) |> is_integer)
    and (elem(coordinate, 1) |> is_integer)

  defguard unique_coordinates(coord_a, coord_b) when coord_a != coord_b

  @doc """
  Creates a new set of Queens
  """
  @spec new() :: Queens.t()
  @spec new({integer, integer}, {integer, integer}) :: Queens.t()
  def new(), do: %Q{}

  def new(position, position)
    when is_coordinate(position),
    do: raise ArgumentError

  def new(white, black) 
    when is_coordinate(white) 
    and is_coordinate(black) 
    and unique_coordinates(white, black), 
    do: %Q{white: white, black: black}


  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(queens) do
    generate_board()
    |> place_queen_on_board(queens.white, "W")
    |> place_queen_on_board(queens.black, "B")
    |> board_to_string
  end

  # make a list of lists representing a board
  defp generate_board do
    generate_row()
    |> List.duplicate(@board_size)
    |> Enum.zip(0..(@board_size - 1))
  end

  # Make a row
  defp generate_row do
    "_"
    |> List.duplicate(@board_size)
    |> Enum.zip(0..(@board_size - 1))
  end

  # place the letter representing the Queen on the board
  defp place_queen_on_board(board, coordinate, letter) do
    board
    |> Enum.map(&do_row_place_queen_on_board(&1, coordinate, letter))
  end

  # on matching x coordinate, look to through the row
  defp do_row_place_queen_on_board({row, x}, coordinate = {x,_y}, letter) do
    updated_row = row
    |> Enum.map(&do_col_place_queen_on_board(&1, coordinate, letter))

    {updated_row, x}
  end
  defp do_row_place_queen_on_board(row, _coordinate, _letter), do: row

  # replace the string at the matching y coordinate with the letter inth tuple
  defp do_col_place_queen_on_board({_col, y}, {_x,y}, letter) do
    {letter, y}
  end
  defp do_col_place_queen_on_board(col, _coordinate, _letter), do: col

  # take the list of lists representing the board, and join them into a multiline string
  defp board_to_string(board) do
    board
    |> Enum.map_join("\n", fn {r, _} -> 
      r |> Enum.map_join(" ", fn {c, _} -> c end)
    end)
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(%Q{white: {x,_}, black: {x,_}}), do: true
  def can_attack?(%Q{white: {_,y}, black: {_,y}}), do: true
  def can_attack?(%Q{white: {x1,y1}, black: {x2, y2}}) do
    slope_x = (x2 - x1)
    slope_y = (y2 - y1)

    slope = slope_x / slope_y
    
    abs(slope) === 1.0
  end 
  
end
