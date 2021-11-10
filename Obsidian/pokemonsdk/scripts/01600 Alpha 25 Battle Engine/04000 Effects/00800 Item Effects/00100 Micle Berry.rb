module Battle
  module Effects
    class Item
      class MicleBerry < Berry
        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if user != @target || user.hp_rate > hp_rate_trigger

          return 1.5
        end

        private

        # Give the hp rate that triggers the berry
        # @return [Float]
        def hp_rate_trigger
          return @target.has_ability?(:gluttony) ? 0.5 : 0.25
        end
      end
      register(:micle_berry, MicleBerry)
    end
  end
end
