defmodule Dominoes.Pile do
  @moduledoc """
  A data structure which represents a pile of dominoes where any could be picked from
  the 'pile'.  It is maintained by two maps that allow easy indexing for the pieces because
  can be played both 'forward' and in 'reverse'.  Maps are used to facilite easy traversal with
  map functions and Access protocols
  """

  alias Dominoes.Pile, as: Pile

  defstruct domino_pile: %{},
            reversed_domino_pile: %{}

  @typep domino_pile :: %{required(1..6) => %{required(1..6) => non_neg_integer()}}

  @type t() :: %__MODULE__{
    domino_pile: domino_pile,
    reversed_domino_pile: domino_pile,
  }

  @spec add_domino(Pile.t(), {integer, integer}) :: Pile.t()
  def add_domino(pile = %Pile{}, {a,b}) do
    pile = %{pile | domino_pile: add_to_domino_map(pile.domino_pile, {a,b})}

    %{pile | reversed_domino_pile: add_to_domino_map(pile.reversed_domino_pile, {b,a})}
  end

  defp add_to_domino_map(domino_map, {a,b}) do
    Map.update(domino_map, a, %{b => 1}, fn a_map ->
      Map.update(a_map, b, 1, &(&1 + 1))
    end)
  end

  @spec is_empty?(Pile.t()) :: boolean
  def is_empty?(pile = %Pile{}) do
    case pile.domino_pile do
      pile when pile == %{} -> true

      pile ->
        pile
        |> Map.keys()
        |> Enum.all?(fn a ->
          pile[a]
          |> Map.to_list()
          |> Enum.all?(fn {_b, c} -> c == 0 end)
        end)
    end
  end

  @spec next_piece_options(Pile.t()) :: list({integer, integer})
  def next_piece_options(pile = %Pile{}) do
    options =
      pile.domino_pile
      |> Map.keys()
      |> Enum.flat_map(fn a ->
        pile.domino_pile[a]
        |> Map.to_list()
        |> Enum.filter(fn {_b, c} -> c > 0 end)
        |> Enum.map(fn {b, _c} -> {a,b} end)
      end)

    reversed_options =
      pile.reversed_domino_pile
      |> Map.keys()
      |> Enum.flat_map(fn b ->
        pile.reversed_domino_pile[b]
        |> Map.to_list()
        |> Enum.filter(fn {_a, c} -> c > 0 end)
        |> Enum.map(fn {a, _c} -> {b,a} end)
      end)

    (options ++ reversed_options)
    |> Enum.reduce(%{}, fn d, map -> Map.update(map, d, 1, &(&1 + 1)) end)
  end

  @spec next_piece_options(Pile.t(), integer) :: list({integer, integer})
  def next_piece_options(pile = %Pile{}, a) do
    options =
      pile.domino_pile[a]
      |> case do
        nil -> []

        options ->
          options
          |> Map.to_list()
          |> Enum.filter(fn {_b, c} -> c > 0 end)
          |> Enum.map(fn {b, _c} -> {a,b} end)
      end

    reversed_options =
      pile.reversed_domino_pile[a]
      |> case do
        nil -> []

        options ->
          options
          |> Map.to_list()
          |> Enum.filter(fn {_b, c} -> c > 0 end)
          |> Enum.map(fn {b, _c} -> {a,b} end)
      end

    (options ++ reversed_options)
    |> Enum.reduce(%{}, fn d, map -> Map.update(map, d, 1, &(&1 + 1)) end)
  end

  @spec select_from_pile(Pile.t(), {pos_integer, pos_integer}) :: {:ok, Pile.t(), {integer, integer}} | {:error, Pile.t(), String.t()}
  def select_from_pile(pile = %Pile{}, {a,b}) do
    forward? = in_pile?(pile.domino_pile, {a,b})
    reverse? = in_pile?(pile.reversed_domino_pile, {a,b})

    found? =
      case {forward?, reverse?} do
        {false, false} -> {:error, pile, "Domino not found in pile."}
        {false, true}  -> {:found, {b,a}}
        {true,  _}     -> {:found, {a,b}}
      end

    case found? do
      err = {:error, _, _} -> err

      {:found, {a,b}} ->
        pile = %{pile | domino_pile: update_in(pile.domino_pile, [a,b], &(&1 - 1))}
        pile = %{pile | reversed_domino_pile: update_in(pile.reversed_domino_pile, [b,a], &(&1 - 1))}

        {:ok, pile, {a,b}}
    end
  end

  defp in_pile?(domino_pile, {a,b}) do
    domino_pile[a]
    |> case do
      nil -> false

      b_map ->
        b_map[b]
        |> case do
          n when is_integer(n) and (n > 0) -> true
          _ -> false
        end
    end
  end
end

defmodule Dominoes do
  alias Dominoes.Pile, as: Pile

  @type domino :: {1..6, 1..6}

  @doc """
  chain?/1 takes a list of domino stones and returns boolean indicating if it's
  possible to make a full chain
  """
  @spec chain?(dominoes :: [domino] | []) :: boolean
  def chain?(dominoes) do
    pile = Enum.reduce(dominoes, %Pile{}, fn d, pile -> Pile.add_domino(pile, d) end)

    starting_piece_options =
      pile
      |> Pile.next_piece_options()
      |> Map.keys()

    start_chain(pile, starting_piece_options)
    |> case do
      {:ok_path, _} -> true
      {:no_path}    -> false
    end
  end

  @doc """
  First step of the chain, select a starting piece, then recursively build the chain
  with the ability to backtrack and make alternate choices for the domino pieces.
  """
  def start_chain(pile, options)

  def start_chain(pile, []) do
    # IO.inspect(binding(), label: "start_chain []")

    if Pile.is_empty?(pile) do
      {:ok_path, []}
    else
      {:no_path}
    end
  end


  def start_chain(pile, [option = {start, _} | options]) do
    # IO.inspect(binding(), label: "start_chain [h|t]")

    {:ok, next_pile, _} = Pile.select_from_pile(pile, option)

    case next_chain(next_pile, [option], start) do
      {:ok_path, chain} -> {:ok_path, chain}

      {:no_path} ->
        start_chain(pile, options)
    end
  end

  @doc """
  Find the second and subsequent pieces of the chain.  next_chain/3 collects the next pieces,
  then delegates the testing of the next pieces to do_next_chain/4
  """
  def next_chain(pile, chain = [_last = {_, edge} | _], starting_edge) do
    # IO.inspect(binding(), label: "next_chain")

    next_piece_options =
      pile
      |> Pile.next_piece_options(edge)
      |> Map.keys()

    case next_piece_options do
      [] ->
        if Pile.is_empty?(pile) and edge == starting_edge do
          {:ok_path, (chain |> Enum.reverse)}
        else
          {:no_path}
        end

      options ->
        do_next_chain(pile, chain, options, starting_edge)
    end
  end

  def do_next_chain(_pile, _chain, [], _) do
    # IO.inspect(binding(), label: "do_next_chain []")

    {:no_path}
  end

  def do_next_chain(pile, chain, [domino | options], starting_edge) do
    # IO.inspect(binding(), label: "do_next_chain [h|t]")

    {:ok, next_pile, _} = Pile.select_from_pile(pile, domino)

    case {domino, Pile.is_empty?(next_pile)} do
      {{_, ^starting_edge}, true} -> {:ok_path, ([domino | chain] |> Enum.reverse())}

      {_, true} -> {:no_path}

      {_, false} ->
        case next_chain(next_pile, [domino | chain], starting_edge) do
          ok = {:ok_path, _chain} -> ok

          {:no_path} ->
            do_next_chain(pile, chain, options, starting_edge)
        end
    end
  end
end
