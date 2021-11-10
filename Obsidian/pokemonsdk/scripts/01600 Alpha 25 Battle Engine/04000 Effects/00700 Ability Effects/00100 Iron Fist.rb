module Battle
  module Effects
    class Ability
      class IronFist < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target

          return move.punching? ? 1.2 : 1
        end
      end
      register(:iron_fist, IronFist)
    end
  end
end
