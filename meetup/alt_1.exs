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

  @teenth_dates 13..19
  @weekdays %{monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7}
  @order %{first: 1, second: 2, third: 3, fourth: 4}

  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(pos_integer, pos_integer, weekday, schedule) :: :calendar.date()
  def meetup(year, month, weekday, schedule) do
    case schedule do
      :teenth ->
        wday_number = Map.get(@weekdays, weekday)

        date =
          Enum.find(@teenth_dates, fn date ->
            wday_number == :calendar.day_of_the_week({year, month, date})
          end)

        {year, month, date}

      :last ->
        dates_from_month_and_weekday(year, month, weekday) |> List.last()

      schedule when schedule in ~w(first second third fourth)a ->
        dates_from_month_and_weekday(year, month, weekday)
        |> Enum.at(Map.get(@order, schedule) - 1)
    end
  end

  defp dates_from_month_and_weekday(year, month, weekday) do
    last_day_of_the_month = :calendar.last_day_of_the_month(year, month)
    wday_number = Map.get(@weekdays, weekday)

    Enum.map(1..last_day_of_the_month, fn day ->
      {year, month, day}
    end)
    |> Enum.filter(fn date ->
      :calendar.day_of_the_week(date) == wday_number
    end)
  end
end