defmodule Secretwords.Plugs.SetMembership do
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case :ets.lookup(:game_sessions, get_session(conn, "game_id")) do
      [{_game_id, state}] ->
        user_id = get_session(conn, "user_id")
        {color, _} = state.teams
          |> Enum.find(fn {_, members} -> Enum.member?(members, user_id) end)
        put_session(conn, "membership", color)
      [] ->
        conn
    end
  end
end
