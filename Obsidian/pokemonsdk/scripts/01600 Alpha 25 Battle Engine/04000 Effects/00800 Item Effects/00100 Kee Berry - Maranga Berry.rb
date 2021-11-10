module Battle
  module Effects
    class Item
      class KeeBerry < Berry
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target
          return if skill&.be_method == :s_thief && launcher&.item_db_symbol == :__undef__
          return unless trigger?(skill) && launcher

          process_effect(target, launcher, skill)
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
          @logic.stat_change_handler.stat_change_with_process(stat_increased, 1, target, launcher, skill)
        end

        # Stat increased on hit
        # @return [Symbol]
        def stat_increased
          return :dfe
        end

        # Tell if the berry triggers
        # @param skill [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def trigger?(skill)
          skill&.physical?
        end
      end

      class MarangaBerry < KeeBerry
        # Stat increased on hit
        # @return [Symbol]
        def stat_increased
          return :dfs
        end

        # Tell if the berry triggers
        # @param skill [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def trigger?(skill)
          skill&.special?
        end
      end
      register(:kee_berry, KeeBerry)
      register(:maranga_berry, MarangaBerry)
    end
  end
end
