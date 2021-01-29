defmodule SecretwordsWeb.GameLiveTest do
  use SecretwordsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  # alias Secretwords.{GameState}

  test "renders the game", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/g/aaa")

    assert html =~ "Game: aaa"
    assert html =~ "<table id=\"word-grid\">"
  end

  test "renders the round and start game button", %{conn: conn} do
    {:ok, view, _html} = live(conn, Routes.live_path(conn, SecretwordsWeb.GameLive, "aaa"))

    assert render(view) =~ "Round 0"
    assert render(view) =~ "Start game"
  end

  # test "something", %{conn: conn} do
  #   game =
  #     %GameState{id: "aaa"}
  #     |> GameState.join(:red, "u1")
  #     |> GameState.join(:red, "u2")
  #     |> GameState.join(:blue, "u3")
  #     |> GameState.join(:blue, "u4")
  #   conn = conn |> assign(:game, game)

  #   {:ok, view, _html} = live(conn, "/g/aaa")

  #   view =
  #     view
  #     |> element("button#next-round")
  #     |> render_click()

  #   # IO.inspect(view)

  #   # assert render(view) =~ "Round 0"
  # end
end
