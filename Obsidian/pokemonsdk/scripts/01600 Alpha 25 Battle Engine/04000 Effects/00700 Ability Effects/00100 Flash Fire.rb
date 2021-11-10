module Battle
  module Effects
    class Ability
      class FlashFire < Ability
        # Function called when a damage_prevention is checked
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def on_damage_prevention(handler, hp, target, launcher, skill)
          return if target != @target
          return unless skill&.type_fire?
          return unless launcher&.can_be_lowered_or_canceled?

          return handler.prevent_change do
            handler.logic.status_change_handler.status_change_with_process(:cure, target) if target.frozen?
            handler.scene.visual.show_ability(target)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, @boost_enabled ? 24 : 427, target))
            @boost_enabled = true
          end
        end

        # Function called when a stat_decrease_prevention is checked
        # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
        # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the stat decrease cannot apply
        def on_stat_decrease_prevention(handler, stat, target, launcher, skill)
          return if target != @target
          return unless skill&.type_fire?
          return unless launcher && target != launcher && launcher.can_be_lowered_or_canceled?

          return :prevent
        end

        # Function called when a stat_increase_prevention is checked
        # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
        # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the stat increase cannot apply
        def on_stat_increase_prevention(handler, stat, target, launcher, skill)
          return if target != @target
          return unless skill&.type_fire?
          return unless launcher && target != launcher && launcher.can_be_lowered_or_canceled?

          return :prevent
        end

        # Function called when a status_prevention is checked
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          return if target != @target
          return unless status == :burn
          return unless launcher&.can_be_lowered_or_canceled?

          return handler.prevent_change do
            if skill.status?
              handler.scene.visual.show_ability(target)
              handler.scene.display_message_and_wait(parse_text_with_pokemon(19, @boost_enabled ? 24 : 427, target))
              @boost_enabled = true
            end
          end
        end

        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1 if user != @target || !@boost_enabled

          return move.type_fire? ? 1.5 : 1
        end

        # Reset the boost when leaving battle
        def reset
          @boost_enabled = false
        end
      end
      register(:flash_fire, FlashFire)
    end
  end
end

Hooks.register(PFM::PokemonBattler, :on_reset_states, 'PSDK reset FlashFire') do
  ability_effect.reset if ability_effect.is_a?(Battle::Effects::Ability::FlashFire)
end
