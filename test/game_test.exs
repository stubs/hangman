defmodule GameTest do
  use ExUnit.Case
  alias Hangman.Game

  test "brand new game" do
    assert %{
        turns_left: 7,
        game_state: :initializing,
        letters: _
    } = Game.new_game()

    assert Game.new_game().letters > 0
  end


  test "letters are lowercase ascii" do
    assert Enum.all?(Game.new_game().letters,
                     fn x -> Regex.match?(~r/[a-z]/, x) end
                    ) == true
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [:won, :lost] do       # use "<-" not "in"
        game = Game.new_game() |> Map.put(:game_state, state)
        assert {^game, _} = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not :already_used. " do
    {game, _tally} = Game.new_game() |> Game.make_move("x")
    assert game.game_state != :already_used
  end

  test "occurence of letter is :already_used. " do
    {game, _tally} = Game.new_game() |> Game.make_move("x")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end
end

