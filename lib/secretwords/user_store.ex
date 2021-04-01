defmodule Secretwords.UserStore do
  @moduledoc false

  use GenServer

  @name __MODULE__

  def start_link(_params), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_params) do
    :ets.new(:users, [:set, :public, :named_table])
    {:ok, "users ets created"}
  end
end
