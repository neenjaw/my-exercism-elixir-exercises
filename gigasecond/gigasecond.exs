defmodule Gigasecond do
  @doc """
  Calculate a date one billion seconds after an input date.
  """
  @spec from({{pos_integer, pos_integer, pos_integer}, {pos_integer, pos_integer, pos_integer}}) ::
          :calendar.datetime()
  def from({{year, month, day}, {hours, minutes, seconds}}) do
    %DateTime{
      year: year, month: month, day: day, hour: hours, minute: minutes, second: seconds,
      std_offset: 0, time_zone: "Etc/UTC", utc_offset: 0, zone_abbr: "UTC"
    }
    |> DateTime.add(1_000_000_000, :second)
    |> do_to_tuple
  end

  defp do_to_tuple(%DateTime{year: year, 
                             month: month, 
                             day: day, 
                             hour: hour, 
                             minute: minute, 
                             second: second}) do

    {{year, month, day},{hour, minute, second}}
  end

end
