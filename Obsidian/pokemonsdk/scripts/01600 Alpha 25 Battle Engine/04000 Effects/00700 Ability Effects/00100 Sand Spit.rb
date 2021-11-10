module Battle
  module Effects
    class Ability
      class SandSpit < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill

          weather_handler = handler.logic.weather_change_handler
          return unless weather_handler.weather_appliable?(:sandstorm)

          nb_turn = target.hold_item?(:smooth_rock) ? 8 : 5
          weather_handler.weather_change(:sandstorm, nb_turn)
          handler.scene.visual.show_ability(target)
          handler.scene.visual.show_rmxp_animation(target, 494)
        end
      end
      register(:sand_spit, SandSpit)
    end
  end
end
