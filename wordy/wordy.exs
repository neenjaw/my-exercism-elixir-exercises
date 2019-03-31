defmodule Wordy do
  @doc """
  Calculate the math problem in the sentence.
  """

  @state_transitions %{
    :start     => [:question],
    :question  => [:number],
    :number    => [:operation, :end],
    :operation => [:number],
  }

  @language_map %{
    "What is"       => %{state: :question},
    "plus"          => %{state: :operation, function: :addition}, 
    "minus"         => %{state: :operation, function: :subtraction}, 
    "divided by"    => %{state: :operation, function: :division}, 
    "multiplied by" => %{state: :operation, function: :mutiplication},
    "?"             => %{state: :end},
  }

  @spec answer(String.t()) :: integer
  def answer(question) do
    # Matches pos and neg integers, no leading zeroes
    by_integer = ~r/-?[1-9]([0-9]+)?/u
    
    question
    |> String.split(by_integer, include_captures: true, trim: true)
    |> do_answer
  end

  @spec do_answer(list(String.t()), atom(), list())
  defp do_answer(word_list, state \\ :start, stack \\ [])

  # base cases
  defp do_answer([], :end, [answer]), do: answer
  defp do_answer(_,  :error, _), do: raise ArgumentError

  # recursive case
  defp do_answer([word | rem_words], state, stack) do
    trimmed_word = 
      word |> String.trim
    
    {next_state, next_stack} =
      handle_word(trimmed_word, state, stack)

    do_answer(rem_words, next_state, next_stack)
  end

  # error catchall if malformed sentences, unknown states
  defp do_answer(_,_,_), do: raise ArgumentError

  # process the word based on the current state
  defp handle_word(word, state, stack) do
    state_map = 
      Map.get(@language_map, word, :undefined)
      |> case do
        :undefined -> check_if_number?(word)
        state_map  -> state_map
      end
      
    if not allowed_state_transition?(state, state_map.state) do
      {:error, nil}
    else
      {state_map.state, process_stack(state_map, stack)}
    end
  end

  # check if the word is a number
  defp check_if_number?(word) do
    word
    |> Integer.parse()
    |> case do
      {int, ""} -> %{state: :number, value: int}
      _         -> %{state: :error, message: "unrecognized word"}
    end
  end

  # Check to be sure that the states are allowed to transition
  defp allowed_state_transition?(current_state, next_state) do
    allowed_transitions = 
      Map.get(@state_transitions, current_state, [])
    
    next_state in allowed_transitions
  end

  # process the stack based on current input
  defp process_stack(%{state: :number, value: addend_a},   [:addition, addend_b | stack]),      do: [(addend_a + addend_b) | stack] 
  defp process_stack(%{state: :number, value: subtrahend}, [:subtraction, minuend | stack]),    do: [(minuend - subtrahend) | stack] 
  defp process_stack(%{state: :number, value: factor_a},   [:mutiplication, factor_b | stack]), do: [(factor_a * factor_b) | stack] 
  defp process_stack(%{state: :number, value: divisor},    [:division, dividend | stack]),      do: [div(dividend, divisor) | stack] 

  defp process_stack(%{state: :number, value: v}, stack), do: [v | stack]

  defp process_stack(%{state: :operation, function: f}, stack), do: [f | stack]

  defp process_stack(_, stack), do: stack
  
end
