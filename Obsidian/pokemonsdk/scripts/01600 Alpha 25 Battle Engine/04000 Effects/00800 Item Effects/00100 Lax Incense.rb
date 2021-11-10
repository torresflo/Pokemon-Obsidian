module Battle
  module Effects
    class Item
      class LaxIncense < Item
        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if target != @target

          return 0.9
        end
      end
      register(:lax_incense, LaxIncense)
      register(:brightpowder, LaxIncense)
    end
  end
end
