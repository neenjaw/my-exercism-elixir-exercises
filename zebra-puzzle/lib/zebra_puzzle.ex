defmodule ZebraPuzzle do
  alias ZebraPuzzle.Fact
  alias ZebraPuzzle.House

  @type solution :: {%House{}, %House{}, %House{}, %House{}, %House{}}

  @doc """
  Determine who drinks the water
  """
  @spec drinks_water() :: atom
  def drinks_water() do
    house =
      solve()
      |> Tuple.to_list()
      |> Enum.find(fn house -> house.drink == :water end)

    house.nationality
  end

  @doc """
  Determine who owns the zebra
  """
  @spec owns_zebra() :: atom
  def owns_zebra() do
    house =
      solve()
      |> Tuple.to_list()
      |> Enum.find(fn house -> house.pet == :zebra end)

    house.nationality
  end

  @spec solve() :: solution()
  def solve() do
    do_solve(ZebraPuzzle.Fact.house_facts(), blank_solution())
  end

  @spec do_solve(list(%Fact{}), solution()) :: solution() | false
  defp do_solve([%Fact{} = fact | other_facts], solution) do
    Enum.find_value(house_positions(), false, fn position ->
      house = solution |> elem(position) |> House.apply_fact(fact)

      case house do
        :error ->
          nil

        _ ->
          solution =
            solution
            |> Tuple.delete_at(position)
            |> Tuple.insert_at(position, house)

          if valid_solution?(solution) do
            do_solve(other_facts, solution)
          end
      end
    end)
  end

  defp do_solve([], solution) do
    solution
  end

  @spec valid_solution?(solution()) :: boolean()
  defp valid_solution?(solution) do
    Enum.all?(house_positions(), fn position ->
      house = elem(solution, position)

      Enum.all?(house.constraints, &check_constraint(&1, position, solution))
    end)
  end

  defp check_constraint({:min_position, min_position}, position, _solution) do
    position >= min_position
  end

  defp check_constraint({:left_neighbour, attributes}, position, solution) do
    cond do
      position == 0 ->
        false

      true ->
        solution
        |> elem(position - 1)
        |> House.congruent?(attributes)
    end
  end

  defp check_constraint({:right_neighbour, attributes}, position, solution) do
    cond do
      position == 4 ->
        false

      true ->
        solution
        |> elem(position + 1)
        |> House.congruent?(attributes)
    end
  end

  defp check_constraint({:neighbour, attributes}, position, solution) do
    Enum.any?([
      check_constraint({:left_neighbour, attributes}, position, solution),
      check_constraint({:right_neighbour, attributes}, position, solution)
    ])
  end

  defp check_constraint(constraint, _, _),
    do: raise(ArgumentError, "#{inspect(constraint)} unhandled")

  @spec blank_solution() :: solution()
  defp blank_solution() do
    house_positions()
    |> Enum.map(&%House{position: &1})
    |> List.to_tuple()
  end

  @spec house_positions() :: Range.t(0, 4)
  defp house_positions(), do: 0..4
end
