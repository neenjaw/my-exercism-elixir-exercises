defmodule Nines do
    def count_nines(max) do
        1..max
        |> Stream.map(&count_nines_in_number(&1))
        |> Enum.reduce(0, fn n, acc -> n + acc end)
    end

    def count_nines_in_number(number) do
        number
        |> Integer.digits
        |> Enum.reduce(0, fn 
            9, acc -> acc + 1
            _, acc -> acc
        end)
    end

    # Timing O(number of digits)
    def count_nines_by_lower_bound(max) do
        digits = max
        |> Integer.digits

        digits
        |> Stream.zip(length(digits)..1)
        |> Stream.map(fn {digit, place} -> {digit, place, get_lower_nine_bound(digit, place)} end)
        |> Enum.reduce(%{sum: 0, digits: [], nines: []}, fn
            {9, p, lower_bound}, acc -> %{acc | sum: acc.sum + lower_bound, digits: [9 | acc.digits], nines: [p | acc.nines]}
            {d, _, lower_bound}, acc -> %{acc | sum: acc.sum + lower_bound, digits: [d | acc.digits]}
        end)
        |> adjust_for_nine_digits
    end

    # the lower bound of nines seems to follow the pattern that there is:
    # 1 * (the number of places - 1) * (10 ^ (number of places - 1))
    # also, add 1 if the current digit is 9 
    def get_lower_nine_bound(digit, place) do
        place-1 
        |> Integer.digits  
        |> Kernel.++(get_lower_bound_zeroes(place))
        |> Integer.undigits
        |> Kernel.*(digit)
    end

    defp get_lower_bound_zeroes(places) when places <= 2, do: []
    defp get_lower_bound_zeroes(places) when places > 2, do: List.duplicate(0, places-2)
        
    defp adjust_for_nine_digits(%{nines: [], sum: sum}), do: sum
    defp adjust_for_nine_digits(%{digits: digits, sum: unadjusted_sum, nines: nines}) do
        [digits, 1..length(digits)]
        |> Stream.zip
        |> Enum.to_list
        |> do_adjust_for_nine_digits(nines)
        |> Kernel.+(unadjusted_sum)
    end

    defp do_adjust_for_nine_digits(digits, nines) do
        digits
        |> Enum.reduce({0, []}, fn {digit, place}, {sum, place_count} -> 
            # find how many to add for the current digit
            how_many = case place do
                1 -> Integer.undigits([digit | place_count]) + 1
                _ -> Integer.undigits([digit | place_count])
            end 
            
            # only count for nines 'ahead' of the current digit
            nine_count = nines
            |> Enum.drop_while(fn nine_place -> nine_place <= place end)
            |> length

            # if the ones digit is a 9, add one
            adjust = case {digit, place} do
                {9, 1} -> 1
                _      -> 0    
            end

            {sum + (how_many * nine_count + adjust), [0 | place_count]}        
        end)
        |> elem(0)
    end
end