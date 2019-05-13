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
    inputs = input
      |> Stream.map(&String.split(&1, ";", trim: true))
      |> Stream.filter(fn split_line -> length(split_line) == 3 end)
      |> Stream.filter(fn [_home, _away, outcome] -> outcome in @valid_outcomes end)
      |> Enum.to_list()

    # Take stream into list, then reduce it to a map to tally scores
    inputs
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
    # home team record update
    record_map = add_record(record_map, home, outcome)
    # away team record update
    add_record(record_map, away, get_away_outcome(outcome))
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
    %{team | wins: team.wins + 1, points: team.points + 3, matches: team.matches + 1}
  end

  defp update_team(team, "draw") do
    %{team | draw: team.draw + 1, points: team.points + 1, matches: team.matches + 1}
  end

  defp update_team(team, "loss") do
    %{team | loss: team.loss + 1, matches: team.matches + 1}
  end

  @team_char_width 30
  @stat_char_width 2

  defp format_tally(teams) do
    format_output([~w(Team MP W D L P) | team_maps_to_list(teams)])
  end

  defp team_maps_to_list(teams) do
    Enum.map(teams, fn team -> [team.name, team.matches, team.wins, team.draw, team.loss, team.points] end)
  end

  defp format_output(lines) do
    lines
    |> Enum.map(fn [name | stats] ->
      name = String.pad_trailing(name, @team_char_width)
      stats = Enum.map(stats, &String.pad_leading("#{&1}", @stat_char_width))

      Enum.join([name | stats], " | ")
    end)
    |> Enum.join("\n")
  end
end
