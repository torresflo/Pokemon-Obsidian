module Battle
  module Effects
    class Item
      class OranBerry < Berry
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target
          return if skill&.be_method == :s_thief && launcher&.item_db_symbol == :__undef__

          process_effect(target, launcher, skill)
        end

        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?

          process_effect(@target, nil, nil)
        end

        # Function that executes the effect of the berry (for Pluck & Bug Bite)
        # @param force_heal [Boolean] tell if a healing berry should force the heal
        def execute_berry_effect(force_heal: false)
          # Remove the following line if the berry should be executed only if the condition match
          define_singleton_method(:hp_rate_trigger) { 1 } if force_heal
          process_effect(@target, nil, nil)
        end

        private

        # Function that process the effect of the berry (if possible)
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def process_effect(target, launcher, skill)
          return if cannot_be_consumed? || target.hp_rate > hp_rate_trigger
          return if target.dead?

          @logic.damage_handler.heal(target, hp_healed) do
            item_name = target.item_name
            consume_berry(target, launcher, skill, should_confuse: should_confuse)
            @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 914, target, PFM::Text::ITEM2[1] => item_name))
          end
        end

        # Give the hp rate that triggers the berry
        # @return [Float]
        def hp_rate_trigger
          return 0.5
        end

        # Give the amount of HP healed
        # @return [Integer]
        def hp_healed
          return 10
        end

        # Tell if the berry effect should confuse
        # @return [Boolean]
        def should_confuse
          return false
        end
      end

      class SitrusBerry < OranBerry
        private

        # Give the amount of HP healed
        # @return [Integer]
        def hp_healed
          return (@target.max_hp / 4).clamp(1, Float::INFINITY)
        end
      end

      class ConfusingBerries < OranBerry
        # Give the hp rate that triggers the berry
        # @return [Float]
        def hp_rate_trigger
          return @target.has_ability?(:gluttony) ? 0.5 : 0.25
        end

        # Give the amount of HP healed
        # @return [Integer]
        def hp_healed
          return (@target.max_hp / 3).clamp(1, Float::INFINITY)
        end

        # Tell if the berry effect should confuse
        # @return [Boolean]
        def should_confuse
          return true
        end
      end
      register(:oran_berry, OranBerry)
      register(:sitrus_berry, SitrusBerry)
      register(:figy_berry, ConfusingBerries)
      register(:wiki_berry, ConfusingBerries)
      register(:mago_berry, ConfusingBerries)
      register(:aguav_berry, ConfusingBerries)
      register(:iapapa_berry, ConfusingBerries)
    end
  end
end
