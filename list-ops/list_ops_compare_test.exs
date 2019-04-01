if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("list_ops.exs", __DIR__)
  Code.load_file("list_ops_body.exs", __DIR__)
end

ExUnit.start()
ExUnit.configure(exclude: :pending, trace: true)

defmodule ListOpsTest do
  alias ListOps, as: LT
  alias ListOpsBody, as: LB

  use ExUnit.Case

  defp odd?(n), do: rem(n, 2) == 1

  # @tag :pending
  test "LT - reverse of huge list" do
    assert LT.reverse(Enum.to_list(1..1_000_000)) == Enum.to_list(1_000_000..1)
  end

  # @tag :pending
  test "LT - map of huge list" do
    assert LT.map(Enum.to_list(1..1_000_000), &(&1 + 1)) == Enum.to_list(2..1_000_001)
  end

  # @tag :pending
  test "LT - filter of huge list" do
    assert LT.filter(Enum.to_list(1..1_000_000), &odd?/1) == Enum.map(1..500_000, &(&1 * 2 - 1))
  end

  # @tag :pending
  test "LT - reduce of huge list" do
    assert LT.reduce(Enum.to_list(1..1_000_000), 0, &(&1 + &2)) ==
             Enum.reduce(1..1_000_000, 0, &(&1 + &2))
  end

  # @tag :pending
  test "LT - append of huge lists" do
    assert LT.append(Enum.to_list(1..1_000_000), Enum.to_list(1_000_001..2_000_000)) ==
             Enum.to_list(1..2_000_000)
  end

  # @tag :pending
  test "LT - concat of huge list of small lists" do
    assert LT.concat(Enum.map(1..1_000_000, &[&1])) == Enum.to_list(1..1_000_000)
  end

  # @tag :pending
  test "LT - concat of small list of huge lists" do
    assert LT.concat(Enum.map(0..9, &Enum.to_list((&1 * 100_000 + 1)..((&1 + 1) * 100_000)))) ==
             Enum.to_list(1..1_000_000)
  end


  # @tag :pending
  test "LB - reverse of huge list" do
    assert LB.reverse(Enum.to_list(1..1_000_000)) == Enum.to_list(1_000_000..1)
  end

  # @tag :pending
  test "LB - map of huge list" do
    assert LB.map(Enum.to_list(1..1_000_000), &(&1 + 1)) == Enum.to_list(2..1_000_001)
  end

  # @tag :pending
  test "LB - filter of huge list" do
    assert LB.filter(Enum.to_list(1..1_000_000), &odd?/1) == Enum.map(1..500_000, &(&1 * 2 - 1))
  end

  # @tag :pending
  test "LB - reduce of huge list" do
    assert LB.reduce(Enum.to_list(1..1_000_000), 0, &(&1 + &2)) ==
             Enum.reduce(1..1_000_000, 0, &(&1 + &2))
  end

  # @tag :pending
  test "LB - append of huge lists" do
    assert LB.append(Enum.to_list(1..1_000_000), Enum.to_list(1_000_001..2_000_000)) ==
             Enum.to_list(1..2_000_000)
  end

  # @tag :pending
  test "LB - concat of huge list of small lists" do
    assert LB.concat(Enum.map(1..1_000_000, &[&1])) == Enum.to_list(1..1_000_000)
  end

  # @tag :pending
  test "LB - concat of small list of huge lists" do
    assert LB.concat(Enum.map(0..9, &Enum.to_list((&1 * 100_000 + 1)..((&1 + 1) * 100_000)))) ==
             Enum.to_list(1..1_000_000)
  end
end
