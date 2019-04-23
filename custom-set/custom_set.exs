defmodule CustomSet do
  alias CustomSet, as: CS

  @opaque t :: %__MODULE__{map: map}

  defstruct map: %{}

  @spec new(Enum.t()) :: t
  def new(enumerable) do
    enumerable
    |> Enum.reduce(%CS{}, fn e, set -> %{set | map: Map.put(set.map, e, true)} end)
  end

  @spec empty?(t) :: boolean
  def empty?(custom_set) do
    Map.equal?(custom_set.map, %{})
  end

  @spec contains?(t, any) :: boolean
  def contains?(custom_set, element) do
    Map.has_key?(custom_set.map, element)
  end

  @spec subset?(t, t) :: boolean
  def subset?(custom_set_1, custom_set_2) do
    custom_set_2_elements = Map.keys(custom_set_2.map)

    custom_set_1.map
    |> Map.keys()
    |> Enum.all?(fn element ->
      element in custom_set_2_elements
    end)
  end

  @spec disjoint?(t, t) :: boolean
  def disjoint?(custom_set_1, custom_set_2) do
    custom_set_2_elements = Map.keys(custom_set_2.map)

    custom_set_1.map
    |> Map.keys()
    |> Enum.any?(fn element ->
      element in custom_set_2_elements
    end)
    |> Kernel.not
  end

  @spec equal?(t, t) :: boolean
  def equal?(custom_set_1, custom_set_2) do
    custom_set_1.map == custom_set_2.map
  end

  @spec add(t, any) :: t
  def add(custom_set, element) do
    %{custom_set | map: Map.put(custom_set.map, element, true)}
  end

  @spec intersection(t, t) :: t
  def intersection(custom_set_1, custom_set_2) do
    custom_set_2_elements = Map.keys(custom_set_2.map)

    custom_set_1.map
    |> Map.keys()
    |> Enum.filter(fn e ->
      e in custom_set_2_elements
    end)
    |> new()
  end

  @spec difference(t, t) :: t
  def difference(custom_set_1, custom_set_2) do
    difference_map =
      custom_set_2.map
      |> Map.keys()
      |> Enum.reduce(custom_set_1.map, fn e, map ->
        Map.delete(map, e)
      end)

    %{custom_set_1 | map: difference_map}
  end

  @spec union(t, t) :: t
  def union(custom_set_1, custom_set_2) do
    union_map =
      custom_set_2.map
      |> Map.keys()
      |> Enum.reduce(custom_set_1.map, fn e, map ->
        Map.put(map, e, true)
      end)

    %{custom_set_1 | map: union_map}
  end
end
