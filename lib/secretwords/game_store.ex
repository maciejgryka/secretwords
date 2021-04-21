defmodule Secretwords.GameStore do
  @moduledoc false

  use GenServer

  alias Secretwords.{GameState, Words}

  @name __MODULE__

  def start_link(_params), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_params) do
    :ets.new(:game_sessions, [:set, :public, :named_table])
    {:ok, "game_sessions ets created"}
  end

  def get(game_id) do
    :ets.lookup(:game_sessions, game_id)
  end

  def get_or_create(game_id) do
    grid_size = 5

    case __MODULE__.get(game_id) do
      [{_game_id, state}] ->
        state

      [] ->
        %GameState{
          id: game_id,
          word_slots: Words.words(1..(grid_size * grid_size)),
          grid_size: grid_size
        }
    end
  end

  def update(game) do
    true = :ets.insert(:game_sessions, {game.id, game})
    :ok = Phoenix.PubSub.broadcast!(Secretwords.PubSub, game.id, {:game_updated, game.id})
    game
  end
end
