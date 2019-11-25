defmodule MatchingBrackets do
  @pairs %{
    "[" => "]",
    "(" => ")",
    "{" => "}",
  }

  @opening Enum.map(@pairs, fn {o, _} -> o end)
  @closing Enum.map(@pairs, fn {_, c} -> c end)

  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t()) :: boolean
  def check_brackets(str) do
    str
    |> String.graphemes()
    |> do_bracket_check()
  end

  defp do_bracket_check(l, stack \\ [])

  # Base case
  defp do_bracket_check([], []), do: true
  defp do_bracket_check([], _),  do: false

  # Opening bracket case
  defp do_bracket_check([c|rest], stack) when c in @opening do
    do_bracket_check(rest, [@pairs[c] | stack])
  end

  # Closing bracket case
  defp do_bracket_check([c|_rest], [])
    when c in @closing, do: false

  defp do_bracket_check([c|rest], [c|stack])
    when c in @closing, do: do_bracket_check(rest, stack)

  defp do_bracket_check([c|_rest], [t|_stack])
    when c in @closing and c != t, do: false

  # Non-bracket case
  defp do_bracket_check([_c|rest], stack) do
    do_bracket_check(rest, stack)
  end
end
