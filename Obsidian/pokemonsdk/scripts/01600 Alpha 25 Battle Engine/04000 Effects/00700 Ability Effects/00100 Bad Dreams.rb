module Battle
  module Effects
    class Ability
      class BadDreams < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?

          sleeping_foes = logic.foes_of(@target).select(&:asleep?)
          return unless sleeping_foes.any?

          scene.visual.show_ability(@target) if sleeping_foes.any?
          sleeping_foes.each do |sleeping_foe|
            hp = sleeping_foe.max_hp / 8
            logic.damage_handler.damage_change(hp.clamp(1, Float::INFINITY), sleeping_foe)
          end
        end
      end
      register(:bad_dreams, BadDreams)
    end
  end
end
