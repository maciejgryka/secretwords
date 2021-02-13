defmodule Secretwords.Helpers do
  @moduledoc """
  Helper functions, which I don't know where else to stick.
  """

  alias Secretwords.GameState

  def get_or_create_game(game_id) do
    grid_size = 5

    case :ets.lookup(:game_sessions, game_id) do
      [{_game_id, state}] ->
        state

      [] ->
        %GameState{
          id: game_id,
          word_slots: GameState.words(1..(grid_size * grid_size)),
          grid_size: grid_size
        }
    end
  end

  def random_string(length \\ 8) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
    |> String.downcase()
  end

  def update_game(game) do
    true = :ets.insert(:game_sessions, {game.id, game})
    :ok = Phoenix.PubSub.broadcast!(Secretwords.PubSub, game.id, {:game_updated, game.id})
    game
  end
end
