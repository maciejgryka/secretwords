defmodule Secretwords.GameStateTest do
  use ExUnit.Case, async: true

  alias Secretwords.{GameState, WordSlot}

  describe "join" do
    test "joins the right team" do
      game = %GameState{} |> GameState.join(:red, "member1")
      assert game.teams[:red] == ["member1"]
    end

    test "ensures members are unique" do
      game =
        %GameState{}
        |> GameState.join(:red, "member1")
        |> GameState.join(:red, "member1")

      assert game.teams[:red] == ["member1"]
    end

    test "allows multiple members" do
      game =
        %GameState{}
        |> GameState.join(:red, "member1")
        |> GameState.join(:red, "member2")

      assert game.teams[:red] == ["member2", "member1"]
    end
  end

  describe "leave" do
    test "leaves the team if given user is a member" do
      assert GameState.leave(
               %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
               :red,
               "u1"
             ).teams == %{red: ["u2"], blue: ["u3"]}

      assert GameState.leave(
               %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
               :blue,
               "u3"
             ).teams == %{red: ["u1", "u2"], blue: []}
    end

    test "does nothing if the given user is not a member" do
      assert GameState.leave(
               %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
               :red,
               "u3"
             ).teams == %{red: ["u1", "u2"], blue: ["u3"]}

      assert GameState.leave(
               %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
               :red,
               "u4"
             ).teams == %{red: ["u1", "u2"], blue: ["u3"]}
    end
  end

  describe "membership" do
    test "returns the team name for users in teams" do
      game = %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}}
      assert GameState.membership(game, "u1") == :red
      assert GameState.membership(game, "u2") == :red
      assert GameState.membership(game, "u3") == :blue
    end

    test "returns nil for non-members" do
      game = %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}}
      assert GameState.membership(game, "u4") == nil
    end
  end

  describe "choose_word" do
    test "markes the word slot as used" do
      game = %GameState{
        word_slots: [
          %WordSlot{word: "one", used: false, type: :red},
          %WordSlot{word: "two", used: false, type: :blue}
        ]
      }

      assert GameState.choose_word(game, "two").word_slots == [
               %WordSlot{word: "one", used: false, type: :red},
               %WordSlot{word: "two", used: true, type: :blue}
             ]
    end
  end

  describe "update points" do
    test "adds points correctly" do
      game = %GameState{
        word_slots: [
          %WordSlot{word: "one", used: false, type: :red},
          %WordSlot{word: "two", used: false, type: :blue},
          %WordSlot{word: "three", used: false, type: :neutral}
        ],
        points: %{red: 0, blue: 0}
      }

      assert GameState.update_points(game, :red).points == %{red: 1, blue: 0}
      assert GameState.update_points(game, :blue).points == %{red: 0, blue: 1}
      assert GameState.update_points(game, :neutral).points == %{red: 0, blue: 0}
    end
  end

  describe "ensure_leaders" do
    test "makes leaders out of sole members" do
      assert GameState.ensure_leaders(%GameState{teams: %{red: [], blue: ["u1"]}}).leaders == %{
               blue: "u1"
             }

      assert GameState.ensure_leaders(%GameState{teams: %{red: ["u2"], blue: ["u1"]}}).leaders ==
               %{red: "u2", blue: "u1"}
    end

    test "removes leaders of empty tems" do
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: [], blue: ["u1"]},
               leaders: %{red: "u3", blue: "u1"}
             }).leaders == %{blue: "u1"}
    end

    test "leaves existing valid leaders" do
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: ["u1", "u2", "u3"], blue: ["u4"]},
               leaders: %{red: "u2", blue: "u4"}
             }).leaders == %{red: "u2", blue: "u4"}
    end

    test "picks a leader for non-empty, leaderless teams" do
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: ["u1", "u2", "u3"], blue: ["u4"]},
               leaders: %{blue: "u4"}
             }).leaders == %{red: "u1", blue: "u4"}
    end
  end

  describe "ensure_membership" do
    test "adds the user to some team if the game has not yet started" do
      assert "u1" in (%GameState{}
                      |> GameState.ensure_membership("u1")
                      |> GameState.all_players())
    end

    test "doesn't add the user to any team if the game has already started" do
      assert "u1" not in (%GameState{round: 1}
                          |> GameState.ensure_membership("u1")
                          |> GameState.all_players())
    end

    test "doesn't add the user to any team if they're already a member" do
      updated_teams =
        (%GameState{teams: %{red: ["u1", "u3"], blue: ["u2"]}}
         |> GameState.ensure_membership("u3")).teams

      assert updated_teams == %{red: ["u1", "u3"], blue: ["u2"]}
    end
  end
end
