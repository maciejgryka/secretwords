defmodule Secretwords.GameSessionStore do
  use GenServer

  @name __MODULE__

  def start_link(_), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_) do
    :ets.new(:game_sessions, [:set, :public, :named_table])
    {:ok, "game_sessions ets created"}
  end
end
