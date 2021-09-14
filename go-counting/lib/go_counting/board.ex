defmodule GoCounting.Board do
  @enforce_keys [:range_x, :range_y, :grid]
  defstruct [:range_x, :range_y, :grid]

  @black ?B
  @white ?W
  @blank ?_

  def decode(board) do
    grid =
      board
      |> String.split("\n", trim: true)
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {cell, x} -> {{x, y}, cell} end)
      end)
      |> Enum.into(%{})

    %__MODULE__{
      range_y: get_range(grid, fn {_, y} -> y end),
      range_x: get_range(grid, fn {x, _} -> x end),
      grid: grid
    }
  end

  def valid_position?(%__MODULE__{} = board, {_x, _y} = pos) do
    not is_nil(board.grid[pos])
  end

  def position_type(%__MODULE__{} = board, {_x, _y} = pos) do
    case board.grid[pos] do
      nil -> :error
      @black -> :black
      @white -> :white
      @blank -> :blank
    end
  end

  def all_positions(%__MODULE__{} = board) do
    Map.keys(board.grid)
  end

  defp get_range(grid, selector) do
    grid
    |> Map.keys()
    |> Enum.map(selector)
    |> Enum.max()
    |> (&Range.new(0, &1)).()
  end
end
