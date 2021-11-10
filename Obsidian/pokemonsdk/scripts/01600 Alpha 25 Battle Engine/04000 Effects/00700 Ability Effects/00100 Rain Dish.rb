module Battle
  module Effects
    class Ability
      class RainDish < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target) && $env.rain?
          return if @target.hp == @target.max_hp
          return if @target.dead?

          scene.visual.show_ability(@target)
          logic.damage_handler.heal(target, target.max_hp / 16)
        end
      end
      register(:rain_dish, RainDish)
    end
  end
end
