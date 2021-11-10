module Battle
  module Effects
    class Ability
      class LeafGuard < Ability
        # List of messages when leaf guard is active
        STATUS_LEAF_GUARD_MSG = { poison: 252, toxic: 252, sleep: 318, freeze: 300, paralysis: 285, burn: 270 }
        # Function called when a status_prevention is checked
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          msg_id = STATUS_LEAF_GUARD_MSG[status]
          return if target != @target
          return unless msg_id && $env.sunny?
          return unless launcher&.can_be_lowered_or_canceled?

          return handler.prevent_change do
            handler.scene.visual.show_ability(target)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, msg_id, target))
          end
        end
      end
      register(:leaf_guard, LeafGuard)
    end
  end
end
