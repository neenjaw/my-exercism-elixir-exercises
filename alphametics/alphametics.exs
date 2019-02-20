defmodule Alphametics do
  @type puzzle :: binary
  @type solution :: %{required(?A..?Z) => 0..9}
  
 @initial_possibiltiies 0..9 |> Enum.to_list

  @doc """
  Takes an alphametics puzzle and returns a solution where every letter
  replaced by its number will make a valid equation. Returns `nil` when
  there is no valid solution to the given puzzle.

  ## Examples

      iex> Alphametics.solve("I + BB == ILL")
      %{?I => 1, ?B => 9, ?L => 0}

      iex> Alphametics.solve("A == B")
      nil
  """
  @spec solve(puzzle) :: solution | nil
  def solve(puzzle) do
    with fpuzzle              <- String.upcase(puzzle),
         equation             <- get_equation(fpuzzle),
         true                 <- valid_puzzle?(equation),
         raw_letter_value_map <- get_letters(fpuzzle),
         letter_value_map     <- remove_zero_possibilities(raw_letter_value_map, fpuzzle),
         rules                <- build_constraint_rules(letter_value_map, fpuzzle, equation),
         letters              <- Map.keys(letter_value_map),
         {:ok, solution}      <- generate_solution(letters, letter_value_map, equation, rules)
    do
      solution
    else
      :no_solution -> nil
    end
  end

  def get_equation(puzzle) do
    ~r/(?'term'\w+|==)/u
      |> Regex.scan(puzzle, capture: :all_names) 
      |> List.flatten
      |> Enum.split_while(fn term -> term != "==" end)
      |> (fn {left, [_eq | right]} -> {left, right} end).()
  end
  
  def valid_puzzle?({left,right}) do
    num_left_terms = length(left)
    num_right_terms = length(right)
    
    max_left_term = max_term_length(left)
    max_right_term = max_term_length(right)
    
    
    (num_right_terms == 1)
      and (max_right_term >= max_left_term)
      and (
        (not ((num_left_terms == 1) and (num_right_terms == 1)))
          or ((left |> hd) == (right |> hd)) )
  end
  
  def max_term_length([]), do: nil
  def max_term_length(terms) when is_list(terms) do
    do_max_term_length(terms)
  end
  
  defp do_max_term_length(terms, max \\ 0)
  defp do_max_term_length([], max), do: max
  defp do_max_term_length([term | rest], max) do
    length_of_term = String.length(term)
  
    cond do
      length_of_term > max -> do_max_term_length(rest, length_of_term)
      true -> do_max_term_length(rest, max)
    end
  end
  
  def get_letters(puzzle) do
    puzzle
      |> to_charlist
      |> Enum.filter(&(&1 in ?A..?Z))
      |> Map.new(fn c -> {c, @initial_possibiltiies} end)
  end

  def remove_zero_possibilities(letter_map, puzzle) do
    Regex.scan(~r/(^|\W)(?'letter'\w)/u, puzzle, capture: :all_names) 
      |> List.flatten 
      |> Enum.uniq
      |> Enum.reduce(letter_map, fn l, map ->
        c = l |> to_charlist |> hd
    
        new_possibiltiies = map[c]
          |> List.delete(0)

        Map.put(map, c, new_possibiltiies)
      end)
  end

  def build_constraint_rules(letter_map, _puzzle, equation) do
    [] ++ column_restrictions(letter_map, equation)
  end

  def column_restrictions(_letter_map, {left, right}) do
    left_by_column = left |> by_column
    right_by_column = right |> by_column

    combined_by_column = combine(left_by_column, right_by_column)

    []
    |> Kernel.++(create_column_rules(combined_by_column))
  end

  def by_column(terms) do
    sorted_terms = terms
      |> Enum.map(&({&1, String.length(&1), String.graphemes(&1)}))
      |> Enum.sort(fn {_, length_a, _}, {_, length_b, _} -> 
        length_a <= length_b 
      end)

    {_, max_term_length, _} = sorted_terms |> List.last

    sorted_terms
    |> Enum.map(fn {_, term_length, term_list} -> 
      List.duplicate("-", (max_term_length - term_length)) ++ term_list
    end)
    |> Enum.zip
  end
  
  def combine(left, right) do
    length_left = length(left)
    length_right = length(right)
    
    max_length = cond do
      length_left >= length_right -> length_left
      true -> length_right
    end
    
    normalized_left = 
      List.duplicate({"-"}, max_length - length_left) ++ left
    normalized_right = 
      List.duplicate({"-"}, max_length - length_right) ++ right
    
    Enum.zip(normalized_left, normalized_right)
  end
  
  def create_column_rules(columns, state \\ :start)
  def create_column_rules(columns, :start) do
    create_column_rules(columns, %{
      :rules => [], 
      :first => true,
      :rev_cols => [],
      })
  end
  def create_column_rules([], state) do
    [{last_left, last_right} | _] = state.rev_cols
    
    last_left_list = last_left |> Tuple.to_list
    {last_right_letter} = last_right
    
    last_letters = [last_right_letter | last_left_list]
      |> Enum.join
      |> to_charlist
    
    last_letter_set = last_letters
      |> MapSet.new

    last_rule = fn soln_acc ->
      required_letters = last_letter_set
        # |> IO.inspect(label: "req: letters, 167")
      soln_letters = soln_acc 
        |> Enum.map(fn {c, _v} -> c end)
        |> MapSet.new
        # |> IO.inspect(label: "sol: letters, 171")

      case MapSet.subset?(required_letters, soln_letters) do
        # false -> true |> IO.inspect(label: "not a subset")
        true  -> 
          soln_map = soln_acc |> Map.new
          
          [rl_val | ll_vals] = last_letters
            |> Enum.map(fn c -> soln_map[c] end)
          
          ll_vals
            |> Enum.sum
            |> Integer.digits
            |> List.last
            |> Kernel.==(rl_val)
            # |> IO.inspect(label: "subset")
      end
    end
  
    [last_rule | state.rules]
  end
  def create_column_rules([column | rest], state) do
    rules = []

    create_column_rules(
      rest, 
      %{state | rev_cols: [column | state.rev_cols], 
      rules: rules ++ state.rules})
  end

  def test_equation({left, right}, solution) do
    get_value_of(left, solution) == get_value_of(right, solution)
  end

  def get_value_of(terms,solution) do
    terms
      |> Enum.map(fn term ->
        term
          |> to_charlist
          |> Enum.map(&(solution[&1]))
          |> Integer.undigits
      end)
      |> Enum.sum
  end

  def generate_solution(chars, possible_vals, eq, rules, soln_map \\ %{})
  def generate_solution([], _, eq, _rules, soln_map) do
    # Base case, no more letters to generate a solution for
    # so test the equation
    
    case test_equation(eq, soln_map) do
      true -> {:ok, soln_map}
      _ -> :no_solution
    end
  end
  def generate_solution([char | chars], value_map, eq, rules, soln_map) do
  
    next_values =
      get_next_char_values(char, value_map, soln_map)
    
    case next_values do
      :no_value -> :no_solution
      
      [value | remaining_values] ->     
        updated_soln_map = Map.put(soln_map, char, value)

        rule_result = rules
          # |> IO.inspect(label: "test rules, 235")
          |> Enum.map(fn f -> f.(updated_soln_map) end)
          # |> IO.inspect(label: "tested rules, 238")
          |> Enum.reduce(true, fn r, conj -> r and conj end)
          # |> IO.inspect(label: "reduced, 240")

        current_result =
          case rule_result do
            true -> generate_solution(chars, value_map, eq, rules, updated_soln_map)
            _ -> :no_solution
          end
        
        case current_result do
          {:ok, _} = result -> result
          
          :no_solution -> 
            # if the solution fails with the current pick, then remove 
            # the possibility then try again
            updated_value_map = Map.put(value_map, char, remaining_values)

            generate_solution([char|chars], updated_value_map, eq, rules, soln_map)
        end
    end
  end
  
  
  def get_next_char_values(char, value_map, soln_map) do
    value_map[char] 
      |> do_get_next_char_values(soln_map)
  end
  
  def do_get_next_char_values([], _soln_map), do: :no_value
  def do_get_next_char_values(values, soln_map = %{}) when map_size(soln_map) == 0, do: values
  def do_get_next_char_values(values, soln_map) do
    values
      # filter out solutions that are already picked from potentials
      |> Enum.reject(fn value ->
        value in (soln_map |> Map.values)
      end)
  end
end