module Battle
  class Move
    class TerrainMove < Move
      TERRAIN_MOVES = {
        electric_terrain: :electric_terrain,
        grassy_terrain: :grassy_terrain,
        misty_terrain: :misty_terrain,
        psychic_terrain: :psychic_terrain
      }

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        logic.fterrain_change_handler.fterrain_change_with_process(TERRAIN_MOVES[db_symbol])
        # TODO: Add animations into the terrain_change_handler
      end
    end
    Move.register(:s_terrain, TerrainMove)
  end
end
