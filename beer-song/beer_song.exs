defmodule BeerSong do
  @doc """
  Get a single verse of the beer song
  """
  @spec verse(integer) :: String.t()
  def verse(number) when number >= 0 do
    # function to determine printing the number or "no more"
    qty = fn
      0 -> "no more"
      x -> x
    end

    # function to determine the plurality of the verb based on number
    s = fn
      1 -> ""
      _ -> "s"
    end

    # function to print how many bottles of beer
    how_many = fn n -> "#{qty.(n)} bottle#{s.(n)} of beer" end
    how_many_next = fn 
      0 -> how_many.(99) 
      x -> how_many.(x-1)
    end

    # function to print what to do
    action = fn
      0 -> "Go to the store and buy some more"
      1 -> "Take it down and pass it around"
      _ -> "Take one down and pass it around"     
    end

    line_one = "#{String.capitalize(how_many.(number))} on the wall, #{how_many.(number)}.\n"
    line_two = "#{action.(number)}, #{how_many_next.(number)} on the wall.\n"

    line_one <> line_two
  end

  @doc """
  Get the entire beer song for a given range of numbers of bottles.
  """
  @spec lyrics(Range.t()) :: String.t()
  def lyrics(range \\ 99..0) do
    range
    |> Enum.map(&(verse(&1)))
    |> Enum.join("\n")
  end
end
