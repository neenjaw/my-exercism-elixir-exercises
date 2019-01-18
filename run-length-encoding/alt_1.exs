defmodule RunLengthEncoder do
  @doc """
  Generates a string where consecutive elements are represented as a data value and count.
  "HORSE" => "1H1O1R1S1E"
  For this example, assume all input are strings, that are all uppercase letters.
  It should also be able to reconstruct the data into its original form.
  "1H1O1R1S1E" => "HORSE"
  """
  @spec encode(String.t) :: String.t
  def encode(str) do
    Regex.scan(~r/(.)\1*/, str)
    |> Enum.map(&(encode_match/1))
    |> Enum.join
  end

  @spec decode(String.t) :: String.t
  def decode(str) do
    Regex.scan(~r/(\d+)(\D)/, str)
    |> Enum.map(&decode_match/1)
    |> Enum.join
  end

  def encode_match([str, letter]) do
     "#{String.length(str)}#{letter}"
  end

  def decode_match([_, num, letter]) do
    letter |> String.duplicate(num |> String.to_integer)
  end
end