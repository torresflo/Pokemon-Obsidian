module Battle
  module Effects
    class Ability
      class AirLock < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target || $env.current_weather_db_symbol == :none

          handler.scene.visual.show_ability(with)
          handler.logic.weather_change_handler.weather_change(:none, 0)
        end

        # Function called when a weather_prevention is checked
        # @param handler [Battle::Logic::WeatherChangeHandler]
        # @param weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
        # @param last_weather [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_weather_prevention(handler, weather_type, last_weather)
          return if weather_type == :none

          return handler.prevent_change do
            handler.scene.visual.show_ability(@target)
          end
        end
      end
      register(:air_lock, AirLock)
      register(:cloud_nine, AirLock)
    end
  end
end
