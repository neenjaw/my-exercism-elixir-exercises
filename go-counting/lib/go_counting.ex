defmodule GoCounting do
  @type position :: {integer, integer}
  @type owner :: %{owner: atom, territory: [position]}
  @type territories :: %{white: [position], black: [position], none: [position]}

  alias GoCounting.Board
  alias GoCounting.Territory

  require Territory

  @doc """
  Return the owner and territory around a position
  """
  @spec territory(board :: String.t(), position :: position) ::
          {:ok, owner} | {:error, String.t()}
  def territory(board, {_x, _y} = pos) do
    result =
      board
      |> Board.decode()
      |> search(pos)

    case result do
      {:error, _} = error ->
        error

      {:ok, territory} ->
        {:ok, Territory.format(territory)}
    end
  end

  @doc """
  Return all white, black and neutral territories
  """
  @spec territories(board :: String.t()) :: territories
  def territories(board) do
    board =
      board
      |> Board.decode()

    all_positions =
      board
      |> Board.all_positions()

    {:ok, all_territories} = search_all_positions(board, all_positions)

    formatted_territories = Enum.map(all_territories, &Territory.format/1)

    %{
      white: find_territories(formatted_territories, :white),
      black: find_territories(formatted_territories, :black),
      none: find_territories(formatted_territories, :none)
    }
  end

  @spec find_territories(list(owner()), atom()) :: list(position)
  defp find_territories(formatted_territories, color) do
    formatted_territories
    |> Enum.reduce([], fn formatted_territory, acc ->
      if formatted_territory.owner == color do
        acc ++ formatted_territory.territory
      else
        acc
      end
    end)
    |> Enum.sort()
  end

  defp search_all_positions(board, positions), do: search_all_positions(board, positions, [])

  defp search_all_positions(board, [position | next_positions], found_territories) do
    case search(board, position) do
      {:error, _} ->
        search_all_positions(board, next_positions, found_territories)

      {:ok, territory} ->
        next_positions = next_positions -- Territory.get_positions(territory)
        search_all_positions(board, next_positions, [territory | found_territories])
    end
  end

  defp search_all_positions(_board, [], territories), do: {:ok, territories}

  defp search(%Board{} = board, pos) do
    cond do
      not Board.valid_position?(board, pos) -> {:error, "Invalid coordinate"}
      true -> do_search(board, [pos])
    end
  end

  defp do_search(board, positions_to_visit) do
    do_search(board, %Territory{}, positions_to_visit, MapSet.new())
  end

  defp do_search(%Board{} = board, %Territory{} = territory, [position | next_positions], visited) do
    visited = MapSet.put(visited, position)

    case Board.position_type(board, position) do
      :error ->
        do_search(board, territory, next_positions, visited)

      :blank ->
        territory = Territory.add_position(territory, position)
        next_positions = get_next_positions(position, next_positions, visited)
        do_search(board, territory, next_positions, visited)

      type when type in ~w[white black]a and Territory.is_empty(territory) ->
        {:ok, territory}

      type when type in ~w[white black]a ->
        territory = Territory.add_bordering_color(territory, type)
        do_search(board, territory, next_positions, visited)
    end
  end

  defp do_search(_board, %Territory{} = territory, [], _visited) do
    {:ok, territory}
  end

  defp get_next_positions({x, y}, next_positions, visited) do
    for dx <- -1..1,
        dy <- -1..1,
        abs(dx) != abs(dy),
        x = x + dx,
        y = y + dy,
        point = {x, y},
        not MapSet.member?(visited, point) do
      point
    end
    |> Kernel.++(next_positions)
    |> MapSet.new()
    |> MapSet.difference(visited)
    |> MapSet.to_list()
  end
end
