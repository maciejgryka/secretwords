defmodule SecretwordsWeb.PageController do
  use SecretwordsWeb, :controller

  alias Secretwords.{Helpers, GameState, WordSlot}

  def words(num) do
    "data/words.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.shuffle()
    |> Enum.slice(num)
    |> Enum.map(fn w -> %WordSlot{word: w} end)
  end

  def index(conn, _params) do
    render(conn, "index.html", game_session: Helpers.random_game_session)
  end

  def game(conn, %{"game_id" => game_id}) do
    user_id = get_session(conn, "user_id")
    conn = put_session(conn, "game_id", game_id)

    state = get_or_create_game(game_id)
    |> GameState.join(:red, user_id)
    |> update_game()

    render(conn, "game.html", game_state: state)
  end

  defp get_or_create_game(game_id) do
    grid_size = 5
    case :ets.lookup(:game_sessions, game_id) do
      [{_game_id, state}] -> state
      [] ->
        %GameState{
          game_id: game_id,
          word_slots: words(1..(grid_size * grid_size)),
          grid_size: grid_size,
        } |> update_game()
    end
  end

  defp update_game(game) do
    true = :ets.insert(:game_sessions, {game.game_id, game})
    game
  end
end
