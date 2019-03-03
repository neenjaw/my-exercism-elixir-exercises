# Great use of list comprehensions!!

defmodule Queens do
  @type t :: %Queens{black: {integer, integer}, white: {integer, integer}}
  defstruct black: nil, white: nil

  @doc """
  Creates a new set of Queens
  """
  @spec new() :: Queens.t()
  @spec new({integer, integer}, {integer, integer}) :: Queens.t()
  def new(white \\ {0, 3}, black \\ {7, 3}) do
    cond do
      white == black ->
        raise ArgumentError

      true ->
        %Queens{black: black, white: white}
    end
  end

  @doc """
  Gives a string representation of the board with
  white and black queen locations shown
  """
  @spec to_string(Queens.t()) :: String.t()
  def to_string(queens) do
    # The money maker!! 
    for x <- 0..7, y <- 0..7 do
      cond do
        {x, y} == queens.black -> "B"
        {x, y} == queens.white -> "W"
        true -> "_"
      end
    end

    |> Enum.chunk_every(8)
    |> Enum.map(&Enum.join(&1, " "))
    |> Enum.join("\n")
  end

  @doc """
  Checks if the queens can attack each other
  """
  @spec can_attack?(Queens.t()) :: boolean
  def can_attack?(queens) do
    with {b_x, b_y} <- queens.black,
         {w_x, w_y} <- queens.white
    do
      cond do
        b_x == w_x -> true
        b_y == w_y -> true
        abs(w_x - b_x) == abs(w_y - b_y) -> true
        true -> false
      end
    end
  end
end