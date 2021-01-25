defmodule Secretwords.GameStateTest do
  use ExUnit.Case

  alias Secretwords.{GameState, WordSlot}

  describe "join" do
    test "joins the right team" do
      game = %GameState{} |> GameState.join(:red, "member1")
      assert game.teams[:red] == ["member1"]
    end

    test "ensures members are unique" do
      game = %GameState{}
      |> GameState.join(:red, "member1")
      |> GameState.join(:red, "member1")
      assert game.teams[:red] == ["member1"]
    end

    test "allows multiple members" do
      game = %GameState{}
      |> GameState.join(:red, "member1")
      |> GameState.join(:red, "member2")
      assert game.teams[:red] == ["member2", "member1"]
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

  describe "leave" do
    test "leaves the team if given user is a member" do
      assert GameState.leave(
        %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
        :red,
        "u1"
      ).teams ==%{red: ["u2"], blue: ["u3"]}

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

  describe "choose_word" do
    test "chooses a word" do
      assert GameState.choose_word(
        %GameState{word_slots: [
          %WordSlot{word: "one", used: false},
          %WordSlot{word: "two", used: false},
        ]},
        "two"
      ) == %GameState{word_slots: [
        %WordSlot{word: "one", used: false},
        %WordSlot{word: "two", used: true},
      ]}
    end

    test "does nothing for a non-existent word" do
      assert GameState.choose_word(
        %GameState{word_slots: [
          %WordSlot{word: "one", used: false},
          %WordSlot{word: "two", used: false},
        ]},
        "three"
      ) == %GameState{word_slots: [
        %WordSlot{word: "one", used: false},
        %WordSlot{word: "two", used: false},
      ]}
    end
  end

  describe  "ensure_leaders"  do
    test "makes leaders out of sole members" do
      assert GameState.ensure_leaders(
        %GameState{teams: %{red: [], blue: ["u1"]}}
      ).leaders == %{blue: "u1"}

      assert GameState.ensure_leaders(
        %GameState{teams: %{red: ["u2"], blue: ["u1"]}}
      ).leaders == %{red: "u2", blue: "u1"}
    end

    test "removes leaders of empty tems" do
      assert GameState.ensure_leaders(
        %GameState{
          teams: %{red: [], blue: ["u1"]},
          leaders:  %{red: "u3", blue: "u1"},
        }
      ).leaders == %{blue: "u1"}
    end

    test "leaves existing valid leaders" do
      assert GameState.ensure_leaders(
        %GameState{
          teams: %{red: ["u1", "u2", "u3"], blue: ["u4"]},
          leaders:  %{red: "u2", blue: "u4"},
        }
      ).leaders == %{red: "u2", blue: "u4"}
    end

    test "picks a leader for non-empty, leaderless teams" do
      assert GameState.ensure_leaders(
        %GameState{
          teams: %{red: ["u1", "u2", "u3"], blue: ["u4"]},
          leaders:  %{blue: "u4"},
        }
      ).leaders == %{red: "u1", blue: "u4"}
    end
  end
end
