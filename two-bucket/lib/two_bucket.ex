defmodule TwoBucket do
  defstruct bucket_one: 0,
            bucket_two: 0,
            moves: 0

  @type t :: %__MODULE__{bucket_one: integer, bucket_two: integer, moves: integer}

  alias TwoBucket.State

  @doc """
  Find the quickest way to fill a bucket with some amount of water from two buckets of specific sizes.
  """
  @spec measure(
          size_one :: integer,
          size_two :: integer,
          goal :: integer,
          start_bucket :: :one | :two
        ) :: {:ok, TwoBucket.t()} | {:error, :impossible}

  def measure(size_one, size_two, goal, _start_bucket) when goal > size_one and goal > size_two,
    do: {:error, :impossible}

  def measure(size_one, size_two, goal, start_bucket) do
    State.new(size_one, size_two, start_bucket)
    |> State.action(:fill, start_bucket)
    |> List.wrap()
    |> do_measure(goal)
  end

  defp do_measure([], _goal), do: {:error, :impossible}

  defp do_measure(possible_goal_states, goal) do
    case Enum.find(possible_goal_states, &State.reached_goal?(&1, goal)) do
      nil ->
        search_actions(possible_goal_states, goal)

      state ->
        {:ok,
         %__MODULE__{
           bucket_one: state.bucket_one,
           bucket_two: state.bucket_two,
           moves: state.moves
         }}
    end
  end

  defp search_actions(states, goal) do
    Enum.flat_map(
      states,
      &apply_search_actions(&1)
    )
    |> do_measure(goal)
  end

  @actions ~w[pour fill empty]a
  @buckets ~w[one two]a
  @search_actions for action <- @actions, bucket <- @buckets, do: {action, bucket}

  defp apply_search_actions(state) do
    @search_actions
    |> Enum.map(fn {action, bucket} ->
      case State.action(state, action, bucket) do
        :error ->
          nil

        next_state ->
          next_state
      end
    end)
    |> Enum.reject(&Kernel.is_nil/1)
  end
end
