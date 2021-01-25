defmodule Secretwords.GameState do
  @type t :: map

  defstruct [
    id: "",
    word_slots: [],
    grid_size: 5,
    teams: %{red: [], blue: []},
    leaders: %{},
    round: 0,
    activity: [],
  ]

  def next_round(game) do
    new_round = game.round + 1
    message = "starting round " <> to_string(new_round)

    %__MODULE__{game | round: new_round}
    |> log_activity(message)
  end

  def choose_word(game, word) do
    new_words = game.word_slots |> Enum.map(fn ws ->
      case ws.word == word do
        true -> %{ws | used: true}
        false -> ws
      end
    end)
    message = "\"" <> word <> "\" selected"

    %{game | word_slots: new_words}
    |> log_activity(message)
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
    message = user_id <> " joined the " <> Atom.to_string(color) <> " team"

    game
    # log joining first, because update_members logs leadership changes
    |> log_activity(message)
    |> update_members(color, updated_members)
  end

  def leave(game, color, user_id) do
    current_members = game.teams[color]
    updated_members = Enum.reject(current_members, &(&1 == user_id))
    message = user_id <> " left the " <> Atom.to_string(color) <> " team"

    game
    # log leaving first, because update_members logs leadership changes
    |> log_activity(message)
    |> update_members(color, updated_members)
  end

  defp update_members(game, color, new_members) do
    %__MODULE__{game | teams: %{game.teams | color => new_members}}
    |> ensure_leaders()
  end

  def ensure_leaders(game) do
    new_leaders =
      game.teams
      |> Enum.map(fn {color, members} ->
        {color, determine_leader(game.leaders[color], members)}
      end)
      |> Enum.reject(fn {_, members} -> is_nil(members) end)
      |> Map.new

    game
    |> set_leaders(new_leaders)
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

  defp set_leaders(game, leaders) do
    # message for each new leader
    messages =
      leaders
      |> Enum.filter(fn {color, user_id} -> game.leaders[color] != user_id end)
      |> Enum.map(fn {color, user_id} ->
          user_id <> " leads the " <> Atom.to_string(color) <> " team"
      end)
      |> Enum.reject(&is_nil/1)

    %__MODULE__{game | leaders: leaders}
    |> log_activity(messages)
  end

  def switch_teams(game, user_id) do
    current_team = membership(game, user_id)
    new_team = if current_team == :red, do: :blue, else: :red

    game
    |> leave(current_team, user_id)
    |> join(new_team, user_id)
  end

  defp log_activity(game, messages) when is_list(messages) do
    %__MODULE__{game | activity: messages ++ game.activity}
  end

  defp log_activity(game, message) do
    %__MODULE__{game | activity: [message | game.activity]}
  end
end
