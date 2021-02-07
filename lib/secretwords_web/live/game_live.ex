defmodule SecretwordsWeb.GameLive do
  @moduledoc """
  LiveView of the game.
  """
  use SecretwordsWeb, :live_view

  alias Secretwords.{GameState, Helpers}

  @min_players 1

  def mount(%{"id" => game_id}, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Secretwords.PubSub, game_id)
      Phoenix.PubSub.subscribe(Secretwords.PubSub, "users")
    end

    user_id = session["user_id"]

    game =
      Helpers.get_or_create_game(game_id)
      |> GameState.ensure_membership(user_id)
      |> Helpers.update_game()

    socket =
      socket
      |> assign(min_players: @min_players)
      |> assign(user_id: user_id)
      |> update_and_assign(game)

    {:ok, socket}
  end

  def handle_event("switch_teams", _value, socket) do
    game =
      Helpers.get_or_create_game(socket.assigns.game.id)
      |> GameState.switch_teams(socket.assigns.user_id)
      |> Helpers.update_game()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_event("leave", %{"team" => color}, socket) do
    color = String.to_atom(color)

    game =
      Helpers.get_or_create_game(socket.assigns.game.id)
      |> GameState.leave(color, socket.assigns.user_id)
      |> Helpers.update_game()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_event("choose_word", %{"word" => word}, socket) do
    game = Helpers.get_or_create_game(socket.assigns.game.id)
    chosen_slot = game |> GameState.find_slot(word)

    game
    |> GameState.choose_word(word)
    |> GameState.update_points(chosen_slot.type)
    |> GameState.step_round(chosen_slot.type)
    |> Helpers.update_game()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_event("next_round", _value, socket) do
    game =
      Helpers.get_or_create_game(socket.assigns.game.id)
      |> GameState.next_round()
      |> Helpers.update_game()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_info({:game_updated, game_id}, socket) do
    {:noreply, update_and_assign(socket, Helpers.get_or_create_game(game_id))}
  end

  defp update_and_assign(socket, game) do
    socket
    |> assign(game: game)
    |> assign(d: derived_state(game, socket.assigns.user_id))
  end

  defp derived_state(game, user_id) do
    is_leader = game |> GameState.is_leader(user_id)
    is_player = game |> GameState.is_player(user_id)
    now_guessing = GameState.membership(game, user_id) == game.now_guessing
    is_game_started = game.round > 0
    is_game_finished = GameState.finished(game)

    %{
      is_leader: is_leader,
      is_player: is_player,
      now_guessing: now_guessing,
      is_game_started: is_game_started && !is_game_finished,
      is_game_finished: is_game_finished,
      has_control: is_player && !is_leader && now_guessing && is_game_started,
      enough_members:
        game.teams
        |> Map.values()
        |> Enum.map(&length/1)
        |> Enum.min() >= @min_players
    }
  end
end
