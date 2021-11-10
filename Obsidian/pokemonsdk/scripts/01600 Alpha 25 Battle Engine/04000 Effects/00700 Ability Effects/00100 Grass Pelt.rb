module Battle
  module Effects
    class Ability
      class GrassPelt < Ability
        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if target != @target

          return move.physical? && @logic.field_terrain_effect.grassy? ? 1.5 : 1
        end
      end
      register(:grass_pelt, GrassPelt)
    end
  end
end
