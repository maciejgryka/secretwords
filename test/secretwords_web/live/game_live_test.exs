defmodule SecretwordsWeb.GameLiveTest do
  use SecretwordsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Secretwords.{GameState, GameStore, WordSlot}
  alias SecretwordsWeb.GameLive

  test "renders the game", %{conn: conn} do
    conn = setup_conn(conn)
    game_id = conn.assigns.game.id

    {:ok, _view, html} = live(conn, "/g/" <> game_id)

    assert html =~ "/g/#{game_id}"
    assert html =~ "<table id=\"word-grid\""
  end

  test "renders the switch teams button", %{conn: conn} do
    game_id = unique_identifier(conn)
    {:ok, view, _html} = live(conn, Routes.live_path(conn, GameLive, game_id))

    assert render(view) =~ "Switch teams"
  end

  describe "selecting a word" do
    test "marks the word as used", %{conn: conn} do
      conn = setup_conn(conn)
      game_id = conn.assigns.game.id
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameLive, game_id))

      refute view
             |> element("td.word.word-used", "one")
             |> has_element?()

      view
      |> element("td.word", "one")
      |> render_click()

      assert view
             |> element("td.word.word-used", "one")
             |> has_element?()
    end

    test "adds points to the right teams", %{conn: conn} do
      conn = setup_conn(conn)
      game_id = conn.assigns.game.id
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameLive, game_id))

      assert view |> element("#points-red", "0") |> has_element?
      assert view |> element("#points-blue", "0") |> has_element?

      view |> element("td.word", "one") |> render_click()
      assert view |> element("#points-red", "1") |> has_element?

      view |> element("td.word", "two") |> render_click()
      assert view |> element("#points-blue", "1") |> has_element?
    end

    test "does not advance the round on a corect guess", %{conn: conn} do
      conn = setup_conn(conn)
      game_id = conn.assigns.game.id
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameLive, game_id))

      assert view |> element("h3", ~r/Round 1/) |> has_element?

      view |> element("td.word", "one") |> render_click()

      assert view |> element("h3", ~r/Round 1/) |> has_element?
    end

    test "advances the round on a wrong guess", %{conn: conn} do
      conn = setup_conn(conn)
      game_id = conn.assigns.game.id
      {:ok, view, _html} = live(conn, Routes.live_path(conn, GameLive, game_id))

      assert view |> element("h3", ~r/Round 1/) |> has_element?

      view |> element("td.word", "two") |> render_click()

      assert view |> element("h3", ~r/Round 2/) |> has_element?
    end
  end

  defp unique_identifier(conn) do
    conn.owner
    |> :erlang.pid_to_list()
    |> :erlang.list_to_binary()
    |> String.replace(["<", ">"], "")
  end

  defp setup_conn(conn) do
    # do a `get` to set up the endpoint, init session etc.
    conn = get(conn, "/")
    user_id = get_session(conn, "user_id")
    game_id = unique_identifier(conn)

    game =
      GameStore.update(%GameState{
        id: game_id,
        now_guessing: :red,
        round: 1,
        teams: %{red: ["u1", user_id], blue: ["u3, u4"]},
        leaders: %{red: "u1", blue: "u3"},
        points: %{red: 0, blue: 0},
        word_slots: [
          %WordSlot{word: "one", used: false, type: :red},
          %WordSlot{word: "two", used: false, type: :blue},
          %WordSlot{word: "three", used: false, type: :neutral}
        ]
      })

    assign(conn, :game, game)
  end
end
