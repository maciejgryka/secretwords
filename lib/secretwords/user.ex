defmodule Secretwords.User do
  @moduledoc false

  defstruct id: "", name: ""

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t()
        }

  def update_user(%__MODULE__{} = user) do
    true = :ets.insert(:users, {user.id, user})

    :ok =
      Phoenix.PubSub.broadcast!(Secretwords.PubSub, "users", {:user_updated, user.id, user.name})

    user
  end

  def get_user(user_id) do
    case :ets.lookup(:users, user_id) do
      [] -> nil
      [{_user_id, user}] -> user
    end
  end

  def name(user_id) do
    case get_user(user_id) do
      nil -> nil
      user -> user.name
    end

    # user_id
  end
end
