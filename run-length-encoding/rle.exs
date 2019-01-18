defmodule RunLengthEncoder do
  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "AABBBCCCC" => "2A3B4C"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "2A3B4C" => "AABBBCCCC"
  """
  @spec encode(String.t()) :: String.t()
  def encode(string) do
    string
    |> String.graphemes()
    |> do_encode()
    |> Enum.join()
  end

  defp do_encode([]), do: []
  defp do_encode(stringlist) when is_list(stringlist) do
    # get the first character to set up the accumulator for first call
    s = List.first(stringlist)

    # chunk function
    #   if the character matches the accumulator, then increment
    #   if the character does not match, chunk and reset accumulator
    chunk_fn = fn c, {char, count} ->
      case c do
        ^char -> {:cont, {char, count + 1}}
        _     -> case count do
                  1 -> {:cont, "#{char}", {c, 1}}
                  _ -> {:cont, "#{count}#{char}", {c, 1}}  
                end
      end
    end

    # when it reaches the end of the list, chunk the last portion
    after_fn = fn 
      {char, 1} -> {:cont, "#{char}", {}} 
      {char, count} -> {:cont, "#{count}#{char}", {}}
    end

    stringlist
    |> Enum.chunk_while({s, 0}, chunk_fn, after_fn)
  end

  @spec decode(String.t()) :: String.t()
  def decode(string) do
    # chunk function
    #   if the character is not a digit, chunk and reset the accumulator
    #   else the current character is a digit and add to the accumulator
    chunk_fn = fn x, acc ->
      if x not in ?0..?9 do
        {:cont, [x | Enum.reverse(acc)], []}
      else
        {:cont, [x | acc]}      
      end
    end

    # after function
    #   only have match for empty list, otherwise it is a malformed encoding
    after_fn = fn
      [] -> {:cont, []}
    end

    string
    |> to_charlist()
    |> Enum.chunk_while([], chunk_fn, after_fn)
    |> Enum.map(fn [letter | numbers] -> 
        s = to_string [letter]

        numbers
        |> to_string()
        |> (fn
              "" -> "1"  # if the string is blank, then return "1"
              x -> x
            end).()
        |> Integer.parse()
        |> (fn {i, _} -> i end).()  # get just the integer portion
        |> (fn i -> String.duplicate(s, i) end).()
      end)
    |> Enum.join() 
  end
end
