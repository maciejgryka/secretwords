defmodule SecretwordsWeb.Features.MultiplayerTest do
  use SecretwordsWeb.ConnCase, async: true
  use Wallaby.Feature
  alias Wallaby.Query

  alias Secretwords.GameState

  @start_button Query.button("Start game")
  @not_started Query.text("Round 0")
  @not_enough_players Query.css("p",
                        text: "Need at least 2 players on each team to start the game."
                      )

  @sessions 4
  feature "only four users can start the game", %{sessions: [player1, player2, player3, player4]} do
    game_id = player1.id

    # make sure game exists in ets
    game_id
    |> GameState.get_or_create_game()
    |> GameState.update_game()

    game_path = Routes.live_path(@endpoint, SecretwordsWeb.GameLive, game_id)

    player1
    |> visit(game_path)
    |> assert_has(@not_started)
    |> assert_has(@not_enough_players)

    player2
    |> visit(game_path)
    |> assert_has(@not_started)
    |> assert_has(@not_enough_players)

    player3
    |> visit(game_path)
    |> assert_has(@not_started)
    |> assert_has(@not_enough_players)

    player4
    |> visit(game_path)
    |> assert_has(@not_started)

    # set up team membership predictably
    game_id
    |> GameState.get_or_create_game()
    |> Map.put(:teams, %{red: [player1.id, player2.id], blue: [player3.id, player4.id]})
    |> Map.put(:leaders, %{red: player1.id, blue: player3.id})
    |> GameState.update_game()

    player1
    |> refute_has(@not_enough_players)
    |> assert_has(@not_started)
    |> click(@start_button)
    |> refute_has(@not_started)
  end
end
