module Battle
  module Effects
    class FieldTerrain
      class Electric < FieldTerrain
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          @internal_counter -= 1
          logic.fterrain_change_handler.fterrain_change(:none) if @internal_counter <= 0
        end

        # Function called when a status_prevention is checked
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          return unless target.affected_by_terrain? && status == :sleep

          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 1207, target))
          end
        end

        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1 unless move.type_electric? && user.affected_by_terrain?

          return 1.5
        end

        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false unless target.affected_by_terrain? && move.status?
          return false unless move.status_effect == GameData::States::ASLEEP || move.db_symbol == :yawn

          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 1207, target))
          return true
        end
      end
      register(:electric_terrain, Electric)
    end
  end
end
