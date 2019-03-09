defmodule Clock do
  defstruct hour: 0, minute: 0

  @type t() :: %__MODULE__{
    hour: pos_integer,
    minute: pos_integer,
  } 

  @minutes_per_hour 60
  @hours_per_day 24

  @doc """
  Returns a clock that can be represented as a string:

      iex> Clock.new(8, 9) |> to_string
      "08:09"
  """
  @spec new(integer, integer) :: Clock
  def new(hour, minute) do
    clock_minute = get_minute(minute)
    clock_hour = get_hour(hour, minute)

    %Clock{hour: clock_hour, minute: clock_minute}
  end

  @doc """
  Adds two clock times:

      iex> Clock.new(10, 0) |> Clock.add(3) |> to_string
      "10:03"
  """
  @spec add(Clock, integer) :: Clock
  def add(%Clock{hour: hour, minute: minute}, add_minute) do
    sum_minute = get_minute(minute, add_minute)

    # calculate the hour based on the minute delta
    sum_hour = get_hour(hour, (minute + add_minute))

    %Clock{hour: sum_hour, minute: sum_minute}
  end

  # calculate the current minute of the clock
  defp get_minute(minute \\ 0, offset) do
    case rem((minute + offset), @minutes_per_hour) do
      m when m < 0 -> m + @minutes_per_hour
      m -> m 
    end
  end

  # calculate the current hour of the clock
  defp get_hour(hour, minute) do
    # account for negate minute and not a full hour
    partial_hour_adjust = 
      case rem(minute, @minutes_per_hour) do
        r when r < 0 -> -1
        _ -> 0
      end

    # calculate amount to adjust hour based on minute supplied
    hour_adjust = div(minute, @minutes_per_hour)

    # get the current hour, if negative, then adjust to make a positive
    rem((hour + hour_adjust + partial_hour_adjust), @hours_per_day)
      |> case do
        h when h < 0 -> h + @hours_per_day
        h -> h
      end
  end


  @doc """
  Display the clock as a string:

      iex> Clock.new(10, 0) |> to_string
      "10:00"
  """
  @spec to_string(Clock) :: String.t()
  def to_string(%Clock{hour: h, minute: m}) do
    hh = String.pad_leading("#{h}", 2, "0")
    mm = String.pad_leading("#{m}", 2, "0")

    "#{hh}:#{mm}"
  end
end

# implement the to_string protocol for Clock
defimpl String.Chars, for: Clock do
  def to_string(clock), do: Clock.to_string(clock)
end