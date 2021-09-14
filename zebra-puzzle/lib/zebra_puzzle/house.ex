defmodule ZebraPuzzle.House do
  require Helpers

  alias ZebraPuzzle.Fact

  @enforce_keys [:position]
  defstruct [
    :position,
    color: :unknown,
    nationality: :unknown,
    pet: :unknown,
    drink: :unknown,
    brand: :unknown,
    constraints: []
  ]

  Helpers.one_of_or_unknown(colors, ~w|red green ivory yellow blue|a)
  Helpers.one_of_or_unknown(nationalities, ~w|english ukrainian norwegian japanese spaniard|a)
  Helpers.one_of_or_unknown(pets, ~w|dog snail zebra horse fox|a)
  Helpers.one_of_or_unknown(drinks, ~w|orange_juice tea coffee milk water|a)
  Helpers.one_of_or_unknown(brands, ~w|old_gold kools chesterfields lucky_strike parliaments|a)
  Helpers.one_of_or_unknown(positions, [0, 1, 2, 3, 4])

  @type constraint ::
          {:min_position, 0, 1, 2, 3, 4}
          | {:neighbour, %__MODULE__{}}
          | {:left_neighbour, %__MODULE__{}}
          | {:right_neighbour, %__MODULE__{}}

  @type t :: %__MODULE__{
          color: colors(),
          nationality: nationalities(),
          pet: pets(),
          drink: drinks(),
          brand: brands(),
          position: positions(),
          constraints: [constraint()]
        }

  def new(%{} = params) do
    struct = struct(__MODULE__)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(params, k) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end

  def congruent?(%__MODULE__{} = house, %{} = attributes) do
    apply_attributes(house, attributes) != :error
  end

  def apply_fact(%__MODULE__{} = house, %Fact{} = fact) do
    house = %{house | constraints: house.constraints ++ fact.constraints}

    apply_attributes(house, fact.house_attributes)
  end

  defp apply_attributes(%__MODULE__{} = house, %{} = attributes) do
    Enum.reduce_while(attributes, house, fn {type, attribute}, house ->
      case Map.fetch(house, type) do
        {:ok, :unknown} -> {:cont, Map.put(house, type, attribute)}
        {:ok, ^attribute} -> {:cont, house}
        _ -> {:halt, :error}
      end
    end)
  end
end
