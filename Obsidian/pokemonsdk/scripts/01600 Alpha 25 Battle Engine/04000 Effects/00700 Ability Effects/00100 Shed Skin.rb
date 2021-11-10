module Battle
  module Effects
    class Ability
      class ShedSkin < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?
          return if @target.status_effect.instance_of?(Status) || bchance?(0.66, logic)

          scene.visual.show_ability(@target)
          logic.status_change_handler.status_change(:cure, @target)
        end
      end
      register(:shed_skin, ShedSkin)
    end
  end
end
