module Battle
  module Effects
    class Ability
      class PunkRock < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          if user == self.target
            return move.sound_attack? ? 1.3 : 1
          elsif target == self.target && user.can_be_lowered_or_canceled?
            return move.sound_attack? ? 0.5 : 1
          end

          return 1
        end
      end
      register(:punk_rock, PunkRock)
    end
  end
end
