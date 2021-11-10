module Battle
  module Effects
    class Item
      class StatusBerry < Berry
        # Function called when a post_status_change is performed
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_status_change(handler, status, target, launcher, skill)
          return if target != @target || status != healed_status

          process_effect(@target, launcher, skill)
        end

        # Function that executes the effect of the berry (for Pluck & Bug Bite)
        # @param force_heal [Boolean] tell if a healing berry should force the heal
        def execute_berry_effect(force_heal: false)
          process_effect(@target, nil, nil) if @target.status_effect.name == healed_status
        end

        private

        # Function that process the effect of the berry (if possible)
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def process_effect(target, launcher, skill)
          return if cannot_be_consumed?

          consume_berry(target, launcher, skill)
          @logic.status_change_handler.status_change(:cure, target, launcher, skill)
        end

        # Tell which status the berry tries to fix
        # @return [Symbol]
        def healed_status
          return :freeze
        end

        class Rawst < StatusBerry
          # Tell which status the berry tries to fix
          # @return [Symbol]
          def healed_status
            return :burn
          end
        end

        class Pecha < StatusBerry
          # Tell which status the berry tries to fix
          # @return [Symbol]
          def healed_status
            return :poison
          end
        end

        class Chesto < StatusBerry
          # Tell which status the berry tries to fix
          # @return [Symbol]
          def healed_status
            return :sleep
          end
        end

        class Cheri < StatusBerry
          # Tell which status the berry tries to fix
          # @return [Symbol]
          def healed_status
            return :paralysis
          end
        end
      end
      register(:aspear_berry, StatusBerry)
      register(:rawst_berry, StatusBerry::Rawst)
      register(:pecha_berry, StatusBerry::Pecha)
      register(:chesto_berry, StatusBerry::Chesto)
      register(:cheri_berry, StatusBerry::Cheri)
    end
  end
end
