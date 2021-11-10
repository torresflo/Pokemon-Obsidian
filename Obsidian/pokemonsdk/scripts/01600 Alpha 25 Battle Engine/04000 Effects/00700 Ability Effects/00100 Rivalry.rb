module Battle
  module Effects
    class Ability
      class Rivalry < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target
          return 1 if (user.gender * target.gender) == 0
          return 1.25 if user.gender == target.gender

          return 0.75
        end
      end
      register(:rivalry, Rivalry)
    end
  end
end
