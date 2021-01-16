defmodule Secretwords.GameState do
  defstruct [
    game_id: "",
    word_slots: [],
    grid_size: 5,
    teams: %{},
    leader_blue: "",
    leader_red: "",
  ]

  def join(game, color, user_id) do
    updated_members = [user_id | Map.get(game.teams, color, [])]
    updated_teams = Map.put(game.teams, color, Enum.uniq(updated_members))
    %Secretwords.GameState{game | teams: updated_teams}
  end
end
