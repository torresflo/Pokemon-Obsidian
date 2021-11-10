module Battle
  module Effects
    class Weather
      class Hail < Weather
        # List of abilities that blocks hail damages
        HAIL_BLOCKING_ABILITIES = %i[magic_guard ice_body snow_cloak overcoat]
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          if $env.decrease_weather_duration
            scene.display_message_and_wait(parse_text(18, 95))
            logic.weather_change_handler.weather_change(:none, 0)
          else
            scene.visual.show_rmxp_animation(battlers.first || logic.battler(0, 0), 495)
            scene.display_message_and_wait(parse_text(18, 99))
            battlers.each do |battler|
              next if battler.type_ice?
              next if battler.dead?
              next if HAIL_BLOCKING_ABILITIES.include?(battler.battle_ability_db_symbol)

              logic.damage_handler.damage_change((battler.max_hp / 16).clamp(1, Float::INFINITY), battler)
            end
          end
        end
      end
      register(:hail, Hail)
    end
  end
end
