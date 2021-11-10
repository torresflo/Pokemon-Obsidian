module Battle
  module Effects
    class Item
      class LeppaBerry < Berry
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?
          return if @target.moveset.none? { |move| move.pp == 0 }

          process_effect(@target, nil, nil)
        end

        # Function that executes the effect of the berry (for Pluck & Bug Bite)
        # @param force_heal [Boolean] tell if a healing berry should force the heal
        def execute_berry_effect(force_heal: false)
          return unless force_heal

          process_effect(@target, nil, nil)
        end

        private

        # Function that process the effect of the berry (if possible)
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def process_effect(target, launcher, skill)
          return if cannot_be_consumed?

          consume_berry(target, launcher, skill)
          move = target.moveset.find { |s| s.pp == 0 }
          move ||= target.moveset.reject { |s| s.pp == s.ppmax }.min_by(&:pp)
          move ||= target.moveset.min_by(&:pp)
          @logic.scene.display_message_and_wait(message(target, move))
        end

        # Give the message
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move, nil] Potential move used
        # @return String
        def message(target, move)
          return parse_text_with_pokemon(19, 917, target, PFM::Text::ITEM2[1] => target.item_name, PFM::Text::MOVE[2] => move.name)
        end
      end
      register(:leppa_berry, LeppaBerry)
    end
  end
end
