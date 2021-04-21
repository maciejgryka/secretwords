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
    case :ets.lookup(:users, user_id) do
      [] -> nil
      [{^user_id, user}] -> user
    end
  end

  def update(user) do
    true = :ets.insert(:users, {user.id, user})

    :ok =
      Phoenix.PubSub.broadcast!(Secretwords.PubSub, "users", {:user_updated, user.id, user.name})

    user
  end
end
