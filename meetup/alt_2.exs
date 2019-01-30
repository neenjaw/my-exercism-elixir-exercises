defmodule Meetup do
  @moduledoc """
  Calculate meetup dates.
  """

  @type weekday ::
          :monday
          | :tuesday
          | :wednesday
          | :thursday
          | :friday
          | :saturday
          | :sunday

  @type schedule :: :first | :second | :third | :fourth | :last | :teenth

  @daynum %{
    monday: 1,
    tuesday: 2,
    wednesday: 3,
    thursday: 4,
    friday: 5,
    saturday: 6,
    sunday: 7
  }

  @day_ranges %{
    first: 1..7,
    second: 8..14,
    third: 15..21,
    fourth: 22..28,
    teenth: 13..19,
    last: 31..21
  }

  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(pos_integer, pos_integer, weekday, schedule) :: :calendar.date()
  def meetup(year, month, weekday, schedule) do
    date = Enum.find(@day_ranges[schedule], &wday?(weekday, {year, month, &1}))
    {year, month, date}
  end

  @spec wday?(weekday, :calendar.date()) :: boolean
  defp wday?(weekday, {year, month, date}) do
    Calendar.ISO.valid_date?(year, month, date) and
      Calendar.ISO.day_of_week(year, month, date) == @daynum[weekday]
  end
end