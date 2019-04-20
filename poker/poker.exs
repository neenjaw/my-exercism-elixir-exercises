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
      # hand = update_in(hand.value_map[1], &(&1 + 1))
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

  defguardp is_sequence(a,b,c,d,e)
    when (a == 14 and b == 2 and c == 3 and d == 4 and e == 5)
    or (b == a+1 and c == b+1 and d == c+1 and e ==d+1)

  @doc """
  Score and rank the hands, returning the highest hand
  """
  @spec best_hand(list(list(String.t()))) :: list(list(String.t()))
  def best_hand(hands) do
    highest_hands =
      hands
      |> analyse_hands()
      |> compare_hands()

    highest_hands
    |> Enum.map(fn hand -> hand.card_list end)
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

  @ordered_list_of_hands [
    [:straight, :flush], #
    :four_of_a_kind,
    :full_house,
    :flush,              #
    :straight,           #
    :three_of_a_kind,
    :two_pair,
    :one_pair,
    :high_card           #
  ]

  defp compare_hands([hand]), do: [hand]
  defp compare_hands(hands) do
    # Find the highest category of hand by using `Enum.find` to return the first
    # element of the @ordered_list_of_hands that is present in the hands.
    # Because a straight flush is a combination of attributes, the code compares
    # a list of attributes or single attributes.
    highest_hand_type =
      @ordered_list_of_hands
      |> Enum.find(fn
        # If any hand has all of the attributes, then this is the highest type of hand
        attributes when is_list(attributes) ->
          Enum.any?(hands, fn hand ->
            Enum.all?(attributes, fn c -> c in hand.attributes end)
          end)

        # If any hand has the attribute, then we have found
        attribute ->
          Enum.any?(hands, fn hand -> attribute in hand.attributes end)
      end)

    # Now filter the hands based on the highest type.  If only one hand remains, we have
    # found the best hand.  If more than one, need to break the tie if possible.
    best_hands =
      hands
      # |> IO.inspect(label: "original")
      |> Enum.filter(fn hand ->
        case highest_hand_type do
          attributes when is_list(attributes) ->
            attributes
            |> Enum.all?(fn c -> c in hand.attributes end)

          attribute ->
            attribute in hand.attributes
        end
      end)
      # |> IO.inspect(label: "pre_break")
      |> (fn
        [hand] -> [hand]
        hands -> break_tie(hands, highest_hand_type)
      end).()
      # |> IO.inspect(label: "post_break")
  end

  def break_tie(hands, category) when is_list(hands) and length(hands) > 1 do
    do_break_tie(hands, category)
  end

  def do_break_tie(hands, [:straight, :flush]), do: do_break_tie(hands, :high_card)
  def do_break_tie(hands, :flush),              do: do_break_tie(hands, :high_card)
  def do_break_tie(hands, :straight),           do: do_break_tie(hands, :high_card)
  def do_break_tie(hands, :high_card) do
    high_card_tuples =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        # create a list of the cards in the hand,
        # ordered by decreasing value
        hand.value_map
        |> Map.to_list
        |> Enum.filter(fn
            {value, 0}   -> false
            _value_count -> true
        end)
        |> Enum.sort(&(&1 >= &2))
        |> Enum.map(fn {v,c} -> {v, index} end)
      end)
      |> Enum.zip()

    max_high_card_value =
      high_card_tuples
      |> List.first
      |> Tuple.to_list()
      |> Enum.max_by(fn {v, _index} -> v end)
      |> Kernel.elem(0)
      |> IO.inspect(label: "267")

    max_high_card_hands =
      high_card_tuples
      |> List.first()
      |> Tuple.to_list()
      |> Enum.filter(fn {v, _index} -> v == max_high_card_value end)
      |> IO.inspect(label: "275")

    # TODO: THIS IS MESSED
    case max_high_card_hands do
      [{_, index}] -> [Enum.at(hands, index)]

      hands ->
    end

    |> (fn _ -> raise ErlangError end).()
    |> case do
      # If there is a tie, return the hands
      :tie -> hands

      # If there is a card that breaks the tie
      tie_breaker_card ->
        max_value =
          tie_breaker_card
          |> Tuple.to_list()
          |> Enum.map(fn {v, _} -> v end)
          |> Enum.max()

        # find the hands that contain the card that breaks the tie
        max_hands =
          tie_breaker_card
          |> Tuple.to_list()
          |> Enum.filter(fn
            {^max_value, _} -> true
            _not_max_value  -> false
          end)
          |> case do
            # If only one hand, then done
            [{_v, index}] ->
              [Enum.at(hands, index)]

            # If there are more than one hand, check those hands for a subsequent tie
            max_hands ->
              max_hands
              |> Enum.map(fn {_v, index} -> Enum.at(hands, index) end)
              |> do_break_tie(:high_card)
          end
    end
  end

  def do_break_tie(hands, :four_of_a_kind) do
    # Create a tuple with the value of the four-of-a-kind, the index of the hand,
    # and the hand with the remaining 1 card in the value map if needed to compare
    # to break a tie
    separated_hands =
      separate_kind_from_remainder_cards(hands, 4)

    four_of_a_kind_max =
      find_kind_max_value(separated_hands)

    best_hands =
      find_all_hands_with_max_value(separated_hands, four_of_a_kind_max)

    handle_remainder(hands, best_hands)
  end

  def do_break_tie(hands, :three_of_a_kind) do
    # Create a tuple with the value of the three-of-a-kind, the index of the hand,
    # and the hand with the remaining 1 card in the value map if needed to compare
    # to break a tie

    separated_hands =
      separate_kind_from_remainder_cards(hands, 3)

    three_of_a_kind_max =
      find_kind_max_value(separated_hands)

    best_hands =
      find_all_hands_with_max_value(separated_hands, three_of_a_kind_max)

    handle_remainder(hands, best_hands)
  end

  def do_break_tie(hands, :one_pair) do
    # Create a tuple with the value of the two-of-a-kind (pair), the index of the hand,
    # and the hand with the remaining 1 card in the value map if needed to compare
    # to break a tie
    separated_hands =
      separate_kind_from_remainder_cards(hands, 2)

    pair_max =
      find_kind_max_value(separated_hands)

    best_hands =
      find_all_hands_with_max_value(separated_hands, pair_max)

    handle_remainder(hands, best_hands)
  end

  def do_break_tie(hands, :full_house) do
    full_house_tuples =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        hand.value_map
        |> Map.to_list()
        |> Enum.filter(fn {_v, c} -> (c == 3) or (c == 2) end)
        |> Enum.sort(fn {_v1, c1}, {_v2, c2} -> c1 >= c2 end)
        |> (fn [{v1, 3}, {v2, 2}] -> {index, {v1, v2}} end).()
      end)
      |> Enum.sort(fn {_i1, v1}, {_i2, v2} -> v1 >= v2 end)

    full_house_max_tuples =
      full_house_tuples
      |> Enum.filter(fn {_i, v} ->
        {_, highest_v} = List.first(full_house_tuples)

        v == highest_v
      end)
      |> Enum.map(fn {i, _} -> Enum.at(hands, i) end)
  end

  def do_break_tie(hands, :two_pair) do
    two_pair_tuples =
      hands
      |> Enum.with_index()
      |> Enum.map(fn {hand, index} ->
        hand.value_map
        |> Map.to_list()
        |> Enum.filter(fn {_v, c} -> (c == 2) or (c == 1) end)
        |> Enum.sort(fn
          { v1,  2}, { v2,  2} -> v1 >= v2
          {_v1, c1}, {_v2, c2} -> c1 >= c2
        end)
        |> (fn [{v1, 2}, {v2, 2}, {v3, 1}] -> {index, {v1, v2, v3}} end).()
      end)
      |> Enum.sort(fn {_i1, v1}, {_i2, v2} -> v1 >= v2 end)

    two_pair_max_tuples =
      two_pair_tuples
      |> Enum.filter(fn {_i, v} ->
        {_, highest_v} = List.first(two_pair_tuples)

        v == highest_v
      end)
      |> Enum.map(fn {i, _} -> Enum.at(hands, i) end)
  end

  def separate_kind_from_remainder_cards(hands, x) do
    hands
    |> Enum.with_index()
    |> Enum.map(fn {hand, index} ->
      value_list = Map.to_list(hand.value_map)

      x_of_a_kind_value =
        value_list
        |> Enum.find(fn {_v, c} -> c == x end)
        |> (fn {v, ^x} -> v end).()

      remaining_cards_value_map =
        value_list
        |> Enum.filter(fn {_v, c} -> ((c != x) or (c != 0)) end)
        |> Map.new

      {x_of_a_kind_value, index, %{hand | value_map: remaining_cards_value_map}}
    end)
  end

  def find_kind_max_value(separated_hands) do
    # Get the max four-of-a-kind
    separated_hands
    |> Enum.max_by(fn {v, _index, _hand} -> v end)
    |> elem(0)
  end

  def find_all_hands_with_max_value(separated_hands, max) do
    Enum.filter(separated_hands, fn {v, _index, _hand} -> v == max end)
  end

  def handle_remainder(hands, [{_v, index, _hand}]), do: [Enum.at(hands, index)]
  def handle_remainder(hands, high_hands) do
    break_tie_hands =
      high_hands
      |> Enum.map(fn {_, _, h} -> h end)
      |> do_break_tie(:high_card)

    # Once the tie breaker hands found, get the value of the tie-breaking card
    tie_breaker_value =
      break_tie_hands
      |> List.first()
      |> (fn hand -> hand.value_map end).()
      |> Map.to_list()
      |> List.first()
      |> (fn {v, 1} -> v end).()

    # Use the value of the tie breaking card to get the indexes of the hands to return
    high_hands
    |> Enum.filter(fn {_, _, hand} -> hand.value_map[tie_breaker_value] == 1 end)
    |> Enum.map(fn {_, index, _hand} -> Enum.at(hands, index) end)
  end

end
