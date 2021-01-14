defmodule Secretwords.Plugs.SetUser do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    conn
    |> maybe_put_session("user_id", random_username())
  end

  defp maybe_put_session(conn, key, value) do
    case get_session(conn, key) do
      nil ->
        IO.inspect(key)
        put_session(conn, key, value)
      _value -> conn
    end
  end

  defp random_username() do
    length = 8
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
    |> String.downcase
  end
end
