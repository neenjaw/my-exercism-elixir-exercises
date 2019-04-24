defmodule OCRNumbers do
  @ocr_to_number %{
    {" _ ","| |","|_|","   "} => "0",
    {"   ","  |","  |","   "} => "1",
    {" _ "," _|","|_ ","   "} => "2",
    {" _ "," _|"," _|","   "} => "3",
    {"   ","|_|","  |","   "} => "4",
    {" _ ","|_ "," _|","   "} => "5",
    {" _ ","|_ ","|_|","   "} => "6",
    {" _ ","  |","  |","   "} => "7",
    {" _ ","|_|","|_|","   "} => "8",
    {" _ ","|_|"," _|","   "} => "9"
  }

  @ocr_width 3
  @ocr_height 4

  defguardp is_valid_line_count(line_count) when rem(line_count, @ocr_height) == 0
  defguardp is_valid_column_count(line_count) when rem(line_count, @ocr_width) == 0

  @doc """
  Given a 3 x 4 grid of pipes, underscores, and spaces, determine which number is represented, or
  whether it is garbled.
  """
  @spec convert([String.t()]) :: String.t()
  def convert(input) do
    rows = length(input)
    columns = input |> List.first() |> String.length()

    case {rows, columns} do
      {rows, _columns} when not is_valid_line_count(rows) ->
        {:error, 'invalid line count'}

      {_rows, columns} when not is_valid_column_count(columns) ->
        {:error, 'invalid column count'}

      _ ->
        converted =
          input
          |> Enum.chunk_every(@ocr_height)
          |> Enum.map(&process_ocr_row/1)
          |> Enum.join(",")

        {:ok, converted}
    end
  end

  defp process_ocr_row(input) do
    input
    |> Enum.map(fn row ->
      row
      |> String.graphemes()
      |> Enum.chunk_every(@ocr_width)
      |> Enum.map(fn chunk -> Enum.join(chunk) end)
    end)
    |> Enum.zip()
    |> Enum.map(fn ocr_tuple ->
      case @ocr_to_number[ocr_tuple] do
        nil -> "?"
        num -> num
      end
    end)
    |> Enum.join()
  end
end
