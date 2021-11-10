module Battle
  class Logic
    # Class responsive of describing the minimum functionality of change handlers
    class ChangeHandlerBase
      # Get the logic
      # @return [Battle::Logic]
      attr_reader :logic
      # Get the scene
      # @return [Battle::Scene]
      attr_reader :scene
      # Create a new ChangeHandler
      # @param logic [Battle::Logic]
      # @param scene [Battle::Scene]
      def initialize(logic, scene)
        @logic = logic
        @scene = scene
        # @type [Proc]
        @reason = nil
      end

      # Process the reason a change could not be done
      def process_prevention_reason
        @reason&.call
      end

      # Reset the reason why change cannot be done
      def reset_prevention_reason
        @reason = nil
      end

      # Function that register a reason why the change is not possible
      # @param reason [Proc] reason that will be registered
      # @return [:prevent] :prevent to make easier the return of hooks
      def prevent_change(&reason)
        @reason = reason
        return :prevent
      end
    end
  end
end
