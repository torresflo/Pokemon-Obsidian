module Battle
  module Effects
    class Ability
      class Drizzle < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          weather_handler = handler.logic.weather_change_handler
          return unless weather_handler.weather_appliable?(weather)

          handler.scene.visual.show_ability(with)
          nb_turn = with.hold_item?(item_db_symbol) ? 8 : 5
          weather_handler.weather_change(weather, nb_turn)
          handler.scene.visual.show_rmxp_animation(with, animation_id)
        end

        private

        # Tell the weather to set
        # @return [Symbol]
        def weather
          return :rain
        end

        # Tell which item increase the turn count
        # @return [Symbol]
        def item_db_symbol
          return :damp_rock
        end

        # Tell which animation to play
        # @return [Integer]
        def animation_id
          493
        end
      end
      register(:drizzle, Drizzle)

      class Drought < Drizzle
        private

        # Tell the weather to set
        # @return [Symbol]
        def weather
          return :sunny
        end

        # Tell which item increase the turn count
        # @return [Symbol]
        def item_db_symbol
          return :heat_rock
        end

        # Tell which animation to play
        # @return [Integer]
        def animation_id
          492
        end
      end
      register(:drought, Drought)

      class SandStream < Drizzle
        private

        # Tell the weather to set
        # @return [Symbol]
        def weather
          return :sandstorm
        end

        # Tell which item increase the turn count
        # @return [Symbol]
        def item_db_symbol
          return :smooth_rock
        end

        # Tell which animation to play
        # @return [Integer]
        def animation_id
          494
        end
      end
      register(:sand_stream, SandStream)

      class SnowWarning < Drizzle
        private

        # Tell the weather to set
        # @return [Symbol]
        def weather
          return :hail
        end

        # Tell which item increase the turn count
        # @return [Symbol]
        def item_db_symbol
          return :icy_rock
        end

        # Tell which animation to play
        # @return [Integer]
        def animation_id
          494
        end
      end
      register(:snow_warning, SnowWarning)
    end
  end
end
