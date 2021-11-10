module Battle
  module Effects
    class Ability
      class Moody < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?

          stats = Battle::Logic::StatChangeHandler::ALL_STATS
          stat_up = stats.select do |stat|
            logic.stat_change_handler.stat_increasable?(stat, @target)
          end.sample(random: logic.generic_rng)
          stat_down = stats.select do |stat|
            stat != stat_up && logic.stat_change_handler.stat_decreasable?(stat, @target)
          end.sample(random: logic.generic_rng)
          return unless stat_down && stat_up

          scene.visual.show_ability(@target)
          logic.stat_change_handler.stat_change_with_process(stat_up, 2, @target)
          logic.stat_change_handler.stat_change_with_process(stat_down, -1, @target)
        end
      end
      register(:moody, Moody)
    end
  end
end
