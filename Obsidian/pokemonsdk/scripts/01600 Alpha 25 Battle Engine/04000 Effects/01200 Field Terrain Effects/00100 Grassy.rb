module Battle
  module Effects
    class FieldTerrain
      class Grassy < FieldTerrain
        # List of moves reduced by grassy terrain
        GRASSY_REDUCED_MOVES = %i[earthquake magnitude bulldoze]
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          @internal_counter -= 1
          if @internal_counter <= 0
            logic.fterrain_change_handler.fterrain_change(:none)
          else
            battlers.each do |battler|
              next unless battler.affected_by_terrain?
              next if battler.dead?

              logic.damage_handler.heal(battler, battler.max_hp / 16)
            end
          end
        end

        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1.5 if move.type_grass? && user.affected_by_terrain?
          return 0.5 if GRASSY_REDUCED_MOVES.include?(db_symbol) && user.affected_by_terrain?

          return 1
        end
      end
      register(:grassy_terrain, Grassy)
    end
  end
end
