defmodule Secretwords.GameStateTest do
  use ExUnit.Case

  alias Secretwords.GameState

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
      ) == %GameState{teams: %{red: ["u2"], blue: ["u3"]}}

      assert GameState.leave(
        %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
        :blue,
        "u3"
      ) == %GameState{teams: %{red: ["u1", "u2"], blue: []}}
    end

    test "does nothing if the giiven user is not a member" do
      assert GameState.leave(
        %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
        :red,
        "u3"
      ) == %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}}

      assert GameState.leave(
        %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}},
        :red,
        "u4"
      ) == %GameState{teams: %{red: ["u1", "u2"], blue: ["u3"]}}
    end
  end
end
