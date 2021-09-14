defmodule React.Cell.Input do
  @enforce_keys [:name, :value]
  defstruct [:name, :value]

  @type t :: %__MODULE__{
          name: String.t(),
          value: any()
        }

  def new({:input, name, value}) do
    %__MODULE__{name: name, value: value}
  end

  alias React.Cell

  defimpl Cell, for: __MODULE__ do
    def set(cell, value), do: %{cell | value: value}
    def update(cell, _input_map), do: cell
    def value(cell), do: cell.value
    def get_inputs(_cell), do: []
  end
end
