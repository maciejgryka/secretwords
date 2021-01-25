defmodule SecretwordsWeb.GameLive do
  use SecretwordsWeb, :live_view

  alias Secretwords.{GameState, Helpers}

  def mount(%{"id" => game_id}, session, socket) do
    user_id = session["user_id"]
    game = Helpers.get_or_create_game(game_id)
    |> GameState.ensure_membership(user_id)
    |> Helpers.update_game()

    if connected?(socket), do: Phoenix.PubSub.subscribe(Secretwords.PubSub, game_id)

    {:ok, assign(socket, [game: game, user_id: user_id])}
  end

  def handle_event("switch_teams", _value, socket) do
    game = Helpers.get_or_create_game(socket.assigns.game.id)
    |> GameState.switch_teams(socket.assigns.user_id)
    |> Helpers.update_game()

    {:noreply, assign(socket, :game, game)}
  end

  def handle_event("choose_word", %{"word" => word}, socket) do
    game = Helpers.get_or_create_game(socket.assigns.game.id)
    |> GameState.choose_word(word)
    |> Helpers.update_game()

    {:noreply, assign(socket, :game, game)}
  end

  def handle_event("next_round", _value, socket) do
    game = Helpers.get_or_create_game(socket.assigns.game.id)
    |> GameState.next_round
    |> Helpers.update_game
    IO.inspect(game.round)

    {:noreply, assign(socket, :game, game)}
  end

  def handle_info({:game_updated, game_id}, socket) do
    {:noreply, assign(socket, :game, Helpers.get_or_create_game(game_id))}
  end
end
