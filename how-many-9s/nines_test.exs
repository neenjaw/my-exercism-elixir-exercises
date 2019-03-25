if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("nines.exs", __DIR__)
end

ExUnit.start()
ExUnit.configure(exclude: :pending, trace: true)


defmodule NinesTest do
  use ExUnit.Case

  @upper_limit 1_000_000_000_000

  def next_nine_count({n, nine_count}) do
    next_nine_count = 
      (n+1)
      |> Integer.digits
      |> Enum.reduce(nine_count, fn
        9, acc -> acc + 1
        _, acc -> acc 
      end)

    {(n+1), next_nine_count}
  end

  test "no difference iterate" do
    {n, last_counted_nine, last_counted_nine_by_bound} =
      Stream.iterate({0, 0}, &next_nine_count/1)
      |> Stream.map(fn {n, counted_nines} -> {n, counted_nines, Nines.count_nines_by_lower_bound(n)} end)
      |> Stream.drop_while(fn {n, counted_nines, counted_nines_by_bound} -> 
        IO.puts("n: #{n}, counted: #{counted_nines}, calculated: #{counted_nines_by_bound}")

        (counted_nines == counted_nines_by_bound) and (n < @upper_limit)
      end)
      |> Stream.take(1)
      |> Enum.to_list
      |> List.first

    assert last_counted_nine == last_counted_nine_by_bound
  end

  @tag :pending
  test "no difference 100" do
    n = 1..100000
    |> Stream.map(fn n -> {n, Nines.count_nines(n), Nines.count_nines_by_lower_bound(n)} end)
    |> Stream.drop_while(fn {n,a,b} -> 
      n
      |> IO.inspect(label: "Pulling next solution for n")

      a == b 
    end)
    |> Stream.map(fn {n,_,_} -> n end)
    |> Stream.take(1)
    |> Enum.to_list
    |> List.first

    assert (n == nil) or ({n, Nines.count_nines_by_lower_bound(n)} == {n, Nines.count_nines(n)})
  end
end
