defmodule Secretwords.Helpers do
  alias Secretwords.{GameState, WordSlot}

  defp words(num) do
    words = "data/words.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.shuffle()
    |> Enum.slice(num)

    types = word_slot_types()

    make_word_slots(words, types)
  end

  def make_word_slots(words, types) do
    [words, types]
    |> Enum.zip
    |> Enum.map(fn {word, type} -> %WordSlot{word: word, type: type} end)
  end

  def word_slot_types() do
    [
      :neutral, :neutral, :neutral, :neutral, :neutral,
      :neutral, :neutral, :neutral, :neutral, :neutral,
      :neutral, :neutral, :neutral, :neutral,
      :red, :red, :red, :red, :red,
      :blue, :blue, :blue, :blue, :blue,
      :killer,
    ] |> Enum.shuffle
  end

  def get_or_create_game(game_id) do
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

  def random_string(length \\ 8) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
    |> String.downcase
  end

  def update_game(game) do
    true = :ets.insert(:game_sessions, {game.id, game})
    :ok = Phoenix.PubSub.broadcast!(Secretwords.PubSub, game.id, {:game_updated, game.id})
    game
  end
end
