module Battle
  module Effects
    class Ability
      class DrySkin < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if target != self.target

          return move.type == GameData::Types::FIRE ? 1.25 : 1
        end

        # Function called when a damage_prevention is checked
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def on_damage_prevention(handler, hp, target, launcher, skill)
          return unless skill&.type_water? && target == self.target
          return unless launcher.can_be_lowered_or_canceled?

          return handler.prevent_change do
            handler.scene.visual.show_ability(target)
            handler.logic.damage_handler.heal(target, target.max_hp / 4)
          end
        end

        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(target)
          return if target.dead?

          if $env.rain?
            scene.visual.show_ability(target)
            logic.damage_handler.heal(target, target.max_hp / 8)
          elsif $env.sunny?
            scene.visual.show_ability(target)
            logic.damage_handler.damage_change((target.max_hp / 8).clamp(1, Float::INFINITY), target)
          end
        end
      end
      register(:dry_skin, DrySkin)
    end
  end
end
