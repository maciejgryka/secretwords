defmodule Secretwords.GameStateTest do
  use ExUnit.Case

  alias Secretwords.GameState

  test "join joins the right team" do
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
