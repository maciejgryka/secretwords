defmodule Secretwords.GameStateTest do
  use ExUnit.Case, async: true

  alias Secretwords.{GameState, WordSlot}

  describe "next_round" do
    test "advances the round and cycles now_guessing" do
      game = %GameState{now_guessing: :red, round: 1}

      updated_game = GameState.next_round(game)
      assert updated_game.round == 2
      assert updated_game.now_guessing == :blue

      updated_game = GameState.next_round(updated_game)
      assert updated_game.round == 3
      assert updated_game.now_guessing == :red
    end
  end

  describe "step_round" do
    test "advances the round if the guess was wrong" do
      game = %GameState{now_guessing: :red, round: 1}
      assert GameState.step_round(game, :blue).round == 2
    end

    test "does not advance the round if the guess was correct" do
      game = %GameState{now_guessing: :red, round: 1}
      assert GameState.step_round(game, :red).round == 1
    end
  end

  describe "join" do
    test "joins the right team" do
      game = GameState.join(%GameState{}, :red, "member1")
      assert MapSet.to_list(game.teams[:red]) == ["member1"]
    end

    test "ensures members are unique" do
      game =
        %GameState{}
        |> GameState.join(:red, "member1")
        |> GameState.join(:red, "member1")

      assert MapSet.to_list(game.teams[:red]) == ["member1"]
    end

    test "allows multiple members" do
      game =
        %GameState{}
        |> GameState.join(:red, "member1")
        |> GameState.join(:red, "member2")

      assert "member1" in game.teams[:red]
      assert "member2" in game.teams[:red]
    end
  end

  describe "leave" do
    test "leaves the team if given user is a member" do
      assert GameState.leave(
               %GameState{teams: %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new(["u3"])}},
               :red,
               "u1"
             ).teams == %{red: MapSet.new(["u2"]), blue: MapSet.new(["u3"])}

      assert GameState.leave(
               %GameState{teams: %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new(["u3"])}},
               :blue,
               "u3"
             ).teams == %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new()}
    end

    test "removes the leader when they leave" do
      assert GameState.leave(
               %GameState{
                 teams: %{red: MapSet.new(["u1", "u2", "u4"]), blue: MapSet.new(["u3"])},
                 leaders: %{red: "u1", blue: "u3"}
               },
               :red,
               "u1"
             ).leaders.red != "u1"
    end

    test "does nothing if the given user is not a member" do
      assert GameState.leave(
               %GameState{teams: %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new(["u3"])}},
               :red,
               "u3"
             ).teams == %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new(["u3"])}

      assert GameState.leave(
               %GameState{teams: %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new(["u3"])}},
               :red,
               "u4"
             ).teams == %{red: MapSet.new(["u1", "u2"]), blue: MapSet.new(["u3"])}
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
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: MapSet.new(), blue: MapSet.new(["u1"])}
             }).leaders == %{
               blue: "u1"
             }

      assert GameState.ensure_leaders(%GameState{
               teams: %{red: MapSet.new(["u2"]), blue: MapSet.new(["u1"])}
             }).leaders ==
               %{red: "u2", blue: "u1"}
    end

    test "removes leaders of empty tems" do
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: MapSet.new(), blue: MapSet.new(["u1"])},
               leaders: %{red: "u3", blue: "u1"}
             }).leaders == %{blue: "u1"}
    end

    test "leaves existing valid leaders" do
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: MapSet.new(["u1", "u2", "u3"]), blue: MapSet.new(["u4"])},
               leaders: %{red: "u2", blue: "u4"}
             }).leaders == %{red: "u2", blue: "u4"}
    end

    test "picks a leader for non-empty, leaderless teams" do
      assert GameState.ensure_leaders(%GameState{
               teams: %{red: MapSet.new(["u1", "u2", "u3"]), blue: MapSet.new(["u4"])},
               leaders: %{blue: "u4"}
             }).leaders == %{red: "u1", blue: "u4"}
    end
  end

  describe "ensure_membership" do
    test "adds the user to some team if the game has not yet started" do
      assert "u1" in (%GameState{}
                      |> GameState.ensure_membership("u1")
                      |> GameState.all_user_ids())
    end

    test "doesn't add the user to any team if the game has already started" do
      assert "u1" not in (%GameState{round: 1}
                          |> GameState.ensure_membership("u1")
                          |> GameState.all_user_ids())
    end

    test "doesn't add the user to any team if they're already a member" do
      updated_teams =
        GameState.ensure_membership(
          %GameState{teams: %{red: MapSet.new(["u1", "u3"]), blue: MapSet.new(["u2"])}},
          "u3"
        ).teams

      assert "u1" in updated_teams.red
      assert "u3" in updated_teams.red
      assert "u2" in updated_teams.blue
      assert "u3" not in updated_teams.blue
    end
  end
end
