module Battle
  module Effects
    class Item
      class HpTriggeredStatBerries < Berry
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

          consume_berry(target, launcher, skill, should_confuse: should_confuse)
          @logic.stat_change_handler.stat_change_with_process(stat_improved, 1, target, launcher, skill)
        end

        # Give the hp rate that triggers the berry
        # @return [Float]
        def hp_rate_trigger
          return @target.has_ability?(:gluttony) ? 0.5 : 0.25
        end

        # Give the stat it should improve
        # @return [Symbol]
        def stat_improved
          return :atk
        end

        # Tell if the berry effect should confuse
        # @return [Boolean]
        def should_confuse
          return false
        end

        class Ganlon < HpTriggeredStatBerries
          # Give the stat it should improve
          # @return [Symbol]
          def stat_improved
            return :dfe
          end
        end

        class Salac < HpTriggeredStatBerries
          # Give the stat it should improve
          # @return [Symbol]
          def stat_improved
            return :spd
          end
        end

        class Petaya < HpTriggeredStatBerries
          # Give the stat it should improve
          # @return [Symbol]
          def stat_improved
            return :ats
          end
        end

        class Apicot < HpTriggeredStatBerries
          # Give the stat it should improve
          # @return [Symbol]
          def stat_improved
            return :dfs
          end
        end

        class Starf < HpTriggeredStatBerries
          # Give the stat it should improve
          # @return [Symbol]
          def stat_improved
            return Battle::Logic::StatChangeHandler::ALL_STATS.sample(random: @logic.generic_rng)
          end
        end
      end
      register(:liechi_berry, HpTriggeredStatBerries)
      register(:ganlon_berry, HpTriggeredStatBerries::Ganlon)
      register(:salac_berry, HpTriggeredStatBerries::Salac)
      register(:petaya_berry, HpTriggeredStatBerries::Petaya)
      register(:apicot_berry, HpTriggeredStatBerries::Apicot)
      register(:starf_berry, HpTriggeredStatBerries::Starf)
    end
  end
end
