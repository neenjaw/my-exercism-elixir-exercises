defmodule BracketPush do
  @pairs [{"{", "}"}, {"(", ")"}, {"[", "]"}]
  @opening Enum.map(@pairs, fn {opening, _} -> opening end)
  @closing Enum.map(@pairs, fn {_, closing} -> closing end)
  @pair_map Enum.into(@pairs, %{})

  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t()) :: boolean
  def check_brackets(str) do
    str
    |> String.graphemes
    |> do_bracket_check()
  end

  defp do_bracket_check(l, stack \\ [])

  defp do_bracket_check([], []), do: true

  defp do_bracket_check([], [_|_]), do: false

  # opening bracket function
  defp do_bracket_check([c|rest], stack) when c in @opening do
    do_bracket_check(rest, [Map.get(@pair_map, c) | stack])
  end

  # closing bracket functions
  defp do_bracket_check([c|_rest], []) when c in @closing do
    false
  end

  defp do_bracket_check([c|rest], [c|stack]) when c in @closing do
    do_bracket_check(rest, stack)
  end

  defp do_bracket_check([c|_rest], [b|_stack]) when c in @closing and c != b do
    false
  end

  # non-bracket function
  defp do_bracket_check([_c|rest], stack) do
    do_bracket_check(rest, stack)
  end
end
