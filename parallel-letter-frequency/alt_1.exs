defmodule Frequency do
  @doc """
  Count letter frequency in parallel.

  Returns a map of characters to frequencies.

  The number of worker processes to use can be set with 'workers'.
  """
  @spec frequency([String.t()], pos_integer) :: map
  def frequency([], _workers), do: %{}

  def frequency(texts, workers) when is_list(texts) do
    texts
    |> Enum.map(&String.downcase/1)
    |> Enum.map(&String.replace(&1, ~r/[\s\,\d]/, ""))
    |> Enum.flat_map(&String.split(&1, "\n", trim: true))
    |> process(workers)
    |> Enum.reduce(%{}, &merge/2)
  end

  @spec counts(String.t()) :: map
  def counts(line) when is_binary(line) do
    line
    |> String.graphemes()
    |> Enum.reduce(%{}, fn g, acc ->
      Map.update(acc, g, 1, &(&1 + 1))
    end)
  end

  @spec process([String.t()], pos_integer) :: map
  defp process(lines, n_workers) do
    workers = create_workers(n_workers)

    lines
    |> Enum.zip(Stream.cycle(workers))
    |> Enum.map(&assign_to_worker/1)
    |> Enum.map(&receive_result/1)
  end

  @spec merge(map, map) :: map
  def merge(map1, map2) do
    Enum.reduce(Map.keys(map2), map1, fn k, m ->
      Map.update(m, k, map2[k], &(&1 + map2[k]))
    end)
  end

  def assign_to_worker({line, worker}) do
    send(worker, {self(), {:task, &counts/1, [line]}})
  end

  def receive_result(_) do
    receive do
      {:result, res} -> res
    end
  end

  @doc """
  A generic worker for tasks.

  just give it a function and its args and it will execute the function with those args
  and resturn the result
  """
  def worker do
    receive do
      {sender, {:task, fun, args}} ->
        send(sender, {:result, apply(fun, args)})
        worker()
    end
  end

  @spec spawn_worker(any) :: pid
  def spawn_worker(_), do: spawn_link(fn -> worker() end)

  @spec create_workers(pos_integer) :: [pid]
  defp create_workers(n_workers), do: 1..n_workers |> Enum.map(&spawn_worker/1)
end