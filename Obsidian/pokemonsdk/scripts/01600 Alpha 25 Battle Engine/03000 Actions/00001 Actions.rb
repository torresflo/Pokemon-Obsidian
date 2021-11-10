module Battle
  # Module containing the action classes for the battle
  module Actions
    # Base class for all actions
    class Base
      # Creates a new action
      # @param scene [Battle::Scene]
      def initialize(scene)
        @scene = scene
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return 1
      end

      # Tell if the action is valid
      # @return [Boolean]
      def valid?
        return self.class != Base
      end

      # Execute the action
      def execute
        return nil
      end
    end
  end
end
