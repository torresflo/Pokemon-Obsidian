module Battle
  module Effects
    class Item
      class JabocaBerry < Berry
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

        private

        # Function that process the effect of the berry (if possible)
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def process_effect(target, launcher, skill)
          return if cannot_be_consumed?

          consume_berry(target, launcher, skill)
          @logic.damage_handler.damage_change((launcher.max_hp / 8).clamp(1, Float::INFINITY), launcher)
          @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 402, launcher))
        end

        # Tell if the berry triggers
        # @param skill [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def trigger?(skill)
          skill&.physical?
        end
      end

      class RowapBerry < JabocaBerry
        # Tell if the berry triggers
        # @param skill [Battle::Move, nil] Potential move used
        # @return [Boolean]
        def trigger?(skill)
          skill&.special?
        end
      end
      register(:jaboca_berry, JabocaBerry)
      register(:rowap_berry, RowapBerry)
    end
  end
end
