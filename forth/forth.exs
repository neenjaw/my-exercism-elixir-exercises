defmodule Forth do
  alias Forth, as: F

  @opaque evaluator :: map

  defstruct evaluator: %{},
            stack: [] 

  # Match whitespace, binary nonprintable, ASCII control characters
  @input_chunk_regex ~r/\s|[\x00-\x1A]|[\cA-\cZ]/u

  @definition_start ":"
  @definition_end ";"

  @doc """
  Create a new evaluator.
  """
  @spec new() :: evaluator
  def new(), do: %F{evaluator: get_default_evaluator()}

  # Create the default evaluator function map
  defp get_default_evaluator do
    %{}
    |> Map.put("+", &operation_add/1)
    |> Map.put("-", &operation_subtract/1)
    |> Map.put("*", &operation_product/1)
    |> Map.put("/", &operation_integer_div/1)
    |> Map.put("dup", &operation_duplicate/1)
    |> Map.put("drop", &operation_drop/1)
    |> Map.put("swap", &operation_swap/1)
    |> Map.put("over", &operation_over/1)
  end

  # Add function
  defp operation_add(stack) do
    {[addend1, addend2], rem_stack} = stack |> take_from_stack(2)

    [(addend1 + addend2) | rem_stack]
  end 

  # Subtract function
  defp operation_subtract(stack) do
    {[subtrahend, minuend], rem_stack} = stack |> take_from_stack(2)

    [(minuend - subtrahend) | rem_stack]
  end

  # Product function
  defp operation_product(stack) do
    {[factor1, factor2], rem_stack} = stack |> take_from_stack(2)

    [(factor1 * factor2) | rem_stack]
  end

  # Integer Division function, catches Division by Zero
  defp operation_integer_div(stack) do
    {[divisor, dividend], rem_stack} = stack |> take_from_stack(2)

    case divisor do
      0 -> raise Forth.DivisionByZero
      _ -> [(div(dividend, divisor)) | rem_stack]
    end
  end

  # Duplicate 'DUP'
  defp operation_duplicate(stack) do
    {[n], rem_stack} = stack |> take_from_stack(1)

    [n, n | rem_stack]
  end

  # Drop 'DROP'
  defp operation_drop(stack) do
    {_, rem_stack} = stack |> take_from_stack(1)

    rem_stack
  end

  # Swap 'SWAP'
  defp operation_swap(stack) do
    {[a, b], rem_stack} = stack |> take_from_stack(2)

    [b, a | rem_stack]
  end

  # Over 'OVER'
  defp operation_over(stack) do
    {[a, b], rem_stack} = stack |> take_from_stack(2)

    [b, a, b | rem_stack]
  end

  # get the number of items from the stack needed for the function, raise Stack Underflow
  defp take_from_stack(stack, number) do
    return = {taken, _rem_stack} = stack |> Enum.split(number)

    cond do
      length(taken) != number -> raise Forth.StackUnderflow
      true -> return
    end
  end

  @doc """
  Evaluate an input string, updating the evaluator state.
  """
  @spec eval(Forth.t(), String.t()) :: evaluator
  def eval(ev, s) do
    formatted_s = s |> String.downcase

    inputs = Regex.split(@input_chunk_regex, formatted_s, trim: true)

    do_eval(ev, inputs)
  end

  defp do_eval(ev, []), do: ev
  defp do_eval(ev, [input | rem_inputs]) do
    what_is_input?(input, ev.evaluator)

    |> case do
      {:start_word_definition, _} -> handle_new_definition(ev, rem_inputs)
      {:defined_operation, op}    -> handle_operation(ev, op)
      {:integer_number, i}        -> handle_integer(ev, i)
      {:unknown_word, uw}         ->
        raise Forth.UnknownWord, word: "'#{uw}' is an unknown word"
    end

    |> case do
      {:ok_new_word,  next_ev, next_inputs} -> do_eval(next_ev, next_inputs)
      {:ok_operation, next_ev}              -> do_eval(next_ev, rem_inputs)
      {:ok_number,    next_ev}              -> do_eval(next_ev, rem_inputs)
    end
  end

  defp what_is_input?(input, evaluator) do
    cond do
      input == @definition_start ->
        {:start_word_definition, input}
      
      Map.has_key?(evaluator, input) -> 
        {:defined_operation, input}
        
      Kernel.is_integer(input) ->
        {:integer_number, input}

      true ->
        with {:ok, number} <- get_integer_from_string(input)
        do
          {:integer_number, number}
        else
          {:error, _} -> {:unknown_word, input}
        end
    end
  end

  defp get_integer_from_string(str) do
    try do
      {:ok, str |> String.to_integer} 
    rescue
      ArgumentError -> {:error, "not an integer"}
    end
  end

  # add a new word definition to the evaluator, return the updated evaluator, stack, and any remaining inputs
  defp handle_new_definition(ev = %F{evaluator: e}, [new_word | definition_inputs]) do
    what_is_input?(new_word, e)
    
    |> case do
      {:integer_number, _} -> 
        raise Forth.InvalidWord, word: "cannot redefine a number"

      {:start_word_definition, _} ->
        raise Forth.InvalidWord, word: "malformed definition"

      {_, word} ->
        do_handle_new_definition(word, definition_inputs, e)
    end

    |> case do
      {:ok, word_definition, remaining_inputs} -> 
        {:ok_new_word, %{ev | evaluator: Map.put(e, new_word, word_definition)}, remaining_inputs}
    end
  end

  # build the word definition's macro
  defp do_handle_new_definition(word, word_inputs, evaluator, fs_acc \\ [])
  # error cases
  defp do_handle_new_definition(_word, [], _e, _fs_acc), 
    do: raise Forth.InvalidWord, word: "definition missing '#{@definition_end}'"
  defp do_handle_new_definition(word, [word | _word_inputs], _e, _fs_acc), 
    do: raise Forth.InvalidWord, word: "cannot define '#{word}' with '#{word}'"
  # success case
  defp do_handle_new_definition(_word, [@definition_end | rem_inputs], _e, fs_acc) do
    fs = fs_acc |> Enum.reverse
    
    {:ok, fs, rem_inputs}
  end
  # recursive case
  defp do_handle_new_definition(word, [f | word_inputs], e, fs_acc) do
    what_is_input?(f, e)
    
    |> case do
      {:defined_operation, op} -> 
        do_handle_new_definition(word, word_inputs, e, [op | fs_acc])
        
      {:integer_number, i} ->
        do_handle_new_definition(word, word_inputs, e, [i | fs_acc])

      {_, w} -> raise Forth.InvalidWord, word: "cannot use #{w} in definition"
    end
  end
  
  # Perform the operation defined by the word on the stack
  #   - If it's a function, call the function,
  #   - If it's a list of words defined, then evaluate the defined list
  defp handle_operation(ev = %F{evaluator: e, stack: t}, word) do
    operation = e[word]

    case operation do
      f when is_function(f) -> {:ok_operation, %{ev | stack: f.(t)}}
      fs when is_list(fs)   -> {:ok_operation, do_eval(ev, fs)}
    end
  end

  # Push the integer to the stack
  defp handle_integer(ev = %F{stack: t}, number) do
    {:ok_number, %{ev | stack: [number | t]}}
  end

  @doc """
  Return the current stack as a string with the element on top of the stack
  being the rightmost element in the string.
  """
  @spec format_stack(evaluator) :: String.t()
  def format_stack(%F{stack: t}) do
    t |> Enum.reverse |> Enum.join(" ")
  end

  # Custom Errors
  
  defmodule StackUnderflow do
    defexception []
    def message(_), do: "stack underflow"
  end

  defmodule InvalidWord do
    defexception word: nil
    def message(e), do: "invalid word: #{inspect(e.word)}"
  end

  defmodule UnknownWord do
    defexception word: nil
    def message(e), do: "unknown word: #{inspect(e.word)}"
  end

  defmodule DivisionByZero do
    defexception []
    def message(_), do: "division by zero"
  end
end
