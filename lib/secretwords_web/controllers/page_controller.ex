defmodule SecretwordsWeb.PageController do
  use SecretwordsWeb, :controller

  alias Secretwords.Helpers
  alias Secretwords.GameState

  def words(num) do
    "data/words.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.shuffle()
    |> Enum.slice(num)
  end

  def index(conn, _params) do
    render(conn, "index.html", game_session: Helpers.random_game_session)
  end

  def game(conn, %{"session_id" => session_id}) do
    user_id = get_session(conn, "user_id")

    state = get_or_create_game(session_id)
    |> GameState.join(:red, user_id)
    |> update_game()

    render(conn, "game.html", game_state: state)
  end

  defp get_or_create_game(session_id) do
    grid_size = 5
    case :ets.lookup(:game_sessions, session_id) do
      [{_session_id, state}] -> state
      [] ->
        %GameState{
          session_id: session_id,
          word_slots: words(1..(grid_size * grid_size)),
          grid_size: grid_size,
        } |> update_game()
    end
  end

  defp update_game(game) do
    true = :ets.insert(:game_sessions, {game.session_id, game})
    game
  end
end
