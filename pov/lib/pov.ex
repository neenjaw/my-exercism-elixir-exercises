defmodule Pov do
  @typedoc """
  A tree, which is made of a node with several branches
  """
  @type tree :: {any, [tree]}

  @doc """
  Reparent a tree on a selected node.
  """
  @spec from_pov(tree :: tree, node :: any) :: {:ok, tree} | {:error, atom}
  def from_pov(tree, node) do
    rerooted =
      tree
      |> Graph.read()
      |> Graph.format(node)

    case rerooted do
      {:error, _} = err -> err
      _ -> {:ok, rerooted}
    end
  end

  @doc """
  Finds a path between two nodes
  """
  @spec path_between(tree :: tree, from :: any, to :: any) :: {:ok, [any]} | {:error, atom}
  def path_between(tree, from, to) do
    graph = Graph.read(tree)
    from_exists? = Graph.node_exists?(graph, from)
    to_exists? = Graph.node_exists?(graph, to)

    case {from_exists?, to_exists?} do
      {false, _} ->
        {:error, :nonexistent_source}

      {_, false} ->
        {:error, :nonexistent_destination}

      _ ->
        {:ok, Graph.find_path(graph, from, to)}
    end
  end
end
