defmodule Secretwords.GameState do
  @type t :: map

  defstruct [
    id: "",
    word_slots: [],
    grid_size: 5,
    teams: %{red: [], blue: []},
    leaders: %{},
    round: 0,
  ]

  def next_round(game) do
    %__MODULE__{game | round: game.round + 1}
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

  def membership(game, user_id) do
    case Enum.find(game.teams, fn {_color, members} -> Enum.member?(members, user_id) end) do
      {color, _members} -> color
      nil -> nil
    end
  end

  def ensure_membership(game, user_id) do
    case Enum.find(game.teams, fn {_, members} -> Enum.member?(members, user_id) end) do
      {_, _} -> game
         nil -> game |> join(Enum.random([:red, :blue]), user_id)
    end
  end

  def join(game, color, user_id) do
    current_members = Map.get(game.teams, color, [])
    updated_members = Enum.uniq([user_id | current_members])
    update_members(game, color, updated_members)
  end

  def leave(game, color, user_id) do
    current_members = game.teams[color]
    updated_members = Enum.reject(current_members, &(&1 == user_id))
    update_members(game, color, updated_members)
  end

  defp update_members(game, color, new_members) do
    %__MODULE__{game | teams: %{game.teams | color => new_members}}
    |> ensure_leaders()
  end

  def ensure_leaders(game) do
    new_leaders = game.teams
      |> Enum.map(fn {color, members} ->
        {color, determine_leader(game.leaders[color], members)}
      end)
      |> Enum.filter(fn {_, members} -> !is_nil(members) end)
      |> Map.new

    %__MODULE__{game | leaders: new_leaders}
  end

  defp determine_leader(current_leader, members) do
    case length(members) do
      0 -> nil
      1 -> List.first(members)
      _ -> if !is_nil(current_leader) do
        current_leader
      else
        List.first(members)
      end
    end
  end

  def switch_teams(game, user_id) do
    current_team = membership(game, user_id)
    new_team = if current_team == :red, do: :blue, else: :red

    game
    |> leave(current_team, user_id)
    |> join(new_team, user_id)
  end
end
