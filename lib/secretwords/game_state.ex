defmodule Secretwords.GameState do
  @moduledoc """
  Implementation of the main game logic.
  """

  alias Secretwords.{User, Words}

  defstruct id: "",
            word_slots: [],
            grid_size: 5,
            teams: %{red: MapSet.new(), blue: MapSet.new()},
            points: %{red: 0, blue: 0},
            leaders: %{},
            round: 0,
            winner: nil,
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
          winner: atom,
          now_guessing: atom,
          activity: [String.t()]
        }

  @max_points 9

  def reset(game) do
    num_words = game.grid_size * game.grid_size

    %__MODULE__{
      game
      | word_slots: Words.words(1..num_words),
        points: %{red: 0, blue: 0},
        round: 0,
        winner: nil,
        activity: []
    }
  end

  @spec next_round(t) :: t
  def next_round(game) do
    new_round = game.round + 1
    new_guessing = other_team(game.now_guessing)

    game
    |> Map.put(:round, new_round)
    |> Map.put(:now_guessing, new_guessing)
    |> log_activity("starting round #{new_round}, #{new_guessing} guessing")
  end

  def step_round(game, chosen_word_slot_type) do
    now_guessing = game.now_guessing

    case chosen_word_slot_type do
      ^now_guessing ->
        # keep the current round if the guessing team was right
        game

      :killer ->
        # finish the game if the killer was chosen
        lose(game, now_guessing)

      _other_or_neutral ->
        # otherwise, advance to the next round
        next_round(game)
    end
  end

  def win(game, team) do
    game
    |> Map.put(:winner, team)
    |> log_activity("game over, #{team} won")
  end

  def lose(game, team) do
    win(game, other_team(team))
  end

  @spec choose_word(t, String.t()) :: t
  def choose_word(game, word) do
    new_words =
      Enum.map(
        game.word_slots,
        fn ws ->
          case ws.word == word do
            true -> %{ws | used: true}
            false -> ws
          end
        end
      )

    game
    |> update_words(new_words)
    |> log_activity("\"#{word}\" selected")
  end

  @spec update_words(t(), [WordSlot.t()]) :: t()
  def update_words(game, new_words), do: %{game | word_slots: new_words}

  @spec find_slot(t, String.t()) :: WordSlot.t()
  def find_slot(game, word), do: Enum.find(game.word_slots, &(&1.word == word))

  @spec update_points(t, :blue | :killer | :neutral | :red) :: t
  def update_points(game, chosen_slot_type) do
    case chosen_slot_type do
      :neutral ->
        game

      :killer ->
        # finish the game if the killer was chosen
        lose(game, game.now_guessing)

      color when color in [:red, :blue] ->
        add_point(game, color)
    end
  end

  defp add_point(game, team) do
    updated_points = %{game.points | team => game.points[team] + 1}

    %{game | points: updated_points}
    |> log_activity("#{team} gets a point")
    |> check_end()
  end

  defp check_end(game) do
    winning_team_points = Enum.find(game.points, fn {_team, points} -> points == @max_points end)

    case winning_team_points do
      nil -> game
      {winning_team, @max_points} -> win(game, winning_team)
    end
  end

  def finished(game) do
    game.winner != nil
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
    if game.round > 0 or is_player(game, user_id) do
      game
    else
      join(game, Enum.random([:red, :blue]), user_id)
    end
  end

  @spec is_leader(t, String.t()) :: boolean
  def is_leader(game, user_id), do: user_id in all_leaders(game)

  @spec is_player(t, String.t()) :: boolean
  def is_player(game, user_id), do: user_id in all_user_ids(game)

  @spec all_leaders(t) :: [String.t()]
  def all_leaders(game), do: Map.values(game.leaders)

  @spec all_user_ids(t) :: [String.t()]
  def all_user_ids(game) do
    game.teams
    |> Map.values()
    |> Enum.map(&MapSet.to_list/1)
    |> List.flatten()
  end

  def all_users(game) do
    game
    |> all_user_ids()
    |> Enum.map(fn user_id -> {user_id, User.name(user_id)} end)
    |> Map.new()
  end

  @spec join(t, atom, String.t()) :: t
  def join(game, color, user_id) do
    game
    # log joining first, because update_members logs leadership changes
    |> log_activity("#{User.name(user_id)} joined the #{color} team")
    |> update_members(color, MapSet.put(game.teams[color], user_id))
  end

  @spec leave(t, atom, String.t()) :: t
  def leave(game, color, user_id) do
    game
    # log leaving first, because update_members logs leadership changes
    |> log_activity("#{User.name(user_id)} left the #{color} team")
    |> update_members(color, MapSet.delete(game.teams[color], user_id))
  end

  @spec update_members(t, atom, MapSet.t()) :: t
  defp update_members(game, color, new_members) do
    updated_teams = Map.put(game.teams, color, new_members)

    game
    |> Map.put(:teams, updated_teams)
    |> ensure_leaders()
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

    set_leaders(game, new_leaders)
  end

  @spec determine_leader(String.t(), MapSet.t()) :: String.t()
  defp determine_leader(current_leader, members) do
    case MapSet.size(members) do
      0 ->
        nil

      _num_members ->
        if is_nil(current_leader) or current_leader not in members do
          Enum.at(members, 0)
        else
          current_leader
        end
    end
  end

  @spec set_leaders(t, %{}) :: t
  def set_leaders(game, leaders) do
    # message for each new leader
    messages =
      leaders
      |> Enum.filter(fn {color, user_id} -> game.leaders[color] != user_id end)
      |> Enum.map(fn {color, user_id} ->
        "#{User.name(user_id)} leads the #{color} team"
      end)
      |> Enum.reject(&is_nil/1)

    game
    |> Map.put(:leaders, leaders)
    |> log_activity(messages)
  end

  @spec switch_teams(t, String.t()) :: t
  def switch_teams(game, user_id) do
    current_team = membership(game, user_id)

    game
    |> leave(current_team, user_id)
    |> join(other_team(current_team), user_id)
  end

  @spec log_activity(t, [String.t()]) :: t
  defp log_activity(game, messages) when is_list(messages) do
    %{game | activity: messages ++ game.activity}
  end

  @spec log_activity(t, String.t()) :: t
  defp log_activity(game, message) do
    %{game | activity: [message | game.activity]}
  end

  defp other_team(team) do
    case team do
      :red -> :blue
      :blue -> :red
    end
  end
end
