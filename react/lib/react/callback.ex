defmodule React.Callback do
  @enforce_keys [:name, :trigger, :callback]
  defstruct [:name, :trigger, :callback]

  @type t :: %__MODULE__{
          name: String.t(),
          trigger: String.t(),
          callback: fun()
        }

  def new(name, trigger, callback) do
    %__MODULE__{name: name, trigger: trigger, callback: callback}
  end
end
