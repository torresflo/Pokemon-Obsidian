module Battle
  module Effects
    class Item
      class ZoomLens < Item
        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if user != @target

          return @logic.battler_attacks_after?(user, target) ? 1.2 : 1
        end
      end
      register(:zoom_lens, ZoomLens)
    end
  end
end
