defmodule Graph do
  defstruct attrs: [], nodes: [], edges: []
end

defmodule Dot.Parser do
  alias Graph, as: G

  defguard valid_node?(node)
    when is_atom(node)

  defguard valid_edge?(a, b)
    when valid_node?(a) and valid_node?(b)

  defguard valid_attr?(keyword, value) 
    when is_atom(keyword) 
      and (
        is_atom(value)
        or is_binary(value)
        or is_number(value)
      )

  @nil_attrs [nil, [], [[]]]

  def parse_ast([do: ast]), do: ast |> parse_ast(%G{})

  # use recursion to iterate through the block
  def parse_ast({:__block__, _, []},      graph = %G{}), do: graph
  def parse_ast({:__block__, _, [h | t]}, graph = %G{}), 
    do: parse_ast({:__block__, [], t}, parse_ast(h, graph))

  # handle graph attributes
  def parse_ast({:graph, _, attr}, graph = %G{}) 
    when attr in @nil_attrs, 
    do: graph
  def parse_ast({:graph, _, [[{kw, val}]]}, graph = %G{})
    when valid_attr?(kw, val),
    do: update_graph_attr(graph, kw, val)  

  # handle edges
  def parse_ast({:--, _, [{a , _, nil}, {b , _, attr}]}, graph = %G{}) 
    when attr in @nil_attrs and valid_edge?(a, b), 
    do: update_edges(graph, a, b, [])
  def parse_ast({:--, _, [{a , _, nil}, {b , _, [[{kw, val}]]}]}, graph = %G{})
    when valid_edge?(a,b) and valid_attr?(kw, val),
    do: update_edges(graph, a, b, [{kw, val}])

  # handle nodes
  def parse_ast({node, _, attr},  graph = %G{}) 
    when attr in @nil_attrs and valid_node?(node), 
    do: update_nodes(graph, node, [])
  def parse_ast({node, _, [[{kw, val}]]}, graph = %G{}) 
    when valid_node?(node) and valid_attr?(kw, val),
    do: update_nodes(graph, node, [{kw, val}])

  # catch invalid statements
  def parse_ast(_, _), do: raise ArgumentError

  # update the graph struct's graph attrs
  def update_graph_attr(graph = %G{}, kw, val), 
    do: %{graph | attrs: (Keyword.put(graph.attrs, kw, val) |> Enum.sort)}

  # update the graph struct's nodes
  def update_nodes(graph = %G{}, node, val) do
    updated_node = 
      graph.nodes
      |> Keyword.get(node, [])
      |> Keyword.merge(val)

    updated_nodes =
      graph.nodes
      |> Keyword.put(node, updated_node)
    
    sorted_nodes =
      updated_nodes 
      |> Enum.sort

    %{graph | nodes: sorted_nodes}
  end

  # update the graph struct's edges
  def update_edges(graph = %G{}, a, b, val) do
    updated_edge_attrs =
      graph.edges
      |> Enum.find(fn
          {^a, ^b, _attrs} -> true
          _                         -> false
        end)
      |> case do
        {_, _, attrs} -> attrs
        _             -> []
      end
      |> Keyword.merge(val)

    updated_edges =
      graph.edges
      |> Enum.filter(fn
          {^a, ^b, _} -> false
          _           -> true  
        end)
      |> Enum.concat([{a, b, updated_edge_attrs}])
      |> Enum.sort(fn 
          {a, _, _}, {b, _, _} when a <= b -> true
          {a, _, _}, {b, _, _} when a >  b -> false
          {e, x, _}, {e, y, _} when x <= y -> true  
          {e, x, _}, {e, y, _} when x >  y -> false  
        end)

    %{graph | edges: updated_edges} 
  end
end

defmodule Dot do
  defmacro graph(ast) do
    ast |> Dot.Parser.parse_ast |> Macro.escape
  end
end

