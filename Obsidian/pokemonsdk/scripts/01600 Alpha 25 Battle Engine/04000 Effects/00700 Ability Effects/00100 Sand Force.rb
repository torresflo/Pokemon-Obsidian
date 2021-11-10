module Battle
  module Effects
    class Ability
      class SandForce < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target
          return 1 unless $env.sandstorm?
          return 1.3 if move.type_steel? || move.type_rock? || move.type_ground?

          return 1
        end
      end
      register(:sand_force, SandForce)
    end
  end
end
