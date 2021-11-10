module Battle
  module Effects
    class Item
      class PersimBerry < Berry
        # Function called when a post_status_change is performed
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_status_change(handler, status, target, launcher, skill)
          return if target != @target || status != :confusion

          process_effect(@target, launcher, skill)
        end

        # Function that executes the effect of the berry (for Pluck & Bug Bite)
        def execute_berry_effect
          process_effect(@target, nil, nil) if @target.confused?
        end

        private

        # Function that process the effect of the berry (if possible)
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def process_effect(target, launcher, skill)
          return if cannot_be_consumed?

          consume_berry(target, launcher, skill)
          @logic.status_change_handler.status_change(:confuse_cure, target, launcher, skill)
        end
      end
      register(:persim_berry, PersimBerry)
    end
  end
end
