defmodule SecretwordsWeb.PageController do
  use SecretwordsWeb, :controller

  alias Secretwords.{Helpers, GameState}

  def index(conn, _params) do
    render(conn, "index.html", game_session: Helpers.random_game_session)
  end

  def game(conn, %{"id" => game_id}) do
    user_id = get_session(conn, "user_id")
    conn = put_session(conn, "game_id", game_id)

    game = Helpers.get_or_create_game(game_id)
    |> GameState.ensure_membership(user_id)
    |> Helpers.update_game()

    render(conn, "game.html", game_state: game)
  end

  def switch(conn, %{"id" => game_id}) do
    user_id = get_session(conn, "user_id")

    Helpers.get_or_create_game(game_id)
    |> GameState.switch_teams(user_id)
    |> Helpers.update_game()

    redirect(conn, to: "/g/" <> game_id)
  end
end
