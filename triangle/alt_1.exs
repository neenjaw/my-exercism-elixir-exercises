defmodule Triangle do
  @type kind :: :equilateral | :isosceles | :scalene

  @doc """
  Return the kind of triangle of a triangle with 'a', 'b' and 'c' as lengths.
  """
  @spec kind(number, number, number) :: { :ok, kind } | { :error, String.t }
  def kind(a, b, c) when a <= 0 or b <= 0 or c <= 0 do
    { :error, "all side lengths must be positive" }
  end

  def kind(a, b, c) when a + b <= c or a + c <= b or b + c <= a do
    { :error, "side lengths violate triangle inequality" }
  end

  def kind(a,b,c) do
    case length(Enum.uniq([a,b,c])) do
      1 -> { :ok, :equilateral }
      2 -> { :ok, :isosceles }
      3 -> { :ok, :scalene }
    end
  end

  # def kind(a, b, c) do
  #   cond do
  #     Enum.any?([a, b, c], &(&1 <= 0))
  #       -> { :error, "all side lengths must be positive" }
  #     # sum of any two sides cannot be less or equal to third side
  #     Enum.any?([a,b,c], &(Enum.sum([a,b,c] -- [&1]) <= &1))
  #       -> { :error, "side lengths violate triangle inequality" }
  #     Enum.uniq([a,b,c]) |> Enum.count == 1
  #       -> { :ok, :equilateral}
  #     Enum.uniq([a,b,c]) |> Enum.count == 2
  #       -> { :ok, :isosceles }
  #     true -> { :ok, :scalene }
  #   end
  # end

end