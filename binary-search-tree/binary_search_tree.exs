defmodule BinarySearchTree do
  @type bst_node :: %{data: any, left: bst_node | nil, right: bst_node | nil}

  @doc """
  Create a new Binary Search Tree with root's value as the given 'data'
  """
  @spec new(any) :: bst_node
  def new(data) do
    %{data: data, left: nil, right: nil}
  end

  @doc """
  Creates and inserts a node with its value as 'data' into the tree.
  """
  @spec insert(bst_node, any) :: bst_node
  def insert(tree = %{data: d, left:  nil}, data) when data <= d, do: %{tree | left:  new(data)}
  def insert(tree = %{data: d, right: nil}, data) when data > d,  do: %{tree | right: new(data)}
  def insert(tree = %{data: d, left:  l},   data) when data <= d, do: %{tree | left:  insert(l, data)}
  def insert(tree = %{data: d, right: r},   data) when data > d,  do: %{tree | right: insert(r, data)}

  @doc """
  Traverses the Binary Search Tree in order and returns a list of each node's data.
  """
  @spec in_order(bst_node) :: [any]
  def in_order(tree), do: do_in_order(tree, [])

  defp do_in_order(nil, greater), do: greater
  defp do_in_order(%{data: d, left: l, right: r}, prev_greater_elements) do
    greater_elements = do_in_order(r, prev_greater_elements)

    do_in_order(l, [d | greater_elements])
  end
end
