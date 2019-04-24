defmodule CryptoSquare do
  @doc """
  Encode string square methods
  ## Examples

    iex> CryptoSquare.encode("abcd")
    "ac bd"
  """
  @spec encode(String.t()) :: String.t()
  def encode(""), do: ""
  def encode(str) do
    normalized_str =
      str
      |> String.downcase()
      |> String.replace(~r/[^[:alnum:]]/u, "")
      |> String.graphemes()

    str_length = length(normalized_str)

    rows =
      str_length
      |> :math.sqrt()
      |> Float.round()
      |> Kernel.trunc()

    columns =
      if rows * rows < str_length do
        rows + 1
      else
        rows
      end

    normalized_str
    |> Kernel.++(List.duplicate("", ((rows*columns) - str_length)))
    |> Enum.chunk_every(columns)
    |> Enum.zip()
    |> Enum.map(fn column -> column |> Tuple.to_list() |> Enum.join() end)
    |> Enum.join(" ")
  end
end
