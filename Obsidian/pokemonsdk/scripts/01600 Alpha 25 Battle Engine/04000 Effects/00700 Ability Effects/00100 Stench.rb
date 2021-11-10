module Battle
  module Effects
    class Ability
      class Stench < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if launcher != @target || launcher.hold_item?(:king_s_rock) || launcher.hold_item?(:razor_fang)
          return unless skill&.direct? && launcher.hp > 0 && bchance?(0.1, @logic)

          handler.scene.visual.show_ability(launcher)
          handler.logic.status_change_handler.status_change_with_process(:flinch, target)
        end
      end
      register(:stench, Stench)
    end
  end
end
