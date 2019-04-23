defmodule Card do
  @suits ~w(C D H S)
  @ranks ~w(2 3 4 5 6 7 8 9 10 J Q K A)
  @ace List.last(@ranks)
  @values @ranks |> Enum.with_index() |> Enum.into(%{})

  defstruct suit: nil, rank: nil

  def new({rank, suit}) when rank in @ranks and suit in @suits do
    %Card{rank: rank, suit: suit}
  end
  def new(source), do: new(String.split_at(source, -1))

  def wheel(size), do: [@ace] ++ Enum.take(@ranks, size - 1)

  def straights(size), do: Enum.chunk_every(@ranks, size, 1)

  def value(@ace, :lower), do: 0
  def value(rank, _bound), do: @values[rank]
end

defmodule Hand do
  @size 5
  @wheel MapSet.new(Card.wheel(@size))
  @straights Enum.map(Card.straights(@size), &MapSet.new/1)

  defstruct source: [], cards: [], groups: [], category: nil,
            flush: false, straight: false, wheel: false, score: []

  def new(source) do
    %Hand{source: source}
    |> parse_source
    |> set_straight
    |> set_flush
    |> group_cards
    |> categorize
    |> score
  end

  defp parse_source(%Hand{source: source} = hand) do
    %{hand | cards: Enum.map(source, &Card.new/1)}
  end

  defp set_straight(%Hand{cards: cards} = hand) do
    case Enum.into(cards, %MapSet{}, & &1.rank) do
      @wheel -> %{hand | straight: true, wheel: true}
      ranks when ranks in @straights -> %{hand | straight: true}
      _ -> hand
     end
  end

  defp set_flush(%Hand{cards: cards} = hand) do
    case Enum.dedup_by(cards, & &1.suit) do
      [_unique_suit] -> %{hand | flush: true}
      _multiple_suits -> hand
    end
  end

  defp group_cards(%Hand{cards: cards} = hand), do: %{hand | groups: group(cards)}

  defp group(cards) do
    cards
    |> Enum.group_by(& &1.rank)
    |> Enum.map(fn {rank, group} -> {length(group), Card.value(rank, :upper)} end)
    |> Enum.sort(&>=/2)
  end

  defp categorize(%Hand{groups: groups} = hand) do
    case Enum.map(groups, & elem(&1, 0)) do
      [4, 1]       -> %{ hand | category: :four_of_a_kind  }
      [3, 2]       -> %{ hand | category: :full_house      }
      [3, 1, 1]    -> %{ hand | category: :three_of_a_kind }
      [2, 2, 1]    -> %{ hand | category: :two_pair        }
      [2, 1, 1, 1] -> %{ hand | category: :one_pair        }
      _distinct    -> %{ hand | category: :high_card       }
    end
  end

  defp score(hand) do
    %{hand | score: [category_score(hand) | cards_score(hand)]}
  end

  defp category_score(%Hand{straight: true, flush: true}), do: 8
  defp category_score(%Hand{category: :four_of_a_kind}),   do: 7
  defp category_score(%Hand{category: :full_house}),       do: 6
  defp category_score(%Hand{flush: true}),                 do: 5
  defp category_score(%Hand{straight: true}),              do: 4
  defp category_score(%Hand{category: :three_of_a_kind}),  do: 3
  defp category_score(%Hand{category: :two_pair}),         do: 2
  defp category_score(%Hand{category: :one_pair}),         do: 1
  defp category_score(_hand),                              do: 0

  defp cards_score(%Hand{wheel: true, cards: cards}) do
    cards
    |> Enum.map(& Card.value(&1.rank, :lower))
    |> Enum.sort(&>=/2)
  end
  defp cards_score(%Hand{category: :high_card, cards: cards}) do
    cards
    |> Enum.map(& Card.value(&1.rank, :upper))
    |> Enum.sort(&>=/2)
  end
  defp cards_score(%Hand{groups: groups}) do
    groups
    |> Enum.flat_map(fn {size, value} -> List.duplicate(value, size) end)
  end
end

defmodule Poker do
  @doc """
  Given a list of poker hands, return a list containing the highest scoring hand.

  If two or more hands tie, return the list of tied hands in the order they were received.

  The basic rules and hand rankings for Poker can be found at:

  https://en.wikipedia.org/wiki/List_of_poker_hands

  For this exercise, we'll consider the game to be using no Jokers,
  so five-of-a-kind hands will not be tested. We will also consider
  the game to be using multiple decks, so it is possible for multiple
  players to have identical cards.

  Aces can be used in low (A 2 3 4 5) or high (10 J Q K A) straights, but do not count as
  a high card in the former case.

  For example, (A 2 3 4 5) will lose to (2 3 4 5 6).

  You can also assume all inputs will be valid, and do not need to perform error checking
  when parsing card values. All hands will be a list of 5 strings, containing a number
  (or letter) for the rank, followed by the suit.

  Ranks (lowest to highest): 2 3 4 5 6 7 8 9 10 J Q K A
  Suits (order doesn't matter): C D H S

  Example hand: ~w(4S 5H 4C 5D 4H) # Full house, 5s over 4s
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    hands
    |> Enum.map(&Hand.new/1)
    |> Enum.sort_by(& &1.score, &>=/2)
    |> Enum.chunk_by(& &1.score)
    |> List.first()
    |> Enum.map(& &1.source)
  end
end
