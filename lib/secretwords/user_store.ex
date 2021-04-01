defmodule Secretwords.UserStore do
  @moduledoc false

  use GenServer

  @name __MODULE__

  def start_link(_params), do: GenServer.start_link(__MODULE__, [], name: @name)

  def init(_params) do
    :ets.new(:users, [:set, :public, :named_table])
    {:ok, "users ets created"}
  end

  def get(user_id) do
    :ets.lookup(:users, user_id)
  end

  def update(user) do
    :ets.insert(:users, {user.id, user})
  end
end
