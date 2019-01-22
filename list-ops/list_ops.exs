defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  def count(l), do: count(l, 0)
  
  # base case
  defp count([], n), do: n
  # recursive case
  defp count([_|t], n), do: count(t, n+1)


  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])

  # base case
  defp reverse([], rev), do: rev
  # recursive case
  defp reverse([h|t], rev), do: reverse(t, [h|rev])


  @spec map(list, (any -> any)) :: list
  def map(l, f), do: map(l, f, []) |> reverse

  # base case
  defp map([], _f, acc), do: acc
  # recursive case
  defp map([h|t], f, acc), do: map(t, f, [f.(h)|acc])


  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter(l, f), do: filter(l, f, []) |> reverse

  # base case
  defp filter([], _f, acc), do: acc
  # recursive case
  defp filter([h|t], f, acc) do
    cond do
      f.(h) -> filter(t, f, [h|acc])
      true  -> filter(t, f, acc)
    end
  end


  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  # base case
  def reduce([], acc, _f), do: acc
  # recursive case
  def reduce([h|t], acc, f), do: reduce(t, f.(h, acc), f)


  @spec append(list, list) :: list
  def append(a, b), do: append(a, b, []) |> reverse

  # base case
  defp append([], [], acc), do: acc
  # recursive cases
  defp append([], [h|t], acc), do: append([], t, [h|acc])
  defp append([h|t], b, acc), do: append(t, b, [h|acc])


  @spec concat([[any]]) :: [any]
  def concat([]), do: []
  def concat([h|t]), do: concat(t, h, []) |> reverse

  # base base
  defp concat([], [], acc), do: acc
  # recursive cases
  defp concat(ll, [h|t], acc), do: concat(ll, t, [h|acc])
  defp concat([llh|llt], [h], acc), do: concat(llt, llh, [h|acc])
  defp concat([llh|llt], [], acc), do: concat(llt, llh, acc)
end
