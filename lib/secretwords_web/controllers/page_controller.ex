defmodule SecretwordsWeb.PageController do
  use SecretwordsWeb, :controller

  def words(num) do
    "data/words.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.shuffle()
    |> Enum.slice(num)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def game(conn, %{"session_id" => session_id}) do
    grid_size = 5

    words =
      case :ets.lookup(:game_sessions, session_id) do
        [{_session_id, words}] ->
          words

        [] ->
          words = words(1..(grid_size * grid_size))
          :ets.insert_new(:game_sessions, {session_id, words})
          words
          # [{_, words}] = :ets.lookup(:game_sessions, session_id)
          # words
      end

    render(conn, "game.html", session_id: session_id, words: words, grid_size: grid_size)
  end
end
