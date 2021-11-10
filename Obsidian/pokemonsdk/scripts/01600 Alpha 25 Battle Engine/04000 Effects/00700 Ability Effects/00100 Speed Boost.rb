module Battle
  module Effects
    class Ability
      class SpeedBoost < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?
          return if @target.switching? && !@switch_by_ko

          @switch_by_ko = false
          if logic.stat_change_handler.stat_increasable?(:spd, @target)
            scene.visual.show_ability(@target)
            logic.stat_change_handler.stat_change_with_process(:spd, 1, @target)
          end
        end

        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return unless with == @target
          return unless who.dead?
          return @switch_by_ko = true unless @logic.actions.empty?

          if @logic.stat_change_handler.stat_increasable?(:spd, @target)
            @logic.scene.visual.show_ability(@target)
            @logic.stat_change_handler.stat_change_with_process(:spd, 1, @target)
          end
        end
      end
      register(:speed_boost, SpeedBoost)
    end
  end
end
