defmodule WordSearch do
  defmodule Location do
    defstruct [:from, :to]

    @type t :: %__MODULE__{
            from: %{row: integer, column: integer},
            to: %{row: integer, column: integer}
          }

    def new({x1, y1} = _from, {x2, y2} = _to) do
      %__MODULE__{from: %{row: y1 + 1, column: x1 + 1}, to: %{row: y2 + 1, column: x2 + 1}}
    end
  end

  defmodule Grid do
    defstruct [:grid, :rows, :cols]

    def new(formatted) do
      formatted_rows = formatted |> String.split("\n", trim: true)

      grid =
        for {row, y} <- formatted_rows |> Stream.with_index(),
            {elem, x} <- to_charlist(row) |> Stream.with_index(),
            into: %{},
            do: {{x, y}, elem}

      rows = length(formatted_rows)
      cols = formatted_rows |> hd() |> to_charlist() |> length()

      %__MODULE__{grid: grid, rows: rows, cols: cols}
    end

    @domain_directions ~w[right diagonal_right down diagonal_left]a

    def generate_domains(%__MODULE__{} = grid, word) do
      length = length(word)

      for y <- 0..(grid.rows - 1),
          x <- 0..(grid.cols - 1),
          direction <- @domain_directions,
          domain = generate_domain(grid, direction, x, y, length),
          List.first(domain),
          into: [],
          do: domain
    end

    defp generate_domain(grid, :right, x, y, length)
         when x + length <= grid.cols do
      for x <- x..(x + length - 1),
          into: [],
          do: {x, y}
    end

    defp generate_domain(grid, :diagonal_right, x, y, length)
         when x + length <= grid.cols and y + length <= grid.rows do
      for d <- 0..(length - 1),
          x = x + d,
          y = y + d,
          into: [],
          do: {x, y}
    end

    defp generate_domain(grid, :down, x, y, length)
         when y + length <= grid.rows do
      for y <- y..(y + length - 1),
          into: [],
          do: {x, y}
    end

    defp generate_domain(grid, :diagonal_left, x, y, length)
         when y + length <= grid.rows and x - length >= 0 do
      for d <- 0..(length - 1),
          x = x - d,
          y = y + d,
          into: [],
          do: {x, y}
    end

    defp generate_domain(_, _, _, _, _), do: []

    def fetch(%__MODULE__{} = grid, coord) do
      grid.grid[coord]
    end
  end

  @type solution :: %{String.t() => nil | Location.t()}

  @doc """
  Find the start and end positions of words in a grid of letters.
  Row and column positions are 1 indexed.
  """
  @spec search(grid :: String.t(), words :: [String.t()]) :: solution()
  def search(grid, words) do
    words = Enum.map(words, &to_charlist/1)
    grid = Grid.new(grid)
    domains = generate_domains(grid, words)

    find_words(grid, domains)
  end

  def generate_domains(grid, words) do
    for word <- words,
        domains = Grid.generate_domains(grid, word),
        into: %{},
        do: {word, domains}
  end

  def find_words(grid, domains) do
    for {word, domains} <- domains,
        {:result, found} = {:result, find_word(grid, word, domains)},
        word = to_string(word),
        into: %{},
        do: {word, found}
  end

  def find_word(grid, word, domains) do
    domains
    |> Stream.flat_map(fn domain ->
      [
        {:forward, domain},
        {:reverse, domain}
      ]
    end)
    |> Stream.map(fn
      {:forward, domain} -> domain
      {:reverse, domain} -> Enum.reverse(domain)
    end)
    |> Enum.find_value(fn domain ->
      found? =
        domain
        |> Enum.map(&Grid.fetch(grid, &1))
        |> Kernel.==(word)

      if found? do
        first = List.first(domain)
        last = List.last(domain)
        Location.new(first, last)
      end
    end)
  end
end
