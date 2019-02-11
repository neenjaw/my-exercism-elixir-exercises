if !System.get_env("EXERCISM_TEST_EXAMPLES") do
  Code.load_file("nines.exs", __DIR__)
end

ExUnit.start()
ExUnit.configure(trace: true)

defmodule NinesTest do
  use ExUnit.Case

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
