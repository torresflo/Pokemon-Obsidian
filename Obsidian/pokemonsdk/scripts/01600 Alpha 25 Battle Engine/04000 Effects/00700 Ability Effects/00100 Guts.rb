module Battle
  module Effects
    class Ability
      class Guts < Ability
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if user != @target || user.status_effect.instance_of?(Status)

          return move.physical? ? 1.5 : 1
        end
      end
      register(:guts, Guts)
    end
  end
end
