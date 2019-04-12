defmodule RailFenceCipher do
  @doc """
  Encode a given plaintext to the corresponding rail fence ciphertext
  """
  @spec encode(String.t(), pos_integer) :: String.t()
  def encode(str, rails) when rails >= 1 do
    rail_sequence_stream =
      create_rail_sequence(rails)

    str
    |> create_rail_map(rail_sequence_stream)
    |> encode_rail_map
  end

  defp create_rail_map(str, rail_sequence_stream) do
    rail_sequence_stream
    |> Stream.zip(String.graphemes(str))
    |> Enum.to_list()
    |> Enum.reduce(%{}, fn {rail, letter}, rail_map ->
      Map.update(rail_map, rail, [letter], fn group -> [letter|group] end)
    end)
  end

  defp create_rail_sequence(rails) do
    case rails do
      1 -> Stream.cycle([1])
      2 -> Stream.cycle([1,2])
      x -> (Enum.to_list(1..x) ++ Enum.to_list((x-1)..(2))) |> Stream.cycle()
    end
  end

  defp encode_rail_map(rail_map) do
    rail_map
    |> Map.keys()
    |> Enum.sort()
    |> Enum.map_join(fn k ->
      rail_map
      |> Map.get(k, [])
      |> Enum.reverse
      |> Enum.join
    end)
  end

  @doc """
  Decode a given rail fence ciphertext to the corresponding plaintext
  """
  @spec decode(String.t(), pos_integer) :: String.t()
  def decode(str, rails) do
    encoded_length =
      String.length(str)

    rail_sequence_stream =
      create_rail_sequence(rails)

    # create a dummy map using a placeholder character
    rail_map =
      "X"
      |> String.duplicate(encoded_length)
      |> create_rail_map(rail_sequence_stream)

    # Using the dummy map, iterate through the map in order and get the length of characters in
    #   each row.  Using this, create tuples to represent string slices, then map the slice to the
    #   tuple.  Using this, create a map of the form %{row => row_grapheme_list}
    encoded_row_map =
      rail_map
      |> Map.keys
      |> Enum.sort
      |> Enum.map(fn key -> Map.get(rail_map, key) |> length() end)
      |> Enum.scan({0, 0}, fn slice_length, {_, slice_start} -> {slice_start, (slice_start + slice_length)} end)
      |> Enum.map(fn {slice_start, slice_end} -> String.slice(str, slice_start, slice_end) |> String.graphemes() end)
      |> Enum.reduce({1, %{}}, fn row, {row_index, row_map} -> {row_index + 1, Map.put(row_map, row_index, row)} end)
      |> (fn {_, x} -> x end).()

    # Using the previously created sequence stream, take a sequence of length equal to the encoded message,
    #   then reduce to the message and then join it.
    rail_sequence_stream
    |> Stream.take(encoded_length)
    |> Enum.to_list()
    |> Enum.reduce({encoded_row_map, []}, &decode_message/2)
    |> (fn {_, x} -> x end).()
    |> Enum.reverse()
    |> Enum.join()
  end

  defp decode_message(row, {rail_map, message}) do
    [letter | remaining_row] = rail_map[row]

    {Map.put(rail_map, row, remaining_row), [letter | message]}
  end
end
