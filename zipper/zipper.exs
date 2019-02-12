defmodule BinTree do
  import Inspect.Algebra

  @moduledoc """
  A node in a binary tree.

  `value` is the value of a node.
  `left` is the left subtree (nil if no subtree).
  `right` is the right subtree (nil if no subtree).
  """
  @type t :: %BinTree{value: any, left: BinTree.t() | nil, right: BinTree.t() | nil}
  defstruct value: nil, left: nil, right: nil

  # A custom inspect instance purely for the tests, this makes error messages
  # much more readable.
  #
  # BT[value: 3, left: BT[value: 5, right: BT[value: 6]]] becomes (3:(5::(6::)):)
  def inspect(%BinTree{value: v, left: l, right: r}, opts) do
    concat([
      "(",
      to_doc(v, opts),
      ":",
      if(l, do: to_doc(l, opts), else: ""),
      ":",
      if(r, do: to_doc(r, opts), else: ""),
      ")"
    ])
  end
end

defmodule Zipper do
  alias BinTree, as: BT 
  alias Zipper, as: Z

  @type t :: %Zipper{tree: BinTree.t(), breadcrumbs: [BinTree.t() | nil]}
  defstruct tree: nil, breadcrumbs: []

  @doc """
  Get a zipper focused on the root node.
  """
  @spec from_tree(BT.t()) :: Z.t()
  def from_tree(bt), do: %Z{tree: bt}

  @doc """
  Get the complete tree from a zipper.
  """
  @spec to_tree(Z.t()) :: BT.t()
  def to_tree(%Z{tree: t, breadcrumbs: []}), do: t
  def to_tree(%Z{tree: t, breadcrumbs: [{:left,  l} | parents]}), do: to_tree %Z{tree: %{l | left:  t}, breadcrumbs: parents}
  def to_tree(%Z{tree: t, breadcrumbs: [{:right, l} | parents]}), do: to_tree %Z{tree: %{l | right: t}, breadcrumbs: parents}


  @doc """
  Get the value of the focus node.
  """
  @spec value(Z.t()) :: any
  def value(%Z{tree: %BT{value: v}}), do: v

  @doc """
  Get the left child of the focus node, if any.
  """
  @spec left(Z.t()) :: Z.t() | nil
  def left(%Z{tree: %BT{left: nil}}), do: nil
  def left(%Z{tree: %BT{left: l} = t} = z), do: %{z | tree: l, breadcrumbs: [{:left, t} | z.breadcrumbs]}  

  @doc """
  Get the right child of the focus node, if any.
  """
  @spec right(Z.t()) :: Z.t() | nil
  def right(%Z{tree: %BT{right: nil}}), do: nil
  def right(%Z{tree: %BT{right: r} = t} = z), do: %{z | tree: r, breadcrumbs: [{:right, t} | z.breadcrumbs]}  

  @doc """
  Get the parent of the focus node, if any.
  """
  @spec up(Z.t()) :: Z.t()
  def up(%Z{breadcrumbs: []}), do: nil 
  def up(%Z{tree: t, breadcrumbs: [{:left,  l} | parents]}), do: %Z{tree: %{l | left:  t}, breadcrumbs: parents}
  def up(%Z{tree: t, breadcrumbs: [{:right, r} | parents]}), do: %Z{tree: %{r | right: t}, breadcrumbs: parents}

  @doc """
  Set the value of the focus node.
  """
  @spec set_value(Z.t(), any) :: Z.t()
  def set_value(%Z{tree: t} = z, v), do: %{z | tree: %{t | value: v}}

  @doc """
  Replace the left child tree of the focus node.
  """
  @spec set_left(Z.t(), BT.t()) :: Z.t()
  def set_left(%Z{tree: t} = z, l), do: %{z | tree: %{t | left: l}}

  @doc """
  Replace the right child tree of the focus node.
  """
  @spec set_right(Z.t(), BT.t()) :: Z.t()
  def set_right(%Z{tree: t} = z, r), do: %{z | tree: %{t | right: r}}
end
