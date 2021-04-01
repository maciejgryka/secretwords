defmodule Secretwords.Plugs.SetMembership do
  @moduledoc """
  If the user joined a game (i.e. the session contains game_id) retrieve the
  membership info from the game state and set it in the session for
  convenience.
  """

  import Plug.Conn

  def init(_params) do
  end

  def call(conn, _params) do
    case :ets.lookup(:game_sessions, get_session(conn, "game_id")) do
      [{_game_id, state}] ->
        user_id = get_session(conn, "user_id")
        {color, _} = Enum.find(state.teams, fn {_, members} -> Enum.member?(members, user_id) end)

        put_session(conn, "membership", color)

      [] ->
        conn
    end
  end
end
