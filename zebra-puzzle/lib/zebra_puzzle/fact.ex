defmodule ZebraPuzzle.Fact do
  @enforce_keys [:house_attributes]
  defstruct [:house_attributes, constraints: []]

  def new(%{house_attributes: house, constraints: constraints}),
    do: %__MODULE__{house_attributes: house, constraints: constraints}

  def new(%{house_attributes: house}), do: %__MODULE__{house_attributes: house}

  @house_facts [
    # Facts from the problem description
    %{house_attributes: %{nationality: :english, color: :red}},
    %{house_attributes: %{nationality: :spaniard, pet: :dog}},
    %{house_attributes: %{drink: :coffee, color: :green}},
    %{
      house_attributes: %{color: :green},
      constraints: [min_position: 1, left_neighbour: %{color: :ivory}]
    },
    %{house_attributes: %{nationality: :ukrainian, drink: :tea}},
    %{house_attributes: %{brand: :old_gold, pet: :snail}},
    %{house_attributes: %{brand: :kools, color: :yellow}},
    %{house_attributes: %{drink: :milk, position: 2}},
    %{
      house_attributes: %{nationality: :norwegian, position: 0},
      constraints: [right_neighbour: %{color: :blue}]
    },
    %{
      house_attributes: %{brand: :chesterfields},
      constraints: [neighbour: %{pet: :fox}]
    },
    %{
      house_attributes: %{brand: :kools},
      constraints: [neighbour: %{pet: :horse}]
    },
    %{house_attributes: %{brand: :lucky_strike, drink: :orange_juice}},
    %{house_attributes: %{nationality: :japanese, brand: :parliaments}},

    # Free variables
    %{house_attributes: %{color: :ivory}},
    %{house_attributes: %{color: :blue}},
    %{house_attributes: %{pet: :fox}},
    %{house_attributes: %{pet: :horse}},
    %{house_attributes: %{pet: :zebra}},
    %{house_attributes: %{drink: :water}}
  ]

  def house_facts(), do: @house_facts |> Enum.map(&new(&1))
end
