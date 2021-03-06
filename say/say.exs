defmodule Say do

  @one_trillion 1_000_000_000_000
  @chunk_names [
    "",
    "thousand",
    "million",
    "billion" 
    ]

  defguardp in_range(n) 
    when n > 0 
    and n < @one_trillion
  
  @doc """
  Translate a positive integer into English.
  """
  @spec in_english(integer) :: {atom, String.t()}
  def in_english(number) when in_range(number) do
    english = 
      number
      |> Integer.digits
      |> Enum.reverse
      |> Enum.chunk_every(3, 3, [0,0])
      |> Enum.map(&convert_chunk_to_english/1)
      |> Enum.zip(@chunk_names)
      |> Enum.filter(fn
          {"", _} -> false
          _chunk  -> true
        end)
      |> Enum.map(fn 
          {chunk, ""} -> chunk 
          {chunk, name} -> "#{chunk} #{name}" 
        end)
      |> Enum.reverse
      |> Enum.join("\s")

    {:ok, english}
  end
  
  def in_english(0), do: {:ok, "zero"}
  def in_english(_), do: {:error, "number is out of range"}
  
  defp convert_chunk_to_english([one, ten, hundred]) do
    hundred_place = 
      case hundred do
        0 -> :none
        _ -> "#{number_in_english(hundred)} hundred"
      end
      
    [hundred_place, convert_ten_place_to_english(ten, one)]
    |> Enum.filter(fn 
         :none -> false
         _name -> true
       end)
    |> Enum.join("\s")
  end
  
  defp number_in_english(n) do
    case n do
      0 -> :none
      1 -> "one"
      2 -> "two"
      3 -> "three"
      4 -> "four"
      5 -> "five"
      6 -> "six"
      7 -> "seven"
      8 -> "eight"
      9 -> "nine"
    end
  end
  
  defp convert_ten_place_to_english(ten, one) do
    case {ten, one} do
      {0, _} -> number_in_english(one)
        
      {1, 0} -> "ten"
      {1, 1} -> "eleven"
      {1, 2} -> "twelve"
      {1, 3} -> "thirteen"
      {1, 4} -> "fourteen"
      {1, 5} -> "fifteen"
      {1, 6} -> "sixteen"
      {1, 7} -> "seventeen"
      {1, 8} -> "eighteen"
      {1, 9} -> "nineteen"
        
      {2, 0} -> "twenty"
      {2, _} -> "twenty-#{number_in_english(one)}"
        
      {3, 0} -> "thirty"
      {3, _} -> "thirty-#{number_in_english(one)}"
        
      {4, 0} -> "forty"
      {4, _} -> "forty-#{number_in_english(one)}"
        
      {5, 0} -> "fifty"
      {5, _} -> "fifty-#{number_in_english(one)}"
        
      {6, 0} -> "sixty"
      {6, _} -> "sixty-#{number_in_english(one)}"
        
      {7, 0} -> "seventy"
      {7, _} -> "seventy-#{number_in_english(one)}"
        
      {8, 0} -> "eighty"
      {8, _} -> "eighty-#{number_in_english(one)}"
        
      {9, 0} -> "ninety"
      {9, _} -> "ninety-#{number_in_english(one)}"
    end
  end
end







