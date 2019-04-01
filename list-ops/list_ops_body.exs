defmodule ListOpsBody do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  # base case
  def count([]), do: 0
  # recursive case
  def count([_|t]), do: 1 + count(t)


  @spec reverse(list) :: list
  def reverse(l), do: reverse(l, [])

  # base case
  def reverse([], rev), do: rev
  # recursive case
  def reverse([h|t], rev), do: reverse(t, [h|rev])

  @spec map(list, (any -> any)) :: list
  def map([], _f), do: []
  def map([h|t], f), do: [f.(h) | map(t, f)]

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter([], _f), do: []
  # recursive case
  def filter([h|t], f) do
    cond do
      f.(h) -> [h | filter(t, f)]
      true  -> filter(t, f)
    end
  end


  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  # base case
  def reduce([], acc, _f), do: acc
  # recursive case
  def reduce([h|t], acc, f), do: reduce(t, f.(h, acc), f)


  @spec append(list, list) :: list
  def append([], b), do: b
  def append(a, []), do: a
  def append([h | t], b), do: [h | append(t, b)]


  @spec concat([[any]]) :: [any]
  def concat([]), do: []
  def concat([h|t]), do: append(h, concat(t))
end
