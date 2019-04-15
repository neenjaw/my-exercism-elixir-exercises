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
      card_count: 0
    ]

    def add_card(hand \\ %Poker.Hand{}, card_string) do
      {value, suit} = String.split_at(card_string, -1)

      hand
      |> add_card_value(value)
      |> add_card_suit(suit)
      |> add_card_to_list(card_string)
      |> increment_card_count()
    end

    def add_cards(hand \\ %Poker.Hand{}, card_string_list) do
      card_string_list
      |> Enum.reduce(hand, fn c, hand -> add_card(hand, c) end)
    end

    @doc """
    Add the value to the hand struct
    """
    defp add_card_value(hand, "A") do
      hand = update_in(hand.value_map[1], &(&1 + 1))
      hand = update_in(hand.value_map[14], &(&1 + 1))
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

  @doc """
  Score and rank the hands, returning the highest hand
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    analyse_hands(hands)
  end

  def analyse_hands(hands, results \\ [])
  def analyse_hands([hand | hands], results) do




    analyse_hands(hands, [nil | results])
  end

end
