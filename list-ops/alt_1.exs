defmodule ListOps do
  # Please don't use any external modules (especially List or Enum) in your
  # implementation. The point of this exercise is to create these basic
  # functions yourself. You may use basic Kernel functions (like `Kernel.+/2`
  # for adding numbers), but please do not use Kernel functions for Lists like
  # `++`, `--`, `hd`, `tl`, `in`, and `length`.

  @spec count(list) :: non_neg_integer
  def count(l), do: reduce(l, 0, fn _, acc -> acc + 1 end)

  @spec reverse(list) :: list
  def reverse(l), do: reduce(l, [], &[&1 | &2])

  @spec map(list, (any -> any)) :: list
  def map(l, f), do: l |> reverse |> reduce([], &[f.(&1) | &2])

  @spec filter(list, (any -> as_boolean(term))) :: list
  def filter(l, f),
    do: l |> reverse |> reduce([], fn x, acc -> if f.(x), do: [x | acc], else: acc end)

  @type acc :: any
  @spec reduce(list, acc, (any, acc -> acc)) :: acc
  def reduce([], acc, _f), do: acc
  def reduce([hd | tl], acc, f), do: reduce(tl, f.(hd, acc), f)

  @spec append(list, list) :: list
  def append(a, b), do: a |> reverse |> reduce(b, &[&1 | &2])

  @spec concat([[any]]) :: [any]
  def concat(l), do: l |> reverse |> reduce([], &append(&1, &2))
end