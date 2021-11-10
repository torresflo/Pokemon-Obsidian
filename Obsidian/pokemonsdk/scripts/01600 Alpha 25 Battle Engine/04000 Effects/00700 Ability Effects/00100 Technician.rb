module Battle
  module Effects
    class Ability
      class Technician < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target

          return move.power <= 60 ? 1.5 : 1
        end
      end
      register(:technician, Technician)
    end
  end
end
