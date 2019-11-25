defmodule SecretHandshake do
  import Bitwise, only: [&&&: 2]

  @command_codes [
    {0b00001, "wink"},
    {0b00010, "double blink"},
    {0b00100, "close your eyes"},
    {0b01000, "jump"},
  ]

  @reverse_code 0b10000

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
    command_list =
      Enum.reduce(@command_codes, [], &parse_commands(code, &1, &2))

    if reverse_commands?(code) do
      Enum.reverse(command_list)
    else
      command_list
    end
  end

  defp parse_commands(code, {command_bitmask, command}, acc) do
    if ((code &&& command_bitmask) != 0), do: acc ++ [command], else: acc
  end

  defp reverse_commands?(code) do
    (code &&& @reverse_code) != 0
  end
end
