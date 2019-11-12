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

  test "a good guess is recognized" do
    {game, _tally} = Game.new_game("wibble") |> Game.make_move("w")
    assert game.game_state == :good_guess
  end

  test "a good guess wins game" do
    game = Game.new_game("wibble")
    Enum.reduce(game.letters, game, fn (x, acc) ->
        {new_game, _} = Game.make_move(acc, x)
        new_game
        end)
    |> Map.fetch(:game_state)
    |> assert == :won


    # OLD VERSION OF TEST WITHOUT REDUCE
    # game = Game.new_game("wibble")
    # {game, _tally} = Game.make_move(game, "w")
    # {game, _tally} = Game.make_move(game, "i")
    # {game, _tally} = Game.make_move(game, "b")
    # {game, _tally} = Game.make_move(game, "l")
    # {game, _tally} = Game.make_move(game, "e")
    # assert game.game_state == :won

  end

  test "bad guess is recognized" do
    {game, _tally} = Game.new_game("wibble") |> Game.make_move("z")
    assert game.game_state == :bad_guess
    assert game.turns_left == 6
  end

  test "bad guess ends game" do
    game = Game.new_game("w")
    {game, _tally} = Game.make_move(game, "a")
    {game, _tally} = Game.make_move(game, "b")
    {game, _tally} = Game.make_move(game, "c")
    {game, _tally} = Game.make_move(game, "d")
    {game, _tally} = Game.make_move(game, "e")
    {game, _tally} = Game.make_move(game, "f")
    {game, _tally} = Game.make_move(game, "g")
    assert game.game_state == :lost
  end
end

