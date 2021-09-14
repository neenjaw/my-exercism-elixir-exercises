defmodule CircularBuffer do
  @moduledoc """
  An API to a stateful process that fills and empties a circular buffer
  """

  defmodule Buffer do
    @empty_buffer %{0 => :empty}

    @enforce_keys [:capacity]
    defstruct [:capacity, size: 0, read_pointer: 0, write_pointer: 0, buffer: @empty_buffer]

    def new(capacity) do
      Agent.start_link(fn -> %__MODULE__{capacity: capacity} end)
    end

    def read(buffer) do
      Agent.get_and_update(buffer, fn state ->
        case state.buffer[state.read_pointer] do
          :empty ->
            {:empty, state}

          item when not is_nil(item) ->
            {item,
             %{
               state
               | size: state.size - 1,
                 read_pointer: rem(state.read_pointer + 1, state.capacity),
                 buffer: Map.put(state.buffer, state.write_pointer, :empty)
             }}
        end
      end)
    end

    def write(buffer, item) do
      Agent.get_and_update(buffer, fn state ->
        cond do
          state.size < state.capacity ->
            {:ok, do_write(state, item)}

          true ->
            {{:error, :full}, state}
        end
      end)
    end

    def overwrite(buffer, item) do
      Agent.get_and_update(buffer, fn state ->
        cond do
          state.size < state.capacity ->
            {:ok, do_write(state, item)}

          true ->
            {:ok, do_overwrite(state, item)}
        end
      end)
    end

    defp do_write(state, item) do
      %{
        state
        | size: state.size + 1,
          write_pointer: rem(state.write_pointer + 1, state.capacity),
          buffer: Map.put(state.buffer, state.write_pointer, item)
      }
    end

    defp do_overwrite(state, item) do
      %{
        state
        | read_pointer: rem(state.read_pointer + 1, state.capacity),
          write_pointer: rem(state.write_pointer + 1, state.capacity),
          buffer: Map.put(state.buffer, state.write_pointer, item)
      }
    end

    def clear(buffer) do
      Agent.update(buffer, fn state ->
        %{state | size: 0, read_pointer: 0, write_pointer: 0, buffer: @empty_buffer}
      end)
    end
  end

  @doc """
  Create a new buffer of a given capacity
  """
  @spec new(capacity :: integer) :: {:ok, pid}
  def new(capacity) do
    Buffer.new(capacity)
  end

  @doc """
  Read the oldest entry in the buffer, fail if it is empty
  """
  @spec read(buffer :: pid) :: {:ok, any} | {:error, atom}
  def read(buffer) do
    case Buffer.read(buffer) do
      :empty -> {:error, :empty}
      item -> {:ok, item}
    end
  end

  @doc """
  Write a new item in the buffer, fail if is full
  """
  @spec write(buffer :: pid, item :: any) :: :ok | {:error, atom}
  def write(buffer, item) do
    Buffer.write(buffer, item)
  end

  @doc """
  Write an item in the buffer, overwrite the oldest entry if it is full
  """
  @spec overwrite(buffer :: pid, item :: any) :: :ok
  def overwrite(buffer, item) do
    Buffer.overwrite(buffer, item)
  end

  @doc """
  Clear the buffer
  """
  @spec clear(buffer :: pid) :: :ok
  def clear(buffer) do
    Buffer.clear(buffer)
  end
end
