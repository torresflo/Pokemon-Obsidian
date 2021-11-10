module Battle
  # Module responsive of mocking the battle scene so nothing happen on the reality
  #
  # How to use:
  #   scene = @scene.clone
  #   scene.extend(SceneMock)
  #
  # Note: super inside this script might call the original function
  module SceneMock
    class << self
      # Method called when a scene gets mocked (through extend)
      # @param mod [Battle::Scene]
      def extended(mod)
        mod.instance_variable_set(:@battle_info, Marshal.load(Marshal.dump(mod.battle_info)))
        mod.instance_variable_set(:@viewport, nil)
        mod.instance_variable_set(:@visual, mod.visual.clone)
        mod.visual.instance_variable_set(:@scene, mod)
        mod.visual.extend(VisualMock)
        mod.instance_variable_set(:@logic, mod.logic.clone)
        mod.logic.instance_variable_set(:@scene, mod)
        mod.logic.extend(LogicMock)
      end
    end

    # Get the mock actions
    # @return [Array<Hash>]
    attr_reader :mock_actions

    # Function that pushes an action to the action array (thing that happens during execution)
    # @param data [Hash]
    def mock_push_action(data)
      @mock_actions ||= []
      @mock_actions << data
    end

    # Function that clears the mock actions
    def mock_clear_actions
      @mock_actions = []
    end

    def message_window
      log_error("message_window called by #{caller[0]}")
      return nil
    end

    def display_message_and_wait(*)
      return 0
    end

    def display_message(*)
      return 0
    end

    def update
      return nil
    end
  end
end
