module Battle
  module Effects
    class Ability
      class ZenMode < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          who.form_calibrate if who == @target && who != with
          return if with != @target

          original_form = with.form
          with.form_calibrate(:battle)
          if with.form != original_form
            handler.scene.visual.show_ability(with)
            handler.scene.visual.show_switch_form_animation(with)
            handler.scene.display_message_and_wait(parse_text(18, with.form.odd? ? 191 : 192))
          end
        end

        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?

          original_form = @target.form
          @target.form_calibrate(:battle)
          return if @target.form == original_form

          scene.visual.show_ability(@target)
          scene.visual.show_switch_form_animation(@target)
          scene.display_message_and_wait(parse_text(18, @target.form.odd? ? 191 : 192))
        end
      end
      register(:zen_mode, ZenMode)
    end
  end
end
