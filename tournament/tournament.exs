defmodule Tournament do
  
  defmodule Team do
    @enforce_keys [:name]
    defstruct name: nil,
              wins: 0,
              loss: 0,
              draw: 0,
              points: 0,
              matches: 0

    @type t() :: %__MODULE__{
      name: String.t(),
      wins: integer(),
      loss: integer(),
      draw: integer(),
      points: integer(),
      matches: integer()
    }
  end

  @valid_outcomes ["win", "loss", "draw"]
  
  @doc """
  Given `input` lines representing two teams and whether the first of them won,
  lost, or reached a draw, separated by semicolons, calculate the statistics
  for each team's number of games played, won, drawn, lost, and total points
  for the season, and return a nicely-formatted string table.

  A win earns a team 3 points, a draw earns 1 point, and a loss earns nothing.

  Order the outcome by most total points for the season, and settle ties by
  listing the teams in alphabetical order.
  """
  @spec tally(input :: list(String.t())) :: String.t()
  def tally(input) do
    # Create a stream function for the input which splits each line, then filters out invalid input
    stream = input
    |> Stream.map(&String.split(&1, ";", trim: true))
    |> Stream.filter(fn split_line -> length(split_line) == 3 end)
    |> Stream.filter(fn [_home, _away, outcome] -> outcome in @valid_outcomes end)

    # Take stream into list, then reduce it to a map to tally scores
    Enum.to_list(stream)
    |> Enum.reduce(%{}, &record_reducer(&1, &2))
    |> Map.values()
    |> Enum.sort(fn team_a, team_b -> 
      # Sorts team a before team b:
      #   1) by decreasing points 
      #   2) by increasing lexical order
      cond do
        team_a.points > team_b.points -> true
        team_a.points < team_b.points -> false
        team_a.name < team_b.name     -> true
        team_a.name >= team_b.name    -> false
        true -> true
      end
    end)
    |> format_tally()
  end

  defp record_reducer([home, away, outcome], record_map) do
    add_record(record_map, home, outcome) |> add_record(away, get_away_outcome(outcome))
  end

  defp get_away_outcome("win"), do: "loss"
  defp get_away_outcome("loss"), do: "win"
  defp get_away_outcome("draw"), do: "draw"

  defp add_record(record_map, team, outcome) do
    team_record = Map.get(record_map, team, %Team{name: team})    

    updated_team_record = update_team(team_record, outcome)

    Map.put(record_map, team, updated_team_record)
  end

  defp update_team(team, "win") do
    team
    |> Map.update(:wins, 0, &(&1 + 1)) 
    |> Map.update(:points, 0, &(&1 + 3))
    |> update_team(:matches)
  end

  defp update_team(team, "draw") do
    team
    |> Map.update(:draw, 0, &(&1 + 1)) 
    |> Map.update(:points, 0, &(&1 + 1))
    |> update_team(:matches)
  end

  defp update_team(team, "loss") do
    team
    |> Map.update(:loss, 0, &(&1 + 1)) 
    |> update_team(:matches)
  end

  defp update_team(team, :matches) do
    team
    |> Map.update(:matches, 0, &(&1 + 1))
  end

  defp format_tally(list_of_teams) do
    header = """
    Team                           | MP |  W |  D |  L |  P
    """

    formatted_teams = list_of_teams
    |> Enum.map_join("\n", &format_team/1)
  
    header <> formatted_teams
  end

  @team_char_width 30
  @stat_char_width 2

  defp format_team(team) do
    name = String.pad_trailing("#{team.name}", @team_char_width)

    [team.matches, team.wins, team.draw, team.loss, team.points]
    |> Enum.map(&String.pad_leading("#{&1}", @stat_char_width))
    |> List.insert_at(0, name)
    |> Enum.join(" | ")
  end
end
