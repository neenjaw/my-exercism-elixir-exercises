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

  # ############################
  #  This generates a solution with traditional north american coins
  #  It does not guarantee a solution for other coins or guarantee the least
  #  number of coins
  # ############################

  @spec generate(list, integer) :: {:ok, list} | {:error, String.t()}
  def generate(_, target) when target < 0, do: {:error, "cannot change"}
  def generate(_, 0), do: {:ok, []}
  def generate(coins, target) do
    coins 
    |> Enum.sort(&(&1 >= &2))
    |> Enum.reduce({[], target}, fn coin, {coin_list, remaining} ->
      {(List.duplicate(coin, div(remaining, coin)) ++ coin_list), rem(remaining, coin)}
    end)
    |> case do
      {coin_list, 0} -> {:ok, coin_list}
      {_, x} when x > 0 -> {:error, "cannot change"}
    end
  end
end
