module GamePlay
  # Parent class of State machine scenes
  #
  # This class is designed to be "parent_class" of state machines scenes designed with .yml files.
  # This class will call `update_state_machine` in update (and handle the state machine), you still have
  # to call `initialize_state_machine` in either `create_graphics` or `initialize`.
  #
  # Note: If a state sets `@sm_execute_next_state` to true, the system will not wait for the next frame to execute the next state.
  #       This executes the next state only if it is different! Please also ensure you don't use this when displaying a message.s
  class StateMachine < Base
    # Update the scene process
    def update
      return unless super

      # Set last state and execute current state
      last_state = @sm_state
      update_state_machine
      # Attempt to execute next state whil it's said to do so
      while @sm_execute_next_state
        # Set execute next state flag to false in order to prevent mistakes (it has to be set by the state!)
        @sm_execute_next_state = false
        # If previous is the same as current, we don't execute the next step
        break if last_state == @sm_state

        # Sets the last state to current in order to ensure next iteration won't infinite-loop
        last_state = @sm_state
        update_state_machine
      end
    end

    private

    # Exit the state machine
    def exit_state_machine
      @running = false
    end
  end
end
