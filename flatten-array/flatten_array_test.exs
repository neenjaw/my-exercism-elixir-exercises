if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("flatten_array.exs", __DIR__)
end

ExUnit.start()
ExUnit.configure(exclude: :pending, trace: true)

defmodule FlattenArrayTest do
  use ExUnit.Case

  @tag :pending
  test "returns original list if there is nothing to flatten" do
    assert FlattenArray.flatten([1, 2, 3]) == [1, 2, 3]
  end

  @tag :pending
  test "flattens an empty nested list" do
    assert FlattenArray.flatten([[]]) == []
  end

  @tag :pending
  test "flattens a nested list" do
    assert FlattenArray.flatten([1, [2, [3], 4], 5, [6, [7, 8]]]) == [1, 2, 3, 4, 5, 6, 7, 8]
  end

  @tag :pending
  test "removes nil from list" do
    assert FlattenArray.flatten([1, nil, 2]) == [1, 2]
  end

  @tag :pending
  test "removes nil from a nested list" do
    assert FlattenArray.flatten([1, [2, nil, 4], 5]) == [1, 2, 4, 5]
  end

  @tag :pending
  test "returns an empty list if all values in nested list are nil" do
    assert FlattenArray.flatten([nil, [nil], [nil, [nil]]]) == []
  end

  test "flatten very large sublist" do
    sub_list = 0..10_000 |> Enum.to_list()
    sub_list2 = 10_001..30_000 |> Enum.to_list()
    list = 30_001..2_000_000 |> Enum.to_list()

    assert FlattenArray.flatten([sub_list, sub_list2 |list]) == (0..2_000_000 |> Enum.to_list())
  end
end
