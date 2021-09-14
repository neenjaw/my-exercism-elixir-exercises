defmodule SgfParsing.Lexer do
  defstruct text: []

  alias SgfParsing.Sgf
  alias SgfParsing.ParseError

  @type t :: %__MODULE__{
          text: list(String.t())
        }

  defguard is_lexer(lexer) when is_struct(lexer, __MODULE__)
  defguard is_empty(lexer) when is_struct(lexer, __MODULE__) and lexer.text == []

  @doc """
  Create a new lexer struct from a string
  """
  @spec new(String.t()) :: __MODULE__.t()
  def new(input) when is_binary(input) do
    %__MODULE__{text: input |> String.graphemes()}
  end

  @doc """
  Consume a part of the text
  """
  @spec consume(__MODULE__.t(), String.t() | nil) :: {:value, String.t(), __MODULE__.t()} | nil
  def consume(lexer, until \\ nil)

  def consume(lexer, _) when is_lexer(lexer) and is_empty(lexer), do: nil

  def consume(lexer, nil) when is_lexer(lexer) do
    case hd(lexer.text) do
      "\\" ->
        {:value, v, lexer} =
          next =
          lexer
          |> Map.put(:text, tl(lexer.text))
          |> consume()

        case v do
          "n" ->
            {:value, "\n", lexer}

          "t" ->
            {:value, "\t", lexer}

          _ ->
            next
        end

      char ->
        {:value, char, Map.put(lexer, :text, tl(lexer.text))}
    end
  end

  def consume(lexer, until) when is_lexer(lexer) and is_binary(until) do
    {consumed, text} = Enum.split_while(lexer.text, fn char -> char != until end)
    {:value, Enum.join(consumed, ""), Map.put(lexer, :text, text)}
  end

  @doc """
  Get the letters from the lexer without altering lexer state
  """
  @spec peek(__MODULE__.t(), non_neg_integer()) :: list(String.t())
  def peek(lexer, n \\ 1) when is_lexer(lexer), do: lexer.text |> Enum.split(n) |> elem(0)

  @doc """
  Parse a string using a lexer to consume it to the Sgf form
  """
  @spec parse(text :: String.t()) :: {:ok, Sgf.t()} | {:error, String.t()}
  def parse(text) when is_binary(text) do
    lexer = new(text)
    {:tree, tree, _} = parse_tree(lexer)

    {:ok, tree}
  rescue
    e in ParseError -> {:error, e.message}
  end

  @spec parse_tree(__MODULE__.t()) :: {:tree, Sgf.t(), __MODULE__.t()}
  def parse_tree(lexer) when is_lexer(lexer) and is_empty(lexer) do
    raise ParseError, "tree missing"
  end

  def parse_tree(lexer) when is_lexer(lexer) do
    case peek(lexer, 2) do
      [";" | _] ->
        raise ParseError, "tree missing"

      ["(", ")"] ->
        raise ParseError, "tree with no nodes"

      ["(", ";"] ->
        # drop (
        {:value, _, lexer} = consume(lexer)
        # get node
        {:node, node, lexer} = parse_node(lexer)
        # drop )
        {:value, _, lexer} = consume(lexer)

        {:tree, node, lexer}
    end
  end

  @spec parse_node(__MODULE__.t()) :: {:node, Sgf.t(), __MODULE__.t()}
  def parse_node(lexer) when is_lexer(lexer) do
    {:value, ";", lexer} = consume(lexer)

    case peek(lexer) do
      [char | _] when char not in ["(", ";", ")"] ->
        {:properties, properties, lexer} = parse_properties(lexer)

        case peek(lexer) do
          [";"] ->
            {:node, child, lexer} = parse_node(lexer)
            {:node, %Sgf{properties: properties, children: [child]}, lexer}

          ["("] ->
            {:children, children, lexer} = parse_children(lexer)
            {:node, %Sgf{properties: properties, children: children}, lexer}

          [")"] ->
            {:node, %Sgf{properties: properties}, lexer}
        end

      _ ->
        {:node, %Sgf{}, lexer}
    end
  end

  @spec parse_children(__MODULE__.t()) :: {:children, list(Sgf.t()), __MODULE__.t()}
  def parse_children(lexer) do
    Stream.unfold(lexer, fn lexer ->
      case peek(lexer) do
        ["("] ->
          {:tree, tree, lexer} = parse_tree(lexer)
          {{:tree, tree, lexer}, lexer}

        _ ->
          nil
      end
    end)
    |> Enum.reduce(:start, fn
      {:tree, tree, lexer}, :start ->
        {:children, [tree], lexer}

      {:tree, tree, lexer}, {:children, trees, _} ->
        {:children, [tree | trees], lexer}
    end)
    |> (fn {:children, trees, lexer} ->
          {:children, Enum.reverse(trees), lexer}
        end).()
  end

  @letter ~r/^\p{L}$/u
  @spec parse_properties(__MODULE__.t()) :: {:properties, map(), __MODULE__.t()}
  def parse_properties(lexer) when is_lexer(lexer) do
    Stream.unfold(lexer, fn lexer ->
      [char] = peek(lexer)

      if char =~ @letter do
        {:value, key, lexer} = consume(lexer, "[")

        cond do
          key != String.upcase(key) ->
            raise ParseError, "property must be in uppercase"

          true ->
            {:property_values, values, lexer} = parse_property_values(lexer)

            {{:property, %{key => values}, lexer}, lexer}
        end
      end
    end)
    |> Enum.reduce(:start, fn
      {:property, property, lexer}, :start ->
        {:properties, property, lexer}

      {:property, property, lexer}, {:properties, properties, _} ->
        {:properties, Map.merge(properties, property), lexer}
    end)
  end

  @spec parse_property_values(__MODULE__.t(), list(String.t())) ::
          {:property_values, list(String.t()), __MODULE__.t()}
  def parse_property_values(lexer, acc \\ []) do
    cond do
      acc == [] and ["["] != peek(lexer) ->
        raise ParseError, "properties without delimiter"

      ["["] != peek(lexer) ->
        {:property_values, Enum.reverse(acc), lexer}

      true ->
        {:value, _, lexer} = consume(lexer)
        {:property_value, property_value, lexer} = parse_property_value(lexer)
        {:value, _, lexer} = consume(lexer)

        parse_property_values(lexer, [property_value | acc])
    end
  end

  @spec parse_property_value(__MODULE__.t(), list(String.t())) ::
          {:property_value, String.t(), __MODULE__.t()}
  def parse_property_value(lexer, acc \\ []) do
    if peek(lexer) == ["]"] do
      {:property_value, acc |> Enum.reverse() |> Enum.join(""), lexer}
    else
      {:value, v, lexer} = consume(lexer)
      parse_property_value(lexer, [v | acc])
    end
  end
end
