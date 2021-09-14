defmodule React.Registry do
  defstruct cells: %{}, callbacks: %{}, cell_deps: %{}, callback_deps: %{}

  alias React.Cell
  alias React.Cell.Input, as: InputCell
  alias React.Cell.Output, as: OutputCell
  alias React.Callback

  def new(cell_definitions) do
    registry = Enum.reduce(cell_definitions, %__MODULE__{}, &add_cell(&2, &1))

    inputs =
      registry.cells
      |> Enum.map(&elem(&1, 1))
      |> Enum.filter(&(Cell.get_inputs(&1) === []))
      |> Enum.map(& &1.name)

    registry
    |> propagate_value(inputs)
  end

  def add_cell(registry = %__MODULE__{}, {:input, _, _} = serialized_cell) do
    cell = InputCell.new(serialized_cell)

    do_add_cell(registry, cell)
  end

  def add_cell(registry = %__MODULE__{}, {:output, _, inputs, _} = serialized_cell)
      when is_list(inputs) do
    cell = OutputCell.new(serialized_cell)

    do_add_cell(registry, cell)
  end

  defp do_add_cell(registry = %__MODULE__{}, cell) do
    %{
      registry
      | cells: Map.put(registry.cells, cell.name, cell),
        cell_deps:
          Enum.reduce(
            Cell.get_inputs(cell),
            registry.cell_deps,
            fn input, cell_deps ->
              Map.update(cell_deps, input, [cell.name], &[cell.name | &1])
            end
          )
    }
  end

  def add_callback(registry = %__MODULE__{}, name, trigger, callback) do
    callback = Callback.new(name, trigger, callback)

    %{
      registry
      | callbacks: Map.put(registry.callbacks, callback.name, callback),
        callback_deps:
          Map.update(registry.callback_deps, trigger, [callback.name], &[callback.name | &1])
    }
  end

  def remove_callback(registry = %__MODULE__{}, cell_name, callback_name) do
    if registry.callbacks[callback_name] do
      %{
        registry
        | callbacks: Map.delete(registry.callbacks, callback_name),
          callback_deps:
            Map.update(
              registry.callback_deps,
              cell_name,
              [],
              &List.delete(&1, callback_name)
            )
      }
    else
      registry
    end
  end

  def get_value(registry = %__MODULE__{}, name) do
    registry.cells[name].value
  end

  def set_value(registry = %__MODULE__{}, name, value) do
    %{
      registry
      | cells: %{registry.cells | name => Cell.set(registry.cells[name], value)}
    }
    |> propagate_value([name])
  end

  defp propagate_value(registry, updated_cells, callbacks_to_notify \\ MapSet.new())

  defp propagate_value(
         registry = %__MODULE__{},
         [updated_cell | other_updated_cells],
         callbacks_to_notify
       ) do
    updated_dependent_cells =
      registry.cell_deps[updated_cell]
      |> Kernel.||([])
      |> Enum.map(&registry.cells[&1])
      |> Enum.map(fn cell ->
        input_values =
          Cell.get_inputs(cell)
          |> Enum.map(&{&1, registry.cells[&1] |> Cell.value()})
          |> Enum.into(%{})

        Cell.update(cell, input_values)
      end)

    changed_dependent_cells =
      updated_dependent_cells
      |> Enum.filter(fn cell ->
        Cell.value(cell) != Cell.value(registry.cells[cell.name])
      end)

    updated_registry =
      changed_dependent_cells
      |> Enum.reduce(registry, fn cell, registry ->
        %{
          registry
          | cells: %{registry.cells | cell.name => cell}
        }
      end)

    next_cells_to_update =
      changed_dependent_cells
      |> Enum.map(& &1.name)
      |> Kernel.++(other_updated_cells)
      |> Enum.uniq()

    updated_callbacks_to_notify =
      changed_dependent_cells
      |> Enum.reduce(callbacks_to_notify, fn cell, callbacks_to_notify ->
        registry.callback_deps[cell.name]
        |> Kernel.||([])
        |> Enum.reduce(callbacks_to_notify, &MapSet.put(&2, &1))
      end)

    propagate_value(updated_registry, next_cells_to_update, updated_callbacks_to_notify)
  end

  defp propagate_value(registry = %__MODULE__{}, [], callbacks_to_notify) do
    callbacks_to_notify
    |> Enum.map(&registry.callbacks[&1])
    |> Enum.each(fn callback ->
      callback.callback.(callback.name, registry.cells[callback.trigger].value)
    end)

    registry
  end
end
