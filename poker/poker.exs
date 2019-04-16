defmodule Poker do
  @moduledoc """
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

  defmodule Hand do
    defstruct [
      suit_map: %{club: 0, spade: 0, heart: 0, diamond: 0},
      value_map: 1..14 |> Enum.map(fn v -> {v, 0} end) |> Map.new,
      card_list: [],
      card_count: 0,
      attributes: []
    ]
    def new(card_string_list) do
      card_string_list
      |> Enum.reverse()
      |> add_cards()
    end

    defp add_cards(hand \\ %Poker.Hand{}, card_string_list) do
      card_string_list
      |> Enum.reduce(hand, fn c, hand -> add_card(hand, c) end)
    end

    defp add_card(hand \\ %Poker.Hand{}, card_string) do
      {value, suit} = String.split_at(card_string, -1)

      hand
      |> add_card_value(value)
      |> add_card_suit(suit)
      |> add_card_to_list(card_string)
      |> increment_card_count()
    end

    @doc """
    Add the value to the hand struct
    """
    defp add_card_value(hand, "A") do
      hand = update_in(hand.value_map[1], &(&1 + 1))
      # hand = update_in(hand.value_map[14], &(&1 + 1))
    end
    defp add_card_value(hand, value) when value in ~w(2 3 4 5 6 7 8 9 10) do
      n = String.to_integer(value)
      update_in(hand.value_map[n], &(&1 + 1))
    end
    defp add_card_value(hand, "J"), do: update_in(hand.value_map[11], &(&1 + 1))
    defp add_card_value(hand, "Q"), do: update_in(hand.value_map[12], &(&1 + 1))
    defp add_card_value(hand, "K"), do: update_in(hand.value_map[13], &(&1 + 1))

    @doc """
    Add the suit to the hand struct
    """
    defp add_card_suit(hand, "H"), do: update_in(hand.suit_map[:heart],   &(&1 + 1))
    defp add_card_suit(hand, "C"), do: update_in(hand.suit_map[:club],    &(&1 + 1))
    defp add_card_suit(hand, "D"), do: update_in(hand.suit_map[:diamond], &(&1 + 1))
    defp add_card_suit(hand, "S"), do: update_in(hand.suit_map[:spade],   &(&1 + 1))

    @doc """
    Add the card to the hand struct
    """
    defp add_card_to_list(hand, card), do: update_in(hand.card_list, &([card | &1]))

    defp increment_card_count(hand, amount \\ 1), do: update_in(hand.card_count, &(&1 + amount))
  end

  defguardp is_sequence(a,b,c,d,e)
    when (a == 1 and b == 10 and c == 11 and d == 12 and e == 13)
    or (b == a+1 and c == b+1 and d == c+1 and e ==d+1)

  @doc """
  Score and rank the hands, returning the highest hand
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    highest_hand =
      hands
      |> analyse_hands()
      |> compare_hands()

    [highest_hand.card_list]
  end

  def analyse_hands(hands, results \\ [])
  def analyse_hands([], results), do: results
  def analyse_hands([hand | hands], results) do
    result =
      hand
      |> Poker.Hand.new()
      |> add_attributes()

    analyse_hands(hands, [result | results])
  end

  defp add_attributes(hand = %Poker.Hand{}) do
    hand
    |> add_flush_attr?()
    |> add_x_of_a_kind_attr?()
    |> add_straight_attr?()
  end

  defp add_flush_attr?(hand = %Poker.Hand{}) do
    hand.suit_map
    |> Map.to_list()
    |> Enum.filter(fn {suit, count} -> if count == 5, do: true, else: false end)
    |> (fn
      [] -> hand
      [{_suit, 5}] -> update_in(hand.attributes, &([:flush | &1]))
    end).()
  end

  defp add_x_of_a_kind_attr?(hand = %Poker.Hand{}) do
    hand.value_map
    |> Map.to_list()
    |> Enum.sort(fn
      {_v1, x}, {_v2, y} when x >= y -> true
      _, _ -> false
    end)
    |> Enum.take_while(fn {_v, c} -> c > 0 end)
    |> case do
      [{_, 4}, {_, 1}] -> :four_of_a_kind
      [{_, 3}, {_, 2}] -> :full_house
      [{_, 3}, {_, 1}, {_, 1}] -> :three_of_a_kind
      [{_, 2}, {_, 2}, {_, 1}] -> :two_pair
      [{_, 2}, {_, 1}, {_, 1}, {_, 1}] -> :one_pair
      [{_, 1}, {_, 1}, {_, 1}, {_, 1}, {_, 1}] -> :high_card
      _ -> raise ArgumentError
    end
    |> case do
      attr -> update_in(hand.attributes, &([attr | &1]))
    end
  end

  defp add_straight_attr?(hand = %Poker.Hand{}) do
    hand.value_map
    |> Map.to_list()
    |> Enum.filter(fn
      {_, 1} -> true
      _      -> false
    end)
    |> case do
      list when length(list) != 5 -> hand

      list ->
        list
        |> Enum.map(fn {v, _c} -> v end)
        |> Enum.sort()
        |> case do
          [a,b,c,d,e] when not is_sequence(a,b,c,d,e) -> hand

          _ -> update_in(hand.attributes, &([:straight | &1]))
        end
    end
  end

  @order_of_hands [
    [:straight, :flush],
    :four_of_a_kind,
    :full_house,
    :flush,
    :straight,
    :three_of_a_kind,
    :two_pair,
    :one_pair,
    :high_card
  ]

  defp compare_hands(hands, best_hand \\ nil)
  defp compare_hands([], best_hand), do: best_hand
  defp compare_hands([hand | hands], nil), do: compare_hands(hands, hand)
  defp compare_hands([hand | hands], best_hand) do
    combined_attributes =
      hand.attributes ++ best_hand.attributes

    highest_category =
      @order_of_hands
      |> Enum.find(fn
        category when is_list(category) ->
          category
          |> Enum.all?(fn c ->
            (c in hand.attributes) or (c in best_hand.attributes)
          end)

        category ->
          (category in hand.attributes) or (category in best_hand.attributes)
      end)

    new_best_hand =
      [hand, best_hand]
      |> Enum.filter(fn hand ->
        case highest_category do
          category when is_list(category) ->
            category
            |> Enum.all?(fn c -> c in hand.attributes end)

          category ->
            category in hand.attributes
        end
      end)
      |> (fn
        hands when length(hands) == 1 -> List.first(hands)
        hands when length(hands) == 2 -> break_tie(hands, highest_category)
      end).()

    compare_hands(hands, new_best_hand)
  end

  def break_tie([a, b], category) do
    IO.inspect binding()
  end
end
