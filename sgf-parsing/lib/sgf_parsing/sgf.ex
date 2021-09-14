defmodule SgfParsing.Sgf do
  defstruct properties: %{}, children: []

  @type t :: %__MODULE__{properties: map, children: [__MODULE__.t()]}
end
