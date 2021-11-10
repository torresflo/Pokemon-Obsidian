module Battle
  module Effects
    class Ability
      class SlowStart < Ability
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if user != self.target || move.special? || user.turn_count >= 5

          return 0.5
        end

        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return target.turn_count < 5 ? 1.5 : 1
        end
      end
      register(:slow_start, SlowStart)
    end
  end
end
