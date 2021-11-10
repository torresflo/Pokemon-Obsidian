module Battle
  module Effects
    class Ability
      class Aftermath < Ability
        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0
          return if launcher.has_ability?(:damp)

          damages = (launcher.max_hp / 4).clamp(1, Float::INFINITY)
          handler.scene.visual.show_ability(target)
          handler.scene.visual.show_hp_animations([launcher], [-damages])
        end
      end
      register(:aftermath, Aftermath)
    end
  end
end
