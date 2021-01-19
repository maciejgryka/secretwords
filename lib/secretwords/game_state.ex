defmodule Secretwords.GameState do
  defstruct [
    id: "",
    word_slots: [],
    grid_size: 5,
    teams: %{red: [], blue: []},
    leaders: %{}
  ]

  def membership(game, user_id) do
    case Enum.find(game.teams, fn {_color, members} -> Enum.member?(members, user_id) end) do
      {color, _members} -> color
      nil -> nil
    end
  end

  def join(game, color, user_id) do
    current_members = Map.get(game.teams, color, [])

    # if the team being joined is empty, make user_id the leader
    game = case current_members do
      [] -> %{game | leaders: Map.put(game.leaders, color, user_id)}
       _ -> game
    end

    update_members(game, color, Enum.uniq([user_id | current_members]))
  end

  def leave(game, color, user_id) do
    update_members(game, color, Enum.reject(game.teams[color], &(&1 == user_id)))
  end

  defp update_members(game, color, new_members) do
    %Secretwords.GameState{game | teams: %{game.teams | color => new_members}}
  end
end
