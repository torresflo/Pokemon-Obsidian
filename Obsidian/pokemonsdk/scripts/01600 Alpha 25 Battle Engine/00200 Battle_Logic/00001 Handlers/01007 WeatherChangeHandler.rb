module Battle
  class Logic
    # Handler responsive of answering properly weather changes requests
    class WeatherChangeHandler < ChangeHandlerBase
      include Hooks
      # Mapping between weather symbol & message_id
      WEATHER_SYM_TO_MSG = {
        none: 97,
        rain: 88,
        sunny: 87,
        sandstorm: 89,
        hail: 90,
        fog: 91
      }

      # Create a new Weather Change Handler
      # @param logic [Battle::Logic]
      # @param scene [Battle::Scene]
      # @param env [PFM::Environnement]
      def initialize(logic, scene, env = $env)
        super(logic, scene)
        @env = env
      end

      # Function telling if a weather can be applyied
      # @param weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      # @return [Boolean]
      def weather_appliable?(weather_type)
        log_data("# weather_appliable?(#{weather_type})")
        reset_prevention_reason
        last_weather = @env.current_weather_db_symbol
        exec_hooks(WeatherChangeHandler, :weather_prevention, binding)
        return true
      rescue Hooks::ForceReturn => e
        log_data("# FR: weather_appliable? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that actually change the weather
      # @param weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      # @param nb_turn [Integer, nil] Number of turn, use nil for Infinity
      def weather_change(weather_type, nb_turn)
        log_data("# weather_change(#{weather_type}, #{nb_turn})")
        last_weather = @env.current_weather_db_symbol
        @env.apply_weather(weather_type, nb_turn)
        show_weather_message(last_weather, weather_type)
        exec_hooks(WeatherChangeHandler, :post_weather_change, binding)
      rescue Hooks::ForceReturn => e
        log_data("# FR: weather_change #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Function that test if the change is possible and perform the change if so
      # @param weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
      # @param nb_turn [Integer, nil] Number of turn, use nil for Infinity
      def weather_change_with_process(weather_type, nb_turn)
        return process_prevention_reason unless weather_appliable?(weather_type)

        weather_change(weather_type, nb_turn)
      end

      private

      # Show the weather message
      # @param last_weather [Symbol]
      # @param current_weather [Symbol]
      def show_weather_message(last_weather, current_weather)
        return if last_weather == current_weather

        @scene.display_message_and_wait(parse_text(18, WEATHER_SYM_TO_MSG[current_weather])) if last_weather == :none || current_weather == :none
      end

      class << self
        # Function that registers a weather_prevention hook
        # @param reason [String] reason of the weather_prevention registration
        # @yieldparam handler [WeatherChangeHandler]
        # @yieldparam weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
        # @yieldparam last_weather [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
        # @yieldreturn [:prevent, nil] :prevent if the status cannot be applied
        def register_weather_prevention_hook(reason)
          Hooks.register(WeatherChangeHandler, :weather_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:weather_type),
              hook_binding.local_variable_get(:last_weather)
            )
            force_return(false) if result == :prevent
          end
        end

        # Function that registers a post_weather_change hook
        # @param reason [String] reason of the post_weather_change registration
        # @yieldparam handler [WeatherChangeHandler]
        # @yieldparam weather_type [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
        # @yieldparam last_weather [Symbol] :none, :rain, :sunny, :sandstorm, :hail, :fog
        def register_post_weather_change_hook(reason)
          Hooks.register(WeatherChangeHandler, :post_weather_change, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:weather_type),
              hook_binding.local_variable_get(:last_weather)
            )
          end
        end
      end
    end

    WeatherChangeHandler.register_weather_prevention_hook('PSDK prev weather: Effects') do |handler, weather_type, last_weather|
      next handler.logic.each_effects(*handler.logic.all_alive_battlers) do |e|
        next e.on_weather_prevention(handler, weather_type, last_weather)
      end
    end
    WeatherChangeHandler.register_post_weather_change_hook('PSDK post weather: Effects') do |handler, weather_type, last_weather|
      next handler.logic.each_effects(*handler.logic.all_alive_battlers) do |e|
        next e.on_post_weather_change(handler, weather_type, last_weather)
      end
    end

    WeatherChangeHandler.register_weather_prevention_hook('PSDK prev weather: Duplicate weather') do |_, weather, prev|
      next if weather != prev

      next :prevent
    end
  end
end
