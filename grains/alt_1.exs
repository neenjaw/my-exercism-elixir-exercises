defmodule Grains do
  def square(number) when number < 1 or number > 64 do
    {:error, "The requested square must be between 1 and 64 (inclusive)"}
  end

  def square(n), do: {:ok, do_square(n)}
  defp do_square(1), do: 1
  defp do_square(n), do: 2 * do_square(n - 1)

  def total, do: {:ok, do_total(64)}
  defp do_total(1), do: do_square(1)
  defp do_total(n), do: do_square(n) + do_total(n - 1)
end