defmodule Secretwords.GameState do
  @type t :: map

  defstruct [
    id: "",
    word_slots: [],
    grid_size: 5,
    teams: %{red: [], blue: []},
    leaders: %{}
  ]

  def ensure_membership(game, user_id) do
    case Enum.find(game.teams, fn {_, members} -> Enum.member?(members, user_id) end) do
      {_, _} -> game
         nil -> game |> join(Enum.random([:red, :blue]), user_id)
    end
  end

  def join(game, color, user_id) do
    current_members = Map.get(game.teams, color, [])

    update_members(game, color, Enum.uniq([user_id | current_members]))
  end

  def membership(game, user_id) do
    case Enum.find(game.teams, fn {_color, members} -> Enum.member?(members, user_id) end) do
      {color, _members} -> color
      nil -> nil
    end
  end

  def leave(game, color, user_id) do
    update_members(game, color, Enum.reject(game.teams[color], &(&1 == user_id)))
  end

  def switch_teams(game, user_id) do
    current_team = membership(game, user_id)
    new_team = if current_team == :red, do: :blue, else: :red

    game
    |> leave(current_team, user_id)
    |> join(new_team, user_id)
  end

  defp update_members(game, color, new_members) do
    %Secretwords.GameState{game | teams: %{game.teams | color => new_members}}
    |> ensure_leders()
  end

  defp ensure_leders(game) do
    game = case length(game.teams[:red]) do
      1 -> %{game | leaders: %{game.leaders | red: game.teams[:red] |> List.first}}
      _ -> game
    end
    game = case length(game.teams[:blue]) do
      1 -> %{game | leaders: %{game.leaders | blue: game.teams[:blue] |> List.first}}
      _ -> game
    end
    game
  end

  def choose_word(game, word) do
    new_words = Enum.map game.word_slots, fn ws ->
      if ws.word == word do
        %{ws | used: true}
      else
        ws
      end
    end
    %{game | word_slots: new_words}
  end
end
