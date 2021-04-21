defmodule SecretwordsWeb.GameLive do
  @moduledoc """
  LiveView of the game.
  """
  use SecretwordsWeb, :live_view

  alias Secretwords.{GameState, GameStore, User, UserStore}

  @min_players 2

  def mount(%{"id" => game_id}, session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Secretwords.PubSub, game_id)
      Phoenix.PubSub.subscribe(Secretwords.PubSub, "users")
    end

    user_id = session["user_id"]

    game =
      GameStore.get_or_create_game(game_id)
      |> GameState.ensure_membership(user_id)
      |> GameStore.update()

    user = UserStore.get(user_id)
    usernames = GameState.all_users(game)

    socket =
      socket
      |> assign(min_players: @min_players)
      |> assign(user_id: user_id)
      |> assign(user: user)
      |> assign(usernames: usernames)
      |> update_and_assign(game)

    {:ok, socket}
  end

  def handle_event("switch_teams", _value, socket) do
    game =
      GameStore.get_or_create_game(socket.assigns.game.id)
      |> GameState.switch_teams(socket.assigns.user_id)
      |> GameStore.update()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_event("leave", _params, socket) do
    game =
      GameStore.get_or_create_game(socket.assigns.game.id)
      |> GameState.leave(:red, socket.assigns.user_id)
      |> GameState.leave(:blue, socket.assigns.user_id)
      |> GameStore.update()

    socket =
      socket
      |> update_and_assign(game)
      |> redirect(to: "/")

    {:noreply, socket}
  end

  def handle_event("choose_word", %{"word" => word}, socket) do
    game = GameStore.get_or_create_game(socket.assigns.game.id)
    chosen_slot = GameState.find_slot(game, word)

    game
    |> GameState.choose_word(word)
    |> GameState.update_points(chosen_slot.type)
    |> GameState.step_round(chosen_slot.type)
    |> GameStore.update()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_event("next_round", _value, socket) do
    game =
      GameStore.get_or_create_game(socket.assigns.game.id)
      |> GameState.next_round()
      |> GameStore.update()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_event("update_username", %{"value" => username}, socket) do
    user = UserStore.update(%User{id: socket.assigns.user_id, name: username})

    socket =
      socket
      |> assign(:user, user)
      |> assign(:usernames, GameState.all_users(socket.assigns.game))

    {:noreply, socket}
  end

  def handle_event("reset_game", _value, socket) do
    game =
      GameStore.get_or_create_game(socket.assigns.game.id)
      |> GameState.reset()
      |> GameStore.update()

    {:noreply, update_and_assign(socket, game)}
  end

  def handle_info({:game_updated, game_id}, socket) do
    {:noreply, update_and_assign(socket, GameStore.get_or_create_game(game_id))}
  end

  def handle_info({:user_updated, user_id, user_name}, socket) do
    updated_users = Map.put(socket.assigns.usernames, user_id, user_name)
    {:noreply, assign(socket, :usernames, updated_users)}
  end

  defp update_and_assign(socket, game) do
    socket
    |> assign(game: game)
    |> assign(d: derived_state(game, socket.assigns.user_id))
  end

  defp derived_state(game, user_id) do
    is_leader = GameState.is_leader(game, user_id)
    is_player = GameState.is_player(game, user_id)
    now_guessing = GameState.membership(game, user_id) == game.now_guessing
    is_game_started = game.round > 0
    is_game_finished = GameState.finished(game)

    %{
      is_leader: is_leader,
      is_player: is_player,
      now_guessing: now_guessing,
      is_game_in_progress: is_game_started && !is_game_finished,
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
