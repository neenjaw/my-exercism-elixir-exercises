defmodule React.Cell.Output do
  @enforce_keys [:name, :inputs, :function, :value]
  defstruct [:name, :inputs, :function, :value]

  @type t :: %__MODULE__{
          name: String.t(),
          inputs: list(String.t()),
          function: fun(),
          value: any()
        }

  def new({:output, name, inputs, function}) do
    %__MODULE__{name: name, inputs: inputs, function: function, value: :undefined}
  end

  alias React.Cell

  defimpl Cell, for: __MODULE__ do
    def set(cell, _value), do: cell

    def update(cell, input_values) do
      inputs = Enum.map(cell.inputs, &Map.fetch!(input_values, &1))

      %{cell | value: apply(cell.function, inputs)}
    end

    def value(cell), do: cell.value
    def get_inputs(cell), do: cell.inputs
  end
end
