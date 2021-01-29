defmodule Secretwords.Plugs.SetUser do
  import Plug.Conn

  alias Secretwords.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    conn
    |> maybe_put_session("user_id", Helpers.random_string())
  end

  defp maybe_put_session(conn, key, value) do
    case get_session(conn, key) do
      nil -> conn |> put_session(key, value)
      _val -> conn
    end
  end
end
