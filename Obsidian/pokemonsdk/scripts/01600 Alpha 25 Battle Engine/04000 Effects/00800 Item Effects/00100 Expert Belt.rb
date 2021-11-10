module Battle
  module Effects
    class Item
      class ExpertBelt < Item
        # Give the move mod3 mutiplier (after everything)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod3_multiplier(user, target, move)
          return 1 if user != @target || !move.super_effective?

          return 1.2
        end
      end
      register(:expert_belt, ExpertBelt)
    end
  end
end
