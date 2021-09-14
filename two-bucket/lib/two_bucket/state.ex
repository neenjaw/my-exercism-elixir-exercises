defmodule TwoBucket.State do
  @enforce_keys [:capacity_one, :capacity_two, :visited]
  defstruct [
    :capacity_one,
    :capacity_two,
    :visited,
    bucket_one: 0,
    bucket_two: 0,
    moves: 0,
    history: []
  ]

  @type t :: %__MODULE__{
          capacity_one: integer,
          capacity_two: integer,
          bucket_one: integer,
          bucket_two: integer,
          moves: integer,
          visited: MapSet.t({integer, integer}),
          history: [{integer, integer}]
        }

  defguardp is_bucket_full(state, bucket)
            when is_struct(state, __MODULE__) and
                   ((bucket == :one and state.capacity_one == state.bucket_one) or
                      (bucket == :two and state.capacity_two == state.bucket_two))

  defguardp is_bucket_empty(state, bucket)
            when is_struct(state, __MODULE__) and
                   ((bucket == :one and state.bucket_one == 0) or
                      (bucket == :two and state.bucket_two == 0))

  def new(capacity_one, capacity_two, start_bucket) do
    %__MODULE__{
      capacity_one: capacity_one,
      capacity_two: capacity_two,
      visited: do_new_visited(capacity_one, capacity_two, start_bucket)
    }
  end

  defp do_new_visited(_capacity_one, capacity_two, :one), do: MapSet.new([{0, capacity_two}])
  defp do_new_visited(capacity_one, _capacity_two, :two), do: MapSet.new([{capacity_one, 0}])

  @type action :: :pour | :empty | :fill
  @type bucket :: :one | :two

  @spec action(state :: __MODULE__.t(), action(), bucket()) :: __MODULE__.t() | :error
  def action(%__MODULE__{} = state, :pour, :one)
      when not is_bucket_empty(state, :one) and not is_bucket_full(state, :two) do
    %{from_post_vol: bucket_one, to_post_vol: bucket_two} =
      pour(state.bucket_one, state.capacity_two, state.bucket_two)

    %{state | bucket_one: bucket_one, bucket_two: bucket_two} |> after_action()
  end

  def action(%__MODULE__{} = state, :pour, :two)
      when not is_bucket_empty(state, :two) and not is_bucket_full(state, :one) do
    %{from_post_vol: bucket_two, to_post_vol: bucket_one} =
      pour(state.bucket_two, state.capacity_one, state.bucket_one)

    %{state | bucket_one: bucket_one, bucket_two: bucket_two} |> after_action()
  end

  def action(%__MODULE__{} = state, :empty, :one) when not is_bucket_empty(state, :one) do
    %{state | bucket_one: 0} |> after_action()
  end

  def action(%__MODULE__{} = state, :empty, :two) when not is_bucket_empty(state, :two) do
    %{state | bucket_two: 0} |> after_action()
  end

  def action(%__MODULE__{} = state, :fill, :one) when not is_bucket_full(state, :one) do
    %{state | bucket_one: state.capacity_one} |> after_action()
  end

  def action(%__MODULE__{} = state, :fill, :two) when not is_bucket_full(state, :two) do
    %{state | bucket_two: state.capacity_two} |> after_action()
  end

  def action(%__MODULE__{}, _, _), do: :error

  defp pour(from_pre_vol, to_capacity, to_pre_vol) do
    capacity_remaining = to_capacity - to_pre_vol
    amount_to_pour = min(capacity_remaining, from_pre_vol)

    from_post_vol = from_pre_vol - amount_to_pour
    to_post_vol = to_pre_vol + amount_to_pour

    %{from_post_vol: from_post_vol, to_post_vol: to_post_vol}
  end

  defp after_action(%__MODULE__{} = state) do
    bucket_state = {state.bucket_one, state.bucket_two}

    cond do
      has_visited?(state, bucket_state) ->
        :error

      true ->
        %{
          state
          | moves: state.moves + 1,
            visited: MapSet.put(state.visited, bucket_state),
            history: [bucket_state | state.history]
        }
    end
  end

  @spec has_visited?(__MODULE__.t(), {integer, integer}) :: boolean()
  defp has_visited?(%__MODULE__{} = state, bucket_state),
    do: MapSet.member?(state.visited, bucket_state)

  @spec reached_goal?(__MODULE__.t(), non_neg_integer()) :: boolean()
  def reached_goal?(%__MODULE__{} = state, goal),
    do: state.bucket_one == goal or state.bucket_two == goal
end
