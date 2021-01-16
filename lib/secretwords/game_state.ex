defmodule Secretwords.GameState do
  defstruct [
    game_id: "",
    word_slots: [],
    grid_size: 5,
    teams: %{},
    leaders: %{}
  ]

  def join(game, color, user_id) do
    current_members = Map.get(game.teams, color, [])

    game = case current_members do
      [] ->
        IO.puts("making " <> user_id <> " a team leader")
        %{game | leaders: Map.put(game.leaders, color, user_id)}
      _ -> game
    end

    updated_members = [user_id | current_members]
    updated_teams = Map.put(game.teams, color, Enum.uniq(updated_members))
    %Secretwords.GameState{game | teams: updated_teams}
  end
end
