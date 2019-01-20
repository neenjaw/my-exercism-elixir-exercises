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
      _  -> str |> String.graphemes |> process_list
    end
  end

  def process_list(l, stack \\ [])
  def process_list([], []), do: true
  def process_list([], [_|_]), do: false

  # opening bracket function
  def process_list([c|rest], stack) when c in @opening do
    process_list(rest, [Map.get(@pairs, c) | stack])
  end

  # closing bracket functions
  def process_list([c|_rest], []) when c in @closing, do: false
  def process_list([c|rest], [c|stack]) 
    when c in @closing, do: process_list(rest, stack)
  def process_list([c|_rest], [t|_stack])
    when c in @closing and c != t, do: false

  # non-bracket function 
  def process_list([_c|rest], stack) do
    process_list(rest, stack)
  end
end