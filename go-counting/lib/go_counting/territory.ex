defmodule GoCounting.Territory do
  defstruct positions: MapSet.new(), bordering_colors: MapSet.new()

  def new(), do: %__MODULE__{}

  @empty_positions MapSet.new()

  defguard is_empty(territory)
           when is_struct(territory, __MODULE__) and
                  territory.positions == @empty_positions

  def add_position(%__MODULE__{} = territory, {_x, _y} = position) do
    %{territory | positions: MapSet.put(territory.positions, position)}
  end

  @colors ~w[black white]a
  def add_bordering_color(%__MODULE__{} = territory, color) when color in @colors do
    %{territory | bordering_colors: MapSet.put(territory.bordering_colors, color)}
  end

  def get_positions(%__MODULE__{} = territory) do
    territory.positions |> MapSet.to_list()
  end

  def format(%__MODULE__{bordering_colors: colors, positions: positions}) do
    color =
      if MapSet.size(colors) == 1 do
        colors |> MapSet.to_list() |> hd()
      else
        :none
      end

    %{owner: color, territory: MapSet.to_list(positions)}
  end
end
