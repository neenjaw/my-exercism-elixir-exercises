defmodule BowlingFrame do
  defstruct index: nil,
            rolls: []
  
  @type t() :: %__MODULE__{
    index: integer,
    rolls: list(integer),
  } 
end

defmodule Bowling do
  alias Bowling, as: G
  alias BowlingFrame, as: F

  defstruct frame_stack: [],
            game_over: false

  @type t() :: %__MODULE__{
    frame_stack: list(BowlingFrame.t()),
    game_over: boolean
  }

  @first_frame 1
  @last_frame 10
  @pins 10

  defguard rolled_strike?(roll) 
    when is_integer(roll) 
    and roll == @pins

  defguard rolled_spare?(roll_a, roll_b) 
    when is_integer(roll_a) 
      and is_integer(roll_b) 
      and (roll_a + roll_b) == @pins

  defguard valid_roll?(roll_a, roll_b) 
    when is_integer(roll_a) 
      and is_integer(roll_b) 
      and (@pins - roll_a - roll_b) >= 0

  @doc """
    Creates a new game of bowling that can be used to store the results of
    the game
  """

  @spec start() :: Bowling.t()
  def start, do: %G{}


  @doc """
    Records the number of pins knocked down on a single roll. Returns the `game`
    unless there is something wrong with the given number of pins, in which
    case it returns a helpful message.
  """

  @spec roll(Bowling.t(), integer) :: Bowling.t() | {:error, String.t()}
  # Roll error cases
  def roll(%G{game_over: true}, _roll), do: {:error, "Cannot roll after game is over"}
  def roll(_game, roll) when roll < 0,  do: {:error, "Negative roll is invalid"}
  def roll(_game, roll) when roll > 10, do: {:error, "Pin count exceeds pins on the lane"}

  # First roll - a strike
  def roll(%G{frame_stack: []}, roll) when rolled_strike?(roll) do
    %G{frame_stack: [%F{index: @first_frame+1}, %F{index: @first_frame, rolls: [@pins]}]}
  end

  # First roll - not a strike
  def roll(%G{frame_stack: []}, roll) do
    %G{frame_stack: [%F{index: @first_frame, rolls: [roll]}]}
  end

  # Last Frame cases - 1st roll
  def roll(game = %G{frame_stack: [frame = %F{index: @last_frame, rolls: []} | prev_frames]}, roll) do
    %{game | frame_stack: [%{frame | rolls: [roll]} | prev_frames]}
  end

  # Last Frame cases - 2nd roll - Return error for invalid second roll
  def roll(%G{frame_stack: [%F{index: @last_frame, rolls: [r]} | _prev_frames]}, roll) 
    when not rolled_strike?(r) and not valid_roll?(r, roll), 
    do: {:error, "Pin count exceeds pins on the lane"}
  
  # Last Frame cases - 2nd roll - Valid roll, determine if game is over 
  def roll(game = %G{frame_stack: [frame = %F{index: @last_frame, rolls: [r]} | prev_frames]}, roll) do
    strike?     = rolled_strike?(r)
    spare?      = rolled_spare?(r, roll)
    bonus_roll? = (strike? or spare?)
    game_over?  = (not bonus_roll?)

    %{game | frame_stack: [%{frame | rolls: [r, roll]} | prev_frames], game_over: game_over?}
  end

  # Last Frame cases - Bonus roll
  def roll(game = %G{frame_stack: [frame = %F{index: @last_frame, rolls: [r1, r2]} | prev_frames], game_over: false}, roll) 
    when rolled_strike?(r2) or rolled_spare?(r1, r2)
    when rolled_strike?(r1) and valid_roll?(r2, roll) 
    do
      %{game | frame_stack: [%{frame | rolls: (frame.rolls ++ [roll]) } | prev_frames], game_over: true}
  end

  # Last Frame cases - Return error case
  def roll(%G{frame_stack: [%F{index: @last_frame, rolls: [_r1, _r2]} | _prev_frames]}, _roll) do
    {:error, "Pin count exceeds pins on the lane"}
  end

  # 2..Last-1 Roll cases - 1st roll, when strike
  def roll(game = %G{frame_stack: [frame = %F{index: i, rolls: []} | prev_frames]}, roll) when rolled_strike?(roll) do
    %{game | frame_stack: [ %F{index: i+1}, %{frame | rolls: [roll]} | prev_frames]}
  end

  # 2..Last-1 Roll cases - 1st roll, when not a strike
  def roll(game = %G{frame_stack: [frame = %F{rolls: []} | prev_frames]}, roll) do
    %{game | frame_stack: [%{frame | rolls: [roll]} | prev_frames]}
  end

  # 2..Last-1 Roll cases - 2st roll
  def roll(game = %G{frame_stack: [frame = %F{index: i, rolls: [r]} | prev_frames]}, roll) when valid_roll?(r, roll) do
    %{game | frame_stack: [ %F{index: i+1}, %{frame | rolls: [r, roll]} | prev_frames]}
  end

  # 2..Last-1 Roll cases - Match any roll not previously matched, then return error
  def roll(_game, _roll), do: {:error, "Pin count exceeds pins on the lane"}


  @doc """
    Returns the score of a given game of bowling if the game is complete.
    If the game isn't complete, it returns a helpful message.
  """

  @spec score(Bowling.t()) :: integer | {:error, String.t()}
  def score(%G{game_over: false}), do: {:error, "Score cannot be taken until the end of the game"}
  def score(%G{frame_stack: frames}) do
    do_scoring(frames)
  end

  # Recursively score the stack of frames, keeping an accumulator for the rolls and score sum
  defp do_scoring(frames, roll_acc \\ [], sum_acc \\ 0)
  defp do_scoring([], _roll_acc, sum_acc), do: sum_acc
  defp do_scoring([%F{index: i, rolls: rs} | prev_frames], roll_acc, sum_acc) when i == @last_frame do
    frame_sum = rs |> Enum.sum

    do_scoring(prev_frames, (rs ++ roll_acc), (sum_acc + frame_sum))
  end
  defp do_scoring([%F{index: i, rolls: rs} | prev_frames], roll_acc, sum_acc) do
    frame_sum = rs |> Enum.sum

    frame_bonus =
      case rs do
        [r] when rolled_strike?(r)          -> roll_acc |> Enum.take(2) |> Enum.sum
        [r1, r2] when rolled_spare?(r1, r2) -> roll_acc |> hd
        _                                   -> 0  
      end

    do_scoring(prev_frames, (rs ++ roll_acc), (sum_acc + frame_sum + frame_bonus))
  end
end
