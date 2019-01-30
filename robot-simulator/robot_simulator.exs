defmodule Direction do
  @directions [:north, :east, :south, :west]

  defguard is_direction(value) 
    when is_atom(value) 
    and value in @directions
end

defmodule Position do
  defguard is_coordinate(value) 
    when is_tuple(value) 
    and tuple_size(value) == 2
    and is_integer(elem value, 0) 
    and is_integer(elem value, 1)
end

defmodule RobotSimulator do
  import Direction, only: [is_direction: 1]
  import Position, only: [is_coordinate: 1]

  defmodule Robot do
    @enforce_keys [:direction, :x_position, :y_position]
    defstruct direction: nil,
              x_position: nil, y_position: nil

    @type t() :: %__MODULE__{
      direction: atom(),
      x_position: integer(),
      y_position: integer(),
    }
  end

  @doc """
  Create a Robot Simulator given an initial direction and position.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec create(direction :: atom, position :: {integer, integer}) :: Robot
  def create(direction \\ :north, position \\ {0,0})
  def create(direction, {x, y} = position) 
    when is_direction(direction) and is_coordinate(position), 
    do: %Robot{direction: direction, x_position: x, y_position: y}
  # Match invalid position, return error
  def create(direction, _) when is_direction(direction), do: {:error, "invalid position"}
  # Match invalid direction, return error
  def create(_, _), do: {:error, "invalid direction"}

  @doc """
  Simulate the robot's movement given a string of instructions.

  Valid instructions are: "R" (turn right), "L", (turn left), and "A" (advance)
  """
  @spec simulate(robot :: Robot, instructions :: String.t()) :: Robot
  def simulate(robot, instructions) do
    instructions
    |> String.upcase
    |> String.graphemes
    |> Enum.reduce(robot, fn 
      # Match to previous error and pass it on
      _, {:error, msg} -> {:error, msg}
      # Match to valid instructions
      "L", r -> turn_robot(r, "L")
      "R", r -> turn_robot(r, "R")
      "A", r -> advance_robot(r)
      # Match to invalid instruction, return error
      _, _   -> {:error, "invalid instruction"}
    end)
  end


  defp turn_robot(robot, direction) do
    %{robot | direction: turn(direction, robot.direction)}
  end

  defp turn("L", :north), do: :west
  defp turn("L", :west),  do: :south
  defp turn("L", :south), do: :east
  defp turn("L", :east),  do: :north

  defp turn("R", :north), do: :east
  defp turn("R", :east),  do: :south
  defp turn("R", :south), do: :west
  defp turn("R", :west),  do: :north

  defp advance_robot(%Robot{direction: :north} = robot), do: %{robot | y_position: (robot.y_position+1)}
  defp advance_robot(%Robot{direction: :south} = robot), do: %{robot | y_position: (robot.y_position-1)}
  defp advance_robot(%Robot{direction: :east}  = robot), do: %{robot | x_position: (robot.x_position+1)}
  defp advance_robot(%Robot{direction: :west}  = robot), do: %{robot | x_position: (robot.x_position-1)}

  @doc """
  Return the robot's direction.

  Valid directions are: `:north`, `:east`, `:south`, `:west`
  """
  @spec direction(robot :: any) :: atom
  def direction(%Robot{direction: d}), do: d

  @doc """
  Return the robot's position.
  """
  @spec position(robot :: Robot) :: {integer, integer}
  def position(%Robot{x_position: x, y_position: y}), do: {x,y}
end
