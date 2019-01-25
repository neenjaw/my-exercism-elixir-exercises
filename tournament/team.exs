defmodule Team do
  @enforce_keys [:name]
  defstruct name: nil,
            wins: 0,
            loss: 0,
            draw: 0,
            points: 0,
            matches: 0

  @type t() :: %__MODULE__{
    name: String.t(),
    wins: integer(),
    loss: integer(),
    draw: integer(),
    points: integer(),
    matches: integer()
  }
end