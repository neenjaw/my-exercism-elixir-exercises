defmodule Poker.Hand do
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

  defp add_card(hand = %Poker.Hand{}, card_string) do
    {value, suit} = String.split_at(card_string, -1)

    hand
    |> add_card_value(value)
    |> add_card_suit(suit)
    |> add_card_to_list(card_string)
    |> increment_card_count()
  end

  # Add the value to the hand struct
  defp add_card_value(hand, "A") do
    # hand = update_in(hand.value_map[1], &(&1 + 1))
    update_in(hand.value_map[14], &(&1 + 1))
  end
  defp add_card_value(hand, value) when value in ~w(2 3 4 5 6 7 8 9 10) do
    n = String.to_integer(value)
    update_in(hand.value_map[n], &(&1 + 1))
  end
  defp add_card_value(hand, "J"), do: update_in(hand.value_map[11], &(&1 + 1))
  defp add_card_value(hand, "Q"), do: update_in(hand.value_map[12], &(&1 + 1))
  defp add_card_value(hand, "K"), do: update_in(hand.value_map[13], &(&1 + 1))

  # Add the suit to the hand struct
  defp add_card_suit(hand, "H"), do: update_in(hand.suit_map[:heart],   &(&1 + 1))
  defp add_card_suit(hand, "C"), do: update_in(hand.suit_map[:club],    &(&1 + 1))
  defp add_card_suit(hand, "D"), do: update_in(hand.suit_map[:diamond], &(&1 + 1))
  defp add_card_suit(hand, "S"), do: update_in(hand.suit_map[:spade],   &(&1 + 1))

  # Add the card to the hand struct
  defp add_card_to_list(hand, card), do: update_in(hand.card_list, &([card | &1]))

  defp increment_card_count(hand, amount \\ 1), do: update_in(hand.card_count, &(&1 + amount))
end

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

  defguard is_regular_sequence(a,b,c,d,e)
    when (b == a+1 and c == b+1 and d == c+1 and e ==d+1)

  defguard is_low_ace_sequence(a,b,c,d,e)
    when (a == 2 and b == 3 and c == 4 and d == 5 and e == 14)
    or (a == 14 and b == 2 and c == 3 and d == 4 and e == 5)

  defguard is_sequence(a,b,c,d,e)
    when is_regular_sequence(a,b,c,d,e) or is_low_ace_sequence(a,b,c,d,e)

  @doc """
  Score and rank the hands, returning the highest hand
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    hands
    |> analyse_each_hand()
    |> compare_hands()
    |> Enum.map(fn hand -> hand.card_list end)
  end

  defp analyse_each_hand(hands) do
    hands
    |> Enum.map(fn hand ->
      hand
      |> Poker.Hand.new()
      |> add_attributes()
    end)
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
    |> Enum.filter(fn {_suit, count} -> if count == 5, do: true, else: false end)
    |> (fn
      [] -> hand
      [{_suit, 5}] -> update_in(hand.attributes, &([:flush | &1]))
    end).()
  end

  defp add_x_of_a_kind_attr?(hand = %Poker.Hand{}) do
    # Create a list of tuples of the value with their counts
    hand.value_map
    |> Map.to_list()
    |> Enum.sort(fn
      {_v1, x}, {_v2, y} when x >= y -> true
      _, _ -> false
    end)

    # discard the tuples with zero-count
    |> Enum.take_while(fn {_v, c} -> c > 0 end)

    # determine the x-of-a-kind attribute
    |> case do
      [{_, 4}, {_, 1}] -> :four_of_a_kind
      [{_, 3}, {_, 2}] -> :full_house
      [{_, 3}, {_, 1}, {_, 1}] -> :three_of_a_kind
      [{_, 2}, {_, 2}, {_, 1}] -> :two_pair
      [{_, 2}, {_, 1}, {_, 1}, {_, 1}] -> :one_pair
      [{_, 1}, {_, 1}, {_, 1}, {_, 1}, {_, 1}] -> :high_card
      _ -> raise ArgumentError, "Hand can't have more than 5 cards"
    end
    |> case do
      attr -> update_in(hand.attributes, &([attr | &1]))
    end
  end

  defp add_straight_attr?(hand = %Poker.Hand{}) do
    # Make a list of tuples of all the cards values with 1 occurence
    hand.value_map
    |> Map.to_list()
    |> Enum.filter(fn
      {_, 1} -> true
      _      -> false
    end)

    # If there isn't five single cards, then return the hand
    # If there is five cards, then determine if they are a sequence
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

  @ordered_list_of_hands [
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

  defp compare_hands([hand]), do: [hand]
  defp compare_hands(hands) do
    # Find the highest category of hand by using `Enum.find` to return the first
    # element of the @ordered_list_of_hands that is present in a hand's attributes.
    highest_hand_type =
      @ordered_list_of_hands
      |> Enum.find(fn
        # when it is a list of attributes representing a combination
        # (eg, :straight, :flush)
        attributes when is_list(attributes) ->
          Enum.any?(hands, fn hand ->
            Enum.all?(attributes, fn c -> c in hand.attributes end)
          end)

        # is a single atom attribute
        attribute ->
          Enum.any?(hands, fn hand -> attribute in hand.attributes end)
      end)

    # Now filter the hands based on the highest type.  If only one hand remains, we have
    # found the best hand.  If more than one, need to break the tie if possible.
    hands
    |> Enum.filter(fn hand ->
      case highest_hand_type do
        attributes when is_list(attributes) ->
          attributes
          |> Enum.all?(fn c -> c in hand.attributes end)

        attribute ->
          attribute in hand.attributes
      end
    end)
    |> (fn
      [hand] -> [hand]
      hands  -> break_tie(hands, highest_hand_type)
    end).()
  end




  # Takes a list of %Poker.Hand structs that assume they all contain the attribute
  # that matches the passed category atom
  defp break_tie([hand], _category),
    do: [hand]
  defp break_tie(hands, category)
    when is_list(hands),
    do: do_break_tie(hands, category)

  defp do_break_tie(hands, [:straight, :flush]), do: do_break_tie(hands, :high_card)
  defp do_break_tie(hands, :flush),              do: do_break_tie(hands, :high_card)

  defp do_break_tie(hands, :straight) do
    # If the hand is a straight with the Ace as a low card:
    #  - remove the Ace from the high position,
    #  - add it to the low position
    hands
    |> Enum.map(fn hand ->
      value_series =
        hand.value_map
        |> Map.to_list()
        |> Enum.filter(fn {_v, c} -> c > 0 end)
        |> Enum.map(fn {v, _c} -> v end)
        |> Enum.sort()

      unless value_series == [2,3,4,5,14] do
        hand
      else
        value_map =
          hand.value_map
          |> Map.delete(14)
          |> Map.put(1, 1)

        %{hand | value_map: value_map}
      end
    end)

    # now can break the tie by high card
    |> do_break_tie(:high_card)
  end

  defp do_break_tie(hands, :high_card) do
    # Create a list of tuples where each element is the ordered nth card in the hand
    # eg) [
    #       {{value_high, hand_1}, {value_high, hand_2}},
    #       {{value_next, hand_1}, {value_next, hand_2}},
    #       etc..
    #     ]
    high_card_tuples =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        # for each hand's value_map, filter card
        # values that arent in the hand. Order by decreasing
        # value, and create a tuple with the hand's index
        hand.value_map
        |> Map.to_list
        |> Enum.filter(fn
            {_value, 0}   -> false
            _value_count -> true
        end)
        |> Enum.sort(&(&1 >= &2))
        |> Enum.map(fn {v, _c} -> {v, index} end)
      end)
      |> Enum.zip()

    do_filter_to_best_hand(high_card_tuples)
    |> Enum.map(fn index -> Enum.at(hands, index) end)
  end

  defp do_break_tie(hands, :full_house) do
    full_house_tuples =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        # transform the hand into a tuple of the index and
        # another tuple consisting of the full house values for each
        # hand.  ex) {index, {3_of_a_kind_value, pair_value}}
        hand.value_map
        |> Map.to_list()
        |> Enum.filter(fn {_v, c} -> (c == 3) or (c == 2) end)
        |> Enum.sort(fn {_v1, c1}, {_v2, c2} -> c1 >= c2 end)
        |> (fn [{v1, 3}, {v2, 2}] -> {index, {v1, v2}} end).()
      end)

      # sort by hand values
      |> Enum.sort(fn {_i1, full_house_a}, {_i2, full_house_b} ->
        full_house_a >= full_house_b
      end)

    {_, highest_full_house} = List.first(full_house_tuples)

    # filter all the hands to compare them to the highest_hand
    # then get the hands to return
    full_house_tuples
    |> Enum.filter(fn {_i, v} -> v == highest_full_house end)
    |> Enum.map(fn {i, _} -> Enum.at(hands, i) end)
  end

  defp do_break_tie(hands, :two_pair) do
    two_pair_tuples =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        # Transform hand into a tuple representing the hand:
        # ex) {index, {highest_pair_value, next_pair_value, kicker_value}}
        hand.value_map
        |> Map.to_list()
        |> Enum.filter(fn {_v, c} -> (c == 2) or (c == 1) end)

        # sort by the count or by the value if the count is 2
        |> Enum.sort(fn
          { v1,  2}, { v2,  2} -> v1 >= v2
          {_v1, c1}, {_v2, c2} -> c1 >= c2
        end)
        |> (fn [{v1, 2}, {v2, 2}, {v3, 1}] -> {index, {v1, v2, v3}} end).()
      end)
      |> Enum.sort(fn {_i1, two_pair_a}, {_i2, two_pair_b} -> two_pair_a >= two_pair_b end)

    {_, highest_two_pair} = List.first(two_pair_tuples)

    two_pair_tuples
    |> Enum.filter(fn {_i, v} -> v == highest_two_pair end)
    |> Enum.map(fn {i, _} -> Enum.at(hands, i) end)
  end

  defp do_break_tie(hands, :four_of_a_kind),  do: do_break_tie_n_of_a_kind(hands, 4)
  defp do_break_tie(hands, :three_of_a_kind), do: do_break_tie_n_of_a_kind(hands, 3)
  defp do_break_tie(hands, :one_pair),        do: do_break_tie_n_of_a_kind(hands, 2)

  defp do_break_tie_n_of_a_kind(hands, n) do
    # Create a tuple with the value of the x-of-a-kind, the index of the hand,
    # and the hand with the remaining cards in the value map if needed to compare
    # to break a tie
    separated_hands =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        value_list = Map.to_list(hand.value_map)

        n_of_a_kind_value =
          value_list
          |> Enum.find(fn {_v, count} -> count == n end)
          |> (fn {value, ^n} -> value end).()

        value_map =
          value_list
          |> Enum.filter(fn {_v, count} -> ((count != n) or (count != 0)) end)
          |> Map.new

        {index, n_of_a_kind_value, value_map}
      end)

    {_index, value_max, _remaining} =
      separated_hands
      |> Enum.max_by(fn {_index, v, _remaining} -> v end)

    separated_hands
    |> Enum.filter(fn {_index, v, _remaining} -> v == value_max end)
    |> Enum.map(fn {index, _, remaining_values} ->
      hand = Enum.at(hands, index)

      %{hand | value_map: remaining_values}
    end)
    |> do_break_tie(:high_card)
  end

  # Take the card tuples created by `do_break_tie(hands, :high_card)`
  # compare the first element by its highest found value
  # take all the hands that have that value, filtering the rest out
  # then if there are multiple hands still competing recursively
  # check subsequent cards.  If no more cards, and multiple, there
  # is a tie.
  defp do_filter_to_best_hand(high_card_tuples) do

    {highest_card_value, _index} =
      high_card_tuples
      |> List.first
      |> Tuple.to_list()
      |> Enum.max_by(fn {v, _index} -> v end)

    highest_card_hands =
      high_card_tuples
      |> List.first()
      |> Tuple.to_list()
      |> Enum.filter(fn {v, _index} -> v == highest_card_value end)

    case highest_card_hands do
      # Only one tuple, return that index
      [{_, index}] -> [index]

      # if more than one tuple
      winners ->
        winner_indexes =
          winners
          |> Enum.map(fn {_, index} -> index end)

        high_card_tuples
        # drop to look at the next highest card
        |> Enum.drop(1)
        |> case do
          # no more cards? then we have a tie
          [] -> winner_indexes

          # check subsequent cards for tie breaking card
          remaining_cards ->
            remaining_cards
            # take out the cards with indexes of hand that have been ruled out
            |> Enum.map(fn next_high_cards ->
              next_high_cards
              |> Tuple.to_list()
              |> Enum.filter(fn {_, index} -> index in winner_indexes end)
              |> List.to_tuple()
            end)

            # Take the remaining cards, and see if there is a further winner
            |> do_filter_to_best_hand()
        end
    end
  end
end
