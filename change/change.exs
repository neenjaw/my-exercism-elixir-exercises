defmodule Change do
  @doc """
    Determine the least number of coins to be given to the user such
    that the sum of the coins' value would equal the correct amount of change.
    It returns {:error, "cannot change"} if it is not possible to compute the
    right amount of coins. Otherwise returns the tuple {:ok, list_of_coins}

    ## Examples

      iex> Change.generate([5, 10, 15], 3)
      {:error, "cannot change"}

      iex> Change.generate([1, 5, 10], 18)
      {:ok, [1, 1, 1, 5, 10]}

  """

  @spec generate(list, integer) :: {:ok, list} | {:error, String.t}
  def generate(coins, target) do
    coins
    |> Enum.sort(&(&1 >= &2))
    |> find_solution(target)
  end

  @spec find_solution(list, integer, integer) :: {:ok, list} | {:error, String.t}
  defp find_solution(coins, target, number_of_coins \\ 1)

  # matches if the target is zero
  defp find_solution(_coins, 0, _number_of_coins),
    do: {:ok, []}

  # matches if it attempts a solution with more coins that cents
  defp find_solution(_coins, target, number_of_coins) when number_of_coins not in 1..target,
    do: {:error, "cannot change"}

  # matches an attempt with valid params
  defp find_solution(coins, target, number_of_coins) do
    # either finds a solution with n coins, or tries to satisfy again with n+1 coins
    case try_n_coins(coins, target, number_of_coins) do
      {:ok, solution} -> {:ok, solution}
      {:error, "cannot change"} -> find_solution(coins, target, number_of_coins + 1)
    end
  end

  @spec try_n_coins(list, integer, integer) :: {:ok, list} | {:error, String.t}
  # if no coins are given to satisfy, respond with error
  defp try_n_coins([], _target, _number_of_coins),
    do: {:error, "cannot change"}

  # if the solution asks for 1 coin, check if there is a single coin that satisfies the target
  defp try_n_coins(coins, target, 1) do
    case Enum.member?(coins, target) do
      true -> {:ok, [target]}
      false -> {:error, "cannot change"}
    end
  end

  # if the coin at the head of the coins list is bigger than the target, discard and try again
  defp try_n_coins([head | tail], target, number_of_coins) when head > target do
    try_n_coins(tail, target, number_of_coins)
  end

  # try to build partial solutions:
  #   1) attempt to build a solution to target-head with n-1 with all of the coins
  #       - if successful, then use the head coin in the solution
  #       - if not able to, try to get a solution, without the head coin to target in n coins
  defp try_n_coins(coins = [coin | remaining_coins], target, number_of_coins) do
    case try_n_coins(coins, target - coin, number_of_coins - 1) do
      {:error, "cannot change"} -> try_n_coins(remaining_coins, target, number_of_coins)
      {:ok, partial_solution} -> {:ok, partial_solution ++ [coin]}
    end
  end
end
