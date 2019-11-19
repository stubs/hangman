defmodule Hangman.Game do

    defstruct(
        turns_left: 7,
        game_state: :initializing,
        letters: [],
        used: MapSet.new()
        # list_used: []
    )

    def new_game(word) do
        %Hangman.Game{
            letters: word |> String.codepoints
        }
    end

    def new_game() do
            new_game(Dictionary.random_word())
    end

    # Using a when clause (also called a guard clause)
    def make_move(game = %{game_state: state}, _guess) when state in [ :won, :lost] do
        game
    end

    def make_move(game, guess) do
        accept_move(game, guess, MapSet.member?(game.used, guess))
        # accept_move(game, guess, Enum.member?(game.list_used, guess))
    end

    @docp """
    this works, but not really DRY.
    defp make_move(game = %{game_state: :won}, _guess) do
        {game, tally(game)}
    end

    defp make_move(game = %{game_state: :lost}, _guess) do
        {game, tally(game)}
    end
    """

    def tally(game) do
        %{
            game_state: game.game_state,
            turns_left: game.turns_left,
            letters:    reveal_guessed(game.letters, game.used),
            used:       game.used
        }
    end

###############################################################################

    defp reveal_guessed(letters, used) do
        letters
        |> Enum.map(fn letter -> reveal_letter(letter, MapSet.member?(used, letter)) end)
    end

    defp reveal_letter(letter, _is_in_word=true),   do: letter
    defp reveal_letter(_letter, _is_not_in_word),    do: "_"

    defp accept_move(game, _guess, _already_guessed=true) do
        Map.put(game, :game_state, :already_used)
    end

    defp accept_move(game, guess, _already_guessed) do
        Map.put(game, :used, MapSet.put(game.used, guess))
        # Map.put(game, :list_used, [ guess | game.used ])
        |> score_guess(Enum.member?(game.letters, guess))
    end

    defp score_guess(game, _good_guess=true) do
        new_state = MapSet.new(game.letters)
        |> MapSet.subset?(game.used)
        |> maybe_won()
        Map.put(game, :game_state, new_state)
    end

    defp score_guess(game = %{turns_left: 1}, _not_good_guess) do
        Map.put(game, :game_state, :lost)
    end

    defp score_guess(game = %{turns_left: turns_left}, _not_good_guess) do
        %{ game |
            game_state: :bad_guess,
            turns_left: turns_left - 1
         }
    end

    defp maybe_won(true),   do: :won
    defp maybe_won(_),      do: :good_guess
end
