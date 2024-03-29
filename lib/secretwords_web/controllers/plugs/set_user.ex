defmodule Secretwords.Plugs.SetUser do
  @moduledoc """
  If the user is not set, create, store in ets and store user_id in the session.
  """
  import Plug.Conn

  alias Secretwords.{Helpers, User, UserStore}

  def init(_params) do
  end

  def call(conn, _params) do
    case get_session(conn, "user_id") do
      nil ->
        user_id = Helpers.random_string()

        UserStore.update(%User{
          id: user_id,
          name: user_id
        })

        put_session(conn, "user_id", user_id)

      user_id ->
        case UserStore.get(user_id) do
          nil ->
            # the user_id in the session has no equivalent in ets, create a new user
            UserStore.update(%User{
              id: user_id,
              name: user_id
            })

            conn

          %User{} ->
            conn
        end

        conn
    end
  end
end
