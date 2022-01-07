module Battle
  module Effects
    class Item
      class ShellBell < Item
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if launcher != @target
          return unless skill && hp >= 8 && launcher != target

          handler.scene.visual.show_item(launcher)
          handler.logic.damage_handler.heal(launcher, hp / 8)
        end
        alias on_post_damage_death on_post_damage
      end
      register(:shell_bell, ShellBell)
    end
  end
end
