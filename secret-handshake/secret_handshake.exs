defmodule SecretHandshake do
  import Bitwise
  @doc """
  Determine the actions of a secret handshake based on the binary
  representation of the given `code`.

  If the following bits are set, include the corresponding action in your list
  of commands, in order from lowest to highest.

  1 = wink
  10 = double blink
  100 = close your eyes
  1000 = jump

  10000 = Reverse the order of the operations in the secret handshake
  """
  @spec commands(code :: integer) :: list(String.t())
  def commands(code) do
    # each function performs bitwise and with 1 to test if the bit is set
    # successive calls user bitwise shift to isolate the correct bit to test
    # wink       = ((code &&& 1) == 1)
    # blink      = (((code >>> 1) &&& 1) == 1)
    # close_eyes = (((code >>> 2) &&& 1) == 1)
    # jump       = (((code >>> 3) &&& 1) == 1)
    # reverse    = (((code >>> 4) &&& 1) == 1)

    []
    |> wink?(code)
    |> blink?(code)
    |> close_eyes?(code)
    |> jump?(code)
    |> reverse?(code)
  end

  defp wink?(actions, code) when ((code &&& 1) == 1), do: Enum.concat(actions, ["wink"])
  defp wink?(actions, _code), do: actions

  defp blink?(actions, code) when (((code >>> 1) &&& 1) == 1), do: Enum.concat(actions, ["double blink"])
  defp blink?(actions, _code), do: actions

  defp close_eyes?(actions, code) when (((code >>> 2) &&& 1) == 1), do: Enum.concat(actions, ["close your eyes"])
  defp close_eyes?(actions, _code), do: actions

  defp jump?(actions, code) when (((code >>> 3) &&& 1) == 1), do: Enum.concat(actions, ["jump"])
  defp jump?(actions, _code), do: actions

  defp reverse?(actions, code) when (((code >>> 4) &&& 1) == 1), do: Enum.reverse(actions)
  defp reverse?(actions, _code), do: actions
end
