module Battle
  module Effects
    class Ability
      class Defeatist < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target
          return 0.5 if user.hp < user.max_hp / 2

          return 1
        end
      end
      register(:defeatist, Defeatist)
    end
  end
end
