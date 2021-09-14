defmodule Graph do
  defstruct nodes: MapSet.new(), edges: MapSet.new()

  def new(), do: %__MODULE__{}

  def add_edge(graph, {a, b}) when is_struct(graph, __MODULE__) do
    nodes =
      graph.nodes
      |> MapSet.put(a)
      |> MapSet.put(b)

    edges =
      graph.edges
      |> MapSet.put({a, b})
      |> MapSet.put({b, a})

    %{graph | nodes: nodes, edges: edges}
  end

  def add_node(graph, a) when is_struct(graph, __MODULE__) do
    %{graph | nodes: MapSet.put(graph.nodes, a)}
  end

  def find_path(graph, from, to) when is_struct(graph, __MODULE__) do
    {^from, children} =
      graph
      |> format(from)

    [from | do_find_path(children, to)]
  end

  defp do_find_path(children, to) do
    children
    |> Enum.find_value(fn
      {^to, _} ->
        [to]

      {node, children} ->
        case do_find_path(children, to) do
          nil ->
            nil

          path ->
            [node | path]
        end
    end)
  end

  def format(graph, origin) when is_struct(graph, __MODULE__) do
    cond do
      node_exists?(graph, origin) ->
        do_format(graph, origin)

      true ->
        {:error, :nonexistent_target}
    end
  end

  defp do_format(graph, origin) do
    outgoing_edges =
      graph.edges
      |> Enum.filter(fn
        {^origin, to} -> MapSet.member?(graph.nodes, to)
        _ -> false
      end)

    graph = %{graph | nodes: MapSet.delete(graph.nodes, origin)}

    {origin, Enum.map(outgoing_edges, fn {_, to} -> do_format(graph, to) end)}
  end

  def node_exists?(graph, node) when is_struct(graph, __MODULE__) do
    MapSet.member?(graph.nodes, node)
  end

  def read(formatted), do: read(new(), formatted)

  defp read(graph, {name, []}), do: add_node(graph, name)

  defp read(graph, {name, [{child_name, _} = child | children]}) do
    graph
    |> add_edge({name, child_name})
    |> read(child)
    |> read({name, children})
  end
end
