module Battle
  module Effects
    class Ability
      class GorillaTactics < Ability
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if user != @target

          return move.physical? ? 1.5 : 1
        end

        # Function called when we try to check if the user cannot use a move
        # @param user [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Proc, nil]
        def on_move_disabled_check(user, move)
          return if user != @target || user.move_history.empty? || user.move_history.last.db_symbol == move.db_symbol

          return proc {}
        end
      end
      register(:gorilla_tactics, GorillaTactics)
    end
  end
end
