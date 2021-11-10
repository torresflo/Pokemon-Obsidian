module Battle
  module Effects
    class Ability
      class VictoryStar < Ability
        # Create a new VictoryStar effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if user.bank != @target.bank

          return 1.1
        end
      end
      register(:victory_star, VictoryStar)
    end
  end
end
