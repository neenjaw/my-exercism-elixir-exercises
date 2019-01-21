defmodule BracketPush do
  @opening ["[", "(", "{"]
  @closing ["}", ")", "]"]
  @pairs %{
    "[" => "]",
    "]" => "[",
    "(" => ")",
    ")" => "(",
    "{" => "}",
    "}" => "{",
  }

  @doc """
  Checks that all the brackets and braces in the string are matched correctly, and nested correctly
  """
  @spec check_brackets(String.t()) :: boolean
  def check_brackets(str) do
    case str do
      "" -> true
      _  -> str |> String.graphemes |> do_bracket_check
    end
  end

  defp do_bracket_check(l, stack \\ [])
  defp do_bracket_check([], []), do: true
  defp do_bracket_check([], [_|_]), do: false

  # opening bracket function
  defp do_bracket_check([c|rest], stack) when c in @opening do
    do_bracket_check(rest, [Map.get(@pairs, c) | stack])
  end

  # closing bracket functions
  defp do_bracket_check([c|_rest], []) when c in @closing, do: false
  defp do_bracket_check([c|rest], [c|stack]) 
    when c in @closing, do: do_bracket_check(rest, stack)
  defp do_bracket_check([c|_rest], [t|_stack])
    when c in @closing and c != t, do: false

  # non-bracket function 
  defp do_bracket_check([_c|rest], stack) do
    do_bracket_check(rest, stack)
  end
end