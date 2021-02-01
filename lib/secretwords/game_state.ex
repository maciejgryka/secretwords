defmodule Secretwords.GameState do
  @moduledoc """
  Implementation of the main game logic.
  """
  defstruct id: "",
            word_slots: [],
            grid_size: 5,
            teams: %{red: [], blue: []},
            points: %{red: 0, blue: 0},
            leaders: %{},
            round: 0,
            now_guessing: :red,
            activity: []

  @type t :: %__MODULE__{
          id: String.t(),
          word_slots: [Secretwords.WordSlot.t()],
          grid_size: integer,
          teams: %{},
          points: %{},
          leaders: %{},
          round: integer,
          now_guessing: atom,
          activity: [String.t()]
        }

  @spec next_round(t) :: t
  def next_round(game) do
    new_round = game.round + 1

    now_guessing =
      case game.now_guessing do
        :red -> :blue
        :blue -> :red
      end

    game
    |> Map.put(:round, new_round)
    |> Map.put(:now_guessing, now_guessing)
    |> log_activity("starting round #{new_round}, #{now_guessing} guessing")
  end

  def step_round(game, chosen_word_slot_type) do
    # advance round if the guessing team got it wrong,
    # otherwise keep the round
    case game.now_guessing == chosen_word_slot_type do
      false -> game |> next_round()
      true -> game
    end
  end

  @spec choose_word(t, String.t()) :: t
  def choose_word(game, word) do
    new_words =
      game.word_slots
      |> Enum.map(fn ws ->
        case ws.word == word do
          true -> %{ws | used: true}
          false -> ws
        end
      end)

    game
    |> update_words(new_words)
    |> log_activity("\"" <> word <> "\" selected")
  end

  @spec update_words(t(), [WordSlot.t()]) :: t()
  def update_words(game, new_words), do: %{game | word_slots: new_words}

  @spec find_slot(t, String.t()) :: WordSlot.t()
  def find_slot(game, word), do: game.word_slots |> Enum.find(&(&1.word == word))

  @spec update_points(t, :blue | :killer | :neutral | :red) :: t
  def update_points(game, chosen_slot_type) do
    case chosen_slot_type do
      :red ->
        game |> add_point(:red) |> log_activity("red gets a point")

      :blue ->
        game |> add_point(:blue) |> log_activity("blue gets a point")

      :neutral ->
        game

      :killer ->
        game
    end
  end

  defp add_point(game, team) do
    updated_points = %{game.points | team => game.points[team] + 1}
    %{game | points: updated_points}
  end

  @spec membership(t, String.t()) :: atom | nil
  def membership(game, user_id) do
    case Enum.find(game.teams, fn {_c, members} -> user_id in members end) do
      {color, _m} -> color
      nil -> nil
    end
  end

  @spec ensure_membership(t, String.t()) :: t
  def ensure_membership(game, user_id) do
    if game.round > 0 or game |> is_player(user_id) do
      game
    else
      game |> join(Enum.random([:red, :blue]), user_id)
    end
  end

  @spec is_leader(t, String.t()) :: boolean
  def is_leader(game, user_id), do: user_id in all_leaders(game)

  @spec is_player(t, String.t()) :: boolean
  def is_player(game, user_id), do: user_id in all_players(game)

  @spec all_leaders(t) :: [String.t()]
  def all_leaders(game), do: game.leaders |> Map.values()

  @spec all_players(t) :: [String.t()]
  def all_players(game), do: game.teams |> Map.values() |> List.flatten()

  @spec join(t, atom, String.t()) :: t
  def join(game, color, user_id) do
    current_members = Map.get(game.teams, color, [])
    updated_members = Enum.uniq([user_id | current_members])
    message = user_id <> " joined the " <> Atom.to_string(color) <> " team"

    game
    # log joining first, because update_members logs leadership changes
    |> log_activity(message)
    |> update_members(color, updated_members)
  end

  @spec leave(t, atom, String.t()) :: t
  def leave(game, color, user_id) do
    current_members = game.teams[color]
    updated_members = Enum.reject(current_members, &(&1 == user_id))
    message = user_id <> " left the " <> Atom.to_string(color) <> " team"

    game
    # log leaving first, because update_members logs leadership changes
    |> log_activity(message)
    |> update_members(color, updated_members)
  end

  @spec update_members(t, atom, [String.t()]) :: t
  defp update_members(game, color, new_members) do
    updated_teams = Map.put(game.teams, color, new_members)
    game |> Map.put(:teams, updated_teams) |> ensure_leaders()
  end

  @spec ensure_leaders(t) :: t
  def ensure_leaders(game) do
    new_leaders =
      game.teams
      |> Enum.map(fn {color, members} ->
        {color, determine_leader(game.leaders[color], members)}
      end)
      |> Enum.reject(fn {_, members} -> is_nil(members) end)
      |> Map.new()

    game |> set_leaders(new_leaders)
  end

  @spec determine_leader(String.t(), [String.t()]) :: String.t()
  defp determine_leader(current_leader, members) do
    case length(members) do
      0 ->
        nil

      1 ->
        List.first(members)

      _ ->
        if is_nil(current_leader) do
          List.first(members)
        else
          current_leader
        end
    end
  end

  @spec set_leaders(t, %{}) :: t
  defp set_leaders(game, leaders) do
    # message for each new leader
    messages =
      leaders
      |> Enum.filter(fn {color, user_id} -> game.leaders[color] != user_id end)
      |> Enum.map(fn {color, user_id} ->
        user_id <> " leads the " <> Atom.to_string(color) <> " team"
      end)
      |> Enum.reject(&is_nil/1)

    game
    |> Map.put(:leaders, leaders)
    |> log_activity(messages)
  end

  @spec switch_teams(t, String.t()) :: t
  def switch_teams(game, user_id) do
    current_team = membership(game, user_id)

    new_team =
      case current_team do
        :red -> :blue
        :blue -> :red
      end

    game
    |> leave(current_team, user_id)
    |> join(new_team, user_id)
  end

  @spec log_activity(t, [String.t()]) :: t
  defp log_activity(game, messages) when is_list(messages) do
    %{game | activity: messages ++ game.activity}
  end

  @spec log_activity(t, String.t()) :: t
  defp log_activity(game, message) do
    %{game | activity: [message | game.activity]}
  end
end
