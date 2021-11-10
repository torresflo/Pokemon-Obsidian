module Battle
  module Actions
    # Class describing the Pre Attacks Action
    class PreAttack < Base
      # Create a new attack action
      # @param scene [Battle::Scene]
      def initialize(scene, attack_actions)
        super(scene)
        @attack_actions = attack_actions
      end

      # Compare this action with another
      # @param other [Base] other action
      # @return [Integer]
      def <=>(other)
        return 1 if other.is_a?(Attack)

        return -1
      end

      # Execute the action
      def execute
        @attack_actions.each { |action| action.move.proceed_pre_attack(action.launcher) }
      end
    end
  end
end
