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

  def game(conn, %{"id" => game_id}) do
    user_id = get_session(conn, "user_id")
    conn = put_session(conn, "game_id", game_id)

    state = get_or_create_game(game_id)
    |> ensure_membership(user_id)
    |> update_game()

    render(conn, "game.html", game_state: state)
  end

  def switch(conn, %{"id" => game_id}) do
    user_id = get_session(conn, "user_id")
    game = get_or_create_game(game_id)

    current_team = GameState.membership(game, user_id)
    new_team = if current_team == :red, do: :blue, else: :red

    game
    |> GameState.leave(current_team, user_id)
    |> GameState.join(new_team, user_id)
    |> update_game()

    redirect(conn, to: "/g/" <> game_id)
  end

  defp ensure_membership(state, user_id) do
    case Enum.find(state.teams, fn {_, members} -> Enum.member?(members, user_id) end) do
      {_, _} -> state
         nil -> state |> GameState.join(Enum.random([:red, :blue]), user_id)
    end
  end

  defp get_or_create_game(game_id) do
    grid_size = 5
    case :ets.lookup(:game_sessions, game_id) do
      [{_game_id, state}] -> state
      [] ->
        %GameState{
          id: game_id,
          word_slots: words(1..(grid_size * grid_size)),
          grid_size: grid_size,
        }
    end
  end

  defp update_game(game) do
    true = :ets.insert(:game_sessions, {game.id, game})
    game
  end
end
