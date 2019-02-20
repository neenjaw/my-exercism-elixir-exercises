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
    fpuzzle = puzzle |> String.upcase
    
    equation = fpuzzle 
    |> get_equation

    letter_possibilities = fpuzzle 
    |> get_letters
    |> remove_zero_possibilities(fpuzzle)    
    
    _rules = build_constraint_rules(letter_possibilities, fpuzzle, equation)

    letters = letter_possibilities |> Map.keys

    generate_solutions(letters, letter_possibilities, equation)
    |> case do
      {:ok, solution} -> solution |> format_solution
      _ -> nil
    end
  end

  def get_letters(puzzle) do
    puzzle
    |> to_charlist
    |> Enum.filter(&(&1 in ?A..?Z))
    |> Map.new(fn c -> {to_string([c]), @initial_possibiltiies} end)
  end

  def build_constraint_rules(letter_map, puzzle, equation) do
    rules = [] 
    |> Kernel.++(column_restrictions(letter_map, equation))
  end

  def remove_zero_possibilities(letter_map, puzzle) do
    Regex.scan(~r/(^|\W)(?'letter'\w)/u, puzzle, capture: :all_names) 
    |> List.flatten 
    |> Enum.uniq
    |> Enum.reduce(letter_map, fn l, map ->
      new_possibiltiies = map[l]
      |> List.delete(0)

      Map.put(map, l, new_possibiltiies)
    end)
  end

  def column_restrictions(letter_map, {left, right}) do
    left_by_column = left |> by_column
    right_by_column = right |> by_column

    letter_map
  end

  def by_column(terms) do
    sorted_terms = terms
    |> Enum.map(&({&1, String.length(&1), String.graphemes(&1)}))
    |> Enum.sort(fn {_, length_a, _}, {_, length_b, _} -> length_a >= length_b end)

    {_, max_term_length, _} = sorted_terms |> hd

    sorted_terms
    |> Enum.map(fn {_, term_length, term_list} -> 
      List.duplicate("-", (max_term_length - term_length)) ++ term_list
    end)
    |> Enum.zip
  end

  def get_equation(puzzle) do
    ~r/(?'term'\w+|==)/u
    |> Regex.scan(puzzle, capture: :all_names) 
    |> List.flatten
    |> Enum.split_while(fn term -> term != "==" end)
    |> (fn {left, [_eq | right]} -> {left, right} end).()
  end

  def test_equation({left, right}, solution) do
    get_value_of(left, solution) == get_value_of(right, solution)
  end

  def get_value_of(terms,solution) do
    terms
    |> Enum.map(fn term ->
      solution
      |> Enum.reduce(term, fn {letter, value}, term ->
        String.replace(term, letter, "#{value}")
      end)
      |> String.to_integer
    end)
    |> Enum.sum
  end

  def generate_solutions(letters, possibilities, equation, solution_acc \\ [])
  def generate_solutions([], _possibilities, equation, solution_acc) do
    # Base case, no more letters to generate a solution for, so test the equation
    case test_equation(equation, solution_acc) do
      true -> {:ok, solution_acc}
      _ -> {:no_solution, "possible solution doesnt work"}
    end
  end
  def generate_solutions([letter|letters], possibilities, equation, solution_acc) do
    # get the list of possibilities for the current letter
    case possibilities[letter] do
      # if there are no more possibilities, then return an error
      [] -> {:no_solution, "no possibilities left for #{letter}"}

      letter_options ->  
        letter_options
        # filter out solutions that are already picked from potentials
        |> Enum.reject(fn option ->
          case solution_acc do
            # If none picked yet, don't filter any
            [] -> false 
            # Filter any previously chose numbers out
            solutions -> 
              solutions
              |> Enum.any?(fn {_, already_picked} -> option == already_picked end)
          end
        end)
        #if there is a potential number, then recursively build a solution
        |> case do
          [] -> {:no_solution, "no options remaining for #{letter}"}
          [foption|foptions] -> 

            case generate_solutions(letters, possibilities, equation, [{letter, foption} | solution_acc]) do
              {:ok, _} = result -> result
              {:no_solution, _} -> 
                # if the solution fails with the current pick, then remove the possibility then try again
                updated_possibiltiies = Map.put(possibilities, letter, foptions)

                generate_solutions([letter|letters], updated_possibiltiies, equation, solution_acc)
            end
        end
    end
  end

  def format_solution(solution, acc \\ %{}) 
  def format_solution([], acc), do: acc
  def format_solution([{letter, value} | rest], acc) do
    codepoint = letter |> to_charlist |> hd

    format_solution rest, Map.put(acc, codepoint, value)
  end
end
