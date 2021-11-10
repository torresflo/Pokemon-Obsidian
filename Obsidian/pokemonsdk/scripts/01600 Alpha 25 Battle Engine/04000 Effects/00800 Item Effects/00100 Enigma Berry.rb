module Battle
  module Effects
    class Item
      class EnigmaBerry < Berry
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

        # Function that executes the effect of the berry (for Pluck & Bug Bite)
        # @param force_heal [Boolean] tell if a healing berry should force the heal
        def execute_berry_effect(force_heal: false)
          # Remove the following line if the berry should be executed only if the condition match
          define_singleton_method(:trigger?) { |_| true } if force_heal
          process_effect(@target, nil, nil)
        end

        private

        # Function that process the effect of the berry (if possible)
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def process_effect(target, launcher, skill)
          return if cannot_be_consumed? || !trigger?(skill)
          return if target.dead?

          @logic.damage_handler.heal(target, hp_healed) do
            item_name = target.item_name
            consume_berry(target, launcher, skill)
            @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 914, target, PFM::Text::ITEM2[1] => item_name))
          end
        end

        # Tell if the berry triggers
        # @param move [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def trigger?(move)
          return move&.super_effective?
        end

        # Give the amount of HP healed
        # @return [Integer]
        def hp_healed
          return (@target.max_hp / 4).clamp(1, Float::INFINITY)
        end
      end
      register(:enigma_berry, EnigmaBerry)
    end
  end
end
