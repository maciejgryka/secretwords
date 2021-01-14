defmodule Secretwords.Helpers do
  def words(num) do
    "data/words.txt"
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.shuffle()
    |> Enum.slice(num)
  end

  def random_game_session() do
    length = 8
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
