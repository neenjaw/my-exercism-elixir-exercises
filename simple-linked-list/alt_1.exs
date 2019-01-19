defmodule LinkedList do
  @opaque t :: tuple()

  defstruct [value: nil, next: nil]

  @doc """
  Construct a new LinkedList
  """
  @spec new() :: t
  def new(), do: nil

  @doc """
  Push an item onto a LinkedList
  """
  @spec push(t, any()) :: t
  def push(nil, elem), do: %LinkedList{value: elem}
  def push(list, elem), do: %LinkedList{value: elem, next: list}

  @doc """
  Calculate the length of a LinkedList
  """
  @spec length(t) :: non_neg_integer()
  def length(list), do: length(list, 0)
  defp length(nil, current), do: current
  defp length(list, current), do: length(list.next, current + 1)

  @doc """
  Determine if a LinkedList is empty
  """
  @spec empty?(t) :: boolean()
  def empty?(nil), do: true
  def empty?(_), do: false

  @doc """
  Get the value of a head of the LinkedList
  """
  @spec peek(t) :: {:ok, any()} | {:error, :empty_list}
  def peek(nil), do: {:error, :empty_list}
  def peek(list), do: {:ok, list.value}

  @doc """
  Get tail of a LinkedList
  """
  @spec tail(t) :: {:ok, t} | {:error, :empty_list}
  def tail(nil), do: {:error, :empty_list}
  def tail(list), do: {:ok, list.next}

  @doc """
  Remove the head from a LinkedList
  """
  @spec pop(t) :: {:ok, any(), t} | {:error, :empty_list}
  def pop(nil), do: {:error, :empty_list}
  def pop(list), do: {:ok, list.value, list.next}

  @doc """
  Construct a LinkedList from a stdlib List
  """
  @spec from_list(list()) :: t
  def from_list([]), do: nil
  def from_list([h | t]), do: %LinkedList{value: h, next: from_list(t)}

  @doc """
  Construct a stdlib List LinkedList from a LinkedList
  """
  @spec to_list(t) :: list()
  def to_list(nil), do: []
  def to_list(list), do: [list.value | to_list(list.next)]

  @doc """
  Reverse a LinkedList
  """
  @spec reverse(t) :: t
  def reverse(nil), do: nil
  def reverse(list), do: reverse(list, nil)
  defp reverse(nil, current), do: current
  defp reverse(next, current) do
    reverse(next.next, %LinkedList{value: next.value, next: current})
  end

end