module Battle
  module Effects
    class Weather
      class Fog < Weather
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          if $env.decrease_weather_duration
            scene.display_message_and_wait(parse_text(18, 96))
            logic.weather_change_handler.weather_change(:none, 0)
          end
        end
      end
      register(:fog, Fog)
    end
  end
end
