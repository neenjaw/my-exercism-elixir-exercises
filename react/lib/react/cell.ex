defprotocol React.Cell do
  @spec set(Cell.t(), value :: any()) :: Cell.t()
  def set(cell, value)

  @type input_value_map :: %{required(String.t()) => any()}

  @spec update(Cell.t(), input_values :: input_value_map()) :: Cell.t()
  def update(cell, input_values)

  @spec value(Cell.t()) :: any()
  def value(cell)

  @spec get_inputs(Cell.t()) :: list(String.t())
  def get_inputs(cell)
end
