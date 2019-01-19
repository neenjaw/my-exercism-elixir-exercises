defmodule LinkedList do
  @opaque t :: tuple()

  @doc """
  Construct a new LinkedList
  """
  @spec new() :: t
  def new() do
    [element: nil, next: nil]
  end

  @doc """
  Push an item onto a LinkedList
  """
  @spec push(t, any()) :: t
  def push(list, elem) do
    [element: elem, next: list]
  end

  @doc """
  Calculate the length of a LinkedList
  """
  @spec length(t) :: non_neg_integer()
  def length(list) do
    count_length(list)
  end

  defp count_length(list, count \\ 0)
  defp count_length([element: nil, next: nil], count), do: count
  defp count_length([element: _, next: n], count), do: count_length(n, count+1)

  @doc """
  Determine if a LinkedList is empty
  """
  @spec empty?(t) :: boolean()
  def empty?(list) do
    case list do
      [element: nil, next: nil] -> true
      _ -> false
    end
  end

  @doc """
  Get the value of a head of the LinkedList
  """
  @spec peek(t) :: {:ok, any()} | {:error, :empty_list}
  def peek(list) do
    case list do
      [element: nil, next: nil] -> {:error, :empty_list}
      [element: e, next: _] -> {:ok, e}
    end
  end

  @doc """
  Get tail of a LinkedList
  """
  @spec tail(t) :: {:ok, t} | {:error, :empty_list}
  def tail(list) do
    case list do
      [element: nil, next: nil] -> {:error, :empty_list}
      [element: _, next: t] -> {:ok, t}
    end
  end

  @doc """
  Remove the head from a LinkedList
  """
  @spec pop(t) :: {:ok, any(), t} | {:error, :empty_list}
  def pop(list) do
    case list do
      [element: nil, next: nil] -> {:error, :empty_list}
      [element: e, next: t] -> {:ok, e, t}
    end
  end

  @doc """
  Construct a LinkedList from a stdlib List
  """
  @spec from_list(list()) :: t
  def from_list(list) do
    do_from_list(list)
  end

  defp do_from_list([]), do: [element: nil, next: nil]
  defp do_from_list([h|t]), do: [element: h, next: do_from_list(t)]

  @doc """
  Construct a stdlib List LinkedList from a LinkedList
  """
  @spec to_list(t) :: list()
  def to_list(list) do
    do_to_list(list)
  end

  defp do_to_list([element: nil, next: nil]), do: []
  defp do_to_list([element: e, next: n]), do: [e | do_to_list(n)]

  @doc """
  Reverse a LinkedList
  """
  @spec reverse(t) :: t
  def reverse(list) do
    do_reverse(list)
  end

  defp do_reverse(list, reversed_list \\ [element: nil, next: nil])
  defp do_reverse([element: nil, next: nil], reversed_list), do: reversed_list
  defp do_reverse([element: e, next: n], reversed_list), do: do_reverse(n, [element: e, next: reversed_list])
end
