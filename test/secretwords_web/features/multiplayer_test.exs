defmodule SecretwordsWeb.Features.MultiplayerTest do
  use SecretwordsWeb.ConnCase, async: true
  use Wallaby.Feature

  alias Wallaby.Query

  @member_list Query.css(".member-list")
  @member Query.css(".member")
  @start_button Query.button("Start game")

  feature "single user cannot starte the game", %{session: session} do
    game_path = Routes.live_path(@endpoint, SecretwordsWeb.GameLive, session.id)

    session
    |> visit(game_path)
    |> assert_has(Query.text("Round 0"))
    |> click(@start_button)
    # cannot start with only 1 player, so the round should not increase
    |> assert_has(Query.text("Round 0"))
  end

  @sessions 2
  feature "two users can start the game", %{sessions: [player1, player2]} do
    game_path = Routes.live_path(@endpoint, SecretwordsWeb.GameLive, player1.id)

    player1
    |> visit(game_path)
    |> assert_has(Query.text("Round 0"))

    player2
    |> visit(game_path)
    |> assert_has(Query.text("Round 0"))

    # membership is random, so switch if both players are on the same team
    member_counts =
      player2
      |> all(@member_list)
      |> Enum.map(fn ml -> ml |> all(@member) |> length end)
    if Enum.min(member_counts) == 0 do
      player2 |> click(Query.button("Switch teams"))
    end

    player2
    |> click(@start_button)
    # |> assert_has(Query.text("Round 1"))
  end
end
