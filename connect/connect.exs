defmodule Connect do
  @doc """
  Calculates the winner (if any) of a board
  using "O" as the white player
  and "X" as the black player
  """
  @spec result_for([String.t()]) :: :none | :black | :white
  def result_for(board) do
  end
end

"""
1: 0 1 2 3 4 5 6 7 8 9
2:  0 1 2 3 4 5 6 7 8 9
3:   0 1 2 3 4 5 6 7 8 9

{n,m} is connected to:
  previous row: {n-1, m}, {n-1, m+1},
  current row:  {n, m-1}, {n, m+1},
  next row:     {n+1, m-1}, {n+1, m}

For a win:
  X must cross the board {_, 0}, {_, 9} by some contiguous path
  O must cross the board {0, _}, {9, _} by some contiguous path

Plan:
1, create a map that can be traversed easily with visit flag
2, find all X on left side
    i) if no X's on left, there is no win for X, skip to O
3, from each X, do a search of possible nodes, except for visited node
4, recurse but flag the next as visited
5, end recurse if:
    i)  path ends, check next X
    ii) path reaches {_, 9}, no more search, X wins

6, If no X is solution, repeat for O
    a) transpose the array

1 2 3
- - -
0
  0
1   0
  1
2   1
  2
3   2
  3
4   3
  4
5   4
  5
6   5
  6
7   6
  7
8   7
  8
9   8
  9
    9

----------------
Could the above be simplified with a MapSet?

As you read, you create all of the tuples for the X with the cordinates

To 'traverse' you pick one of the starting ones (0, x)
-then remove it from the set,
-then look for {x, y}
-repeat until no matches, or reach {_,9}

"""
