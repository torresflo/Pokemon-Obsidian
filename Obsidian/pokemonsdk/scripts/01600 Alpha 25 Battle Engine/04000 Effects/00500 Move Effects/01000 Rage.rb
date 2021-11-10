module Battle
  module Effects
    # Implement the Rage effect
    class Rage < PokemonTiedEffectBase
      # Function called after damages were applied (post_damage, when target is still alive)
      # @param handler [Battle::Logic::DamageHandler]
      # @param hp [Integer] number of hp (damage) dealt
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      def on_post_damage(handler, hp, target, launcher, skill)
        return if target != @pokemon

        if target.move_history.last.move.be_method == :s_rage
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 532, target))
          handler.logic.stat_change_handler.stat_change_with_process(:atk, 1, target)
        else
          kill
        end
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :rage
      end
    end
  end
end
