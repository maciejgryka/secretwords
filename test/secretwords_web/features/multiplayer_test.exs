defmodule SecretwordsWeb.Features.MultiplayerTest do
  use SecretwordsWeb.ConnCase, async: true
  use Wallaby.Feature
  alias Wallaby.Query

  alias Secretwords.GameState

  @start_button Query.button("Start game")
  @switch_teams Query.button("Switch teams")
  @round Query.text("Round")
  @started Query.text("Round 1")
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
    |> refute_has(@round)
    |> assert_has(@not_enough_players)
    |> assert_has(@switch_teams)

    player2
    |> visit(game_path)
    |> refute_has(@round)
    |> assert_has(@not_enough_players)
    |> assert_has(@switch_teams)

    player3
    |> visit(game_path)
    |> refute_has(@round)
    |> assert_has(@not_enough_players)
    |> assert_has(@switch_teams)

    player4
    |> visit(game_path)
    |> refute_has(@round)
    |> assert_has(@switch_teams)

    # assign members and leaders
    # it doesn't matter which team each of the players is on as long as each team has 2 players
    [
      red = [red_leader | _],
      blue = [blue_leader | _]
    ] =
      game_id
      |> GameState.get_or_create_game()
      |> GameState.all_user_ids()
      |> Enum.chunk_every(2)

    # set up team membership predictably
    game_id
    |> GameState.get_or_create_game()
    |> Map.put(:teams, %{red: red, blue: blue})
    |> Map.put(:leaders, %{red: red_leader, blue: blue_leader})
    |> GameState.update_game()

    player2
    |> refute_has(@round)
    |> refute_has(@not_enough_players)
    |> click(@switch_teams)
    |> assert_has(@not_enough_players)
    |> click(@switch_teams)
    |> refute_has(@not_enough_players)
    |> click(@start_button)
    |> assert_has(@started)
  end
end
