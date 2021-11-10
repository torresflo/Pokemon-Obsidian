module Battle
  module Effects
    class Item
      class WideLens < Item
        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if user != @target

          return 1.1
        end
      end
      register(:wide_lens, WideLens)
    end
  end
end
