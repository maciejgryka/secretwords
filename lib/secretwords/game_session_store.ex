defmodule Secretwords.GameSessionStore do
  @moduledoc false

  use GenServer

  @name __MODULE__

  def start_link(_params), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_params) do
    :ets.new(:game_sessions, [:set, :public, :named_table])
    {:ok, "game_sessions ets created"}
  end
end
