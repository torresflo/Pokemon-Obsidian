module Battle
  class Logic
    # Handler responsive of calling all the end turn events
    class EndTurnHandler
      include Hooks
      # Create a new end turn handler
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene]
      def initialize(logic, scene)
        @logic = logic
        @scene = scene
      end

      # Function that call all the events (end_turn_event)
      def process_events
        @alive_battlers = @logic.all_alive_battlers.dup
        exec_hooks(EndTurnHandler, :end_turn_event, binding)
        @logic.delete_dead_effects
      end

      class << self
        # Register a end turn event
        # @param reason [String] reason of the event
        # @yieldparam logic [Battle::Logic] logic of the battle
        # @yieldparam scene [Battle::Scene] battle scene
        # @yieldparam battlers [Array<PFM::PokemonBattler>] all alive battlers
        def register_end_turn_event(reason)
          Hooks.register(EndTurnHandler, :end_turn_event, reason) do
            @alive_battlers.reject!(&:dead?)
            yield(@logic, @scene, @alive_battlers)
          end
        end
      end
    end

    EndTurnHandler.register_end_turn_event('PSDK end turn: Effects') do |logic, scene, battlers|
      logic.each_effects(*battlers) do |e|
        e.on_end_turn_event(logic, scene, battlers)
      end
    end
  end
end
