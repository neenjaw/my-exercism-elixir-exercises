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

  @schedules [:first, :second, :third, :fourth, :last, :teenth]
  @weekdays [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  @teenth_date_range 13..19

  defguardp is_year(value) when value >= 2000 and value < 3000
  defguardp is_month(value) when value in 1..12
  defguardp is_weekday(value) when is_atom(value) and value in @weekdays
  defguardp is_schedule(value) when is_atom(value) and value in @schedules

  @weekday_int_to_atom %{
    1 => :monday,
    2 => :tuesday,
    3 => :wednesday,
    4 => :thursday,
    5 => :friday,
    6 => :saturday,
    7 => :sunday
  }

  @doc """
  Calculate a meetup date.

  The schedule is in which week (1..4, last or "teenth") the meetup date should
  fall.
  """
  @spec meetup(pos_integer, pos_integer, weekday, schedule) :: :calendar.date()
  def meetup(year, month, weekday, schedule) 
  when is_year(year) and is_month(month) and is_weekday(weekday) and is_schedule(schedule) 
  do
    # start searching from the beginning of the month
    %Date{year: year, month: month, day: 1}
    |> get_initial_search_state(weekday, schedule)
    |> search
  end

  # Get the initial search state depending on the schedule
  defp get_initial_search_state(date, weekday, :last = schedule), 
    do: %{last_date_found: nil, initial_month: date.month} |> Map.merge(get_base_state(date, weekday, schedule))
  defp get_initial_search_state(date, weekday, schedule), 
    do: get_base_state(date, weekday, schedule)

  defp get_base_state(date, weekday, schedule), 
    do: %{schedule: schedule, search_date: date, looking_for: weekday, num_weekday_found: 0, complete: false}

  defp search(state) do
    search_state = check_date(state)

    case search_state do
      %{complete: true}  -> format_found_date(search_state)
      %{num_weekday_found: 0} -> search_state |> get_next_day_to_search |> search
      %{num_weekday_found: _} -> search_state |> get_next_day_to_search(7) |> search
    end
  end

  defp get_next_day_to_search(%{search_date: date} = state, increment \\ 1) do
    # Add one day to the date, then return the new state
    %{state | search_date: (date |> Date.add(increment))}
  end

  defp format_found_date(%{search_date: date}) do
    {date.year, date.month, date.day}
  end

  # check if the weekday matches, if it does, check the schedule if it is the correct day
  defp check_date(%{search_date: date, looking_for: weekday, num_weekday_found: n} = state) do
    case @weekday_int_to_atom[Date.day_of_week(date)] do
      ^weekday -> %{state | num_weekday_found: n+1} |> check_schedule()
      _        -> state
    end
  end

  # :first
  defp check_schedule(%{schedule: :first, num_weekday_found: 1} = state), 
    do: %{state | complete: true}

  # :second
  defp check_schedule(%{schedule: :second, num_weekday_found: n} = state) when n < 2,  
    do: state
  defp check_schedule(%{schedule: :second, num_weekday_found: 2} = state),
    do: %{state | complete: true}    

  # :third
  defp check_schedule(%{schedule: :third, num_weekday_found: n} = state) when n < 3,  
    do: state
  defp check_schedule(%{schedule: :third, num_weekday_found: 3} = state), 
    do: %{state | complete: true}    

  # :fourth
  defp check_schedule(%{schedule: :fourth, num_weekday_found: n} = state) when n < 4,  
    do: state
  defp check_schedule(%{schedule: :fourth, num_weekday_found: 4} = state),
    do: %{state | complete: true}

  # :last
  defp check_schedule(%{schedule: :last, initial_month: m, search_date: (%Date{month: m} = date)} = state),
    do: %{state | last_date_found: date}
  defp check_schedule(%{schedule: :last} = state), 
    do: %{state | search_date: state.last_date_found, complete: true}

  # :teenth
  defp check_schedule(%{schedule: :teenth, search_date: %Date{day: d}} = state)
    when d in @teenth_date_range, 
    do: %{state | complete: true}
  defp check_schedule(%{schedule: :teenth} = state), do: state
end
