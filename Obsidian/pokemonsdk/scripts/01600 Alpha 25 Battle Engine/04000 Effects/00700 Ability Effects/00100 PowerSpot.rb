module Battle
  module Effects
    class Ability
      class PowerSpot < Ability
        # Create a new PowerSpot effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user.bank != self.target.bank

          return 1.2
        end
      end

      register(:power_spot, PowerSpot)
    end
  end
end
