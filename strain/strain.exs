defmodule Strain do
  @doc """
  Given a `list` of items and a function `fun`, return the list of items where
  `fun` returns true.

  Do not use `Enum.filter`.
  """
  @spec keep(list :: list(any), fun :: (any -> boolean)) :: list(any)
  def keep(list, fun) do
    filter_list(list, fun)
  end

  @doc """
  Given a `list` of items and a function `fun`, return the list of items where
  `fun` returns false.

  Do not use `Enum.reject`.
  """
  @spec discard(list :: list(any), fun :: (any -> boolean)) :: list(any)
  def discard(list, fun) do
    filter_list(list, &(not apply(fun, [&1])))
  end

  defp filter_list([], _fun), do: []
  defp filter_list([element | remaining], fun) do
    cond do
      apply(fun, [element]) -> [element | filter_list(remaining, fun)]
      true                  -> filter_list(remaining, fun)
    end
  end
end
