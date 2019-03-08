defmodule Clock do
  defstruct hour: 0, minute: 0

  @minutes_per_hour 60
  @hours_per_rotation 12

  @doc """
  Returns a clock that can be represented as a string:

      iex> Clock.new(8, 9) |> to_string
      "08:09"
  """
  @spec new(integer, integer) :: Clock
  def new(hour, minute) do
    clock_minute = rem(minute, @minutes_per_hour)
    
    minute_carry = div(minute, @minutes_per_hour)

    clock_hour = rem((hour+minute_carry), @hours_per_rotation)

    %Clock{hour: clock_hour, minute: clock_minute}
  end

  @doc """
  Adds two clock times:

      iex> Clock.new(10, 0) |> Clock.add(3) |> to_string
      "10:03"
  """
  @spec add(Clock, integer) :: Clock
  def add(%Clock{hour: hour, minute: minute}, add_minute) do
  end

  @spec to_string(Clock) :: String.t()
  def to_string(%Clock{hour: h, minute: m}) do
    h_string = String.pad_leading("#{h}", 2, "0")
    m_string = String.pad_leading("#{m}", 2, "0")

    "#{h_string}:#{m_string}"
  end
end

defimpl String.Chars, for: Clock do
  def to_string(clock), do: Clock.to_string(clock)
end