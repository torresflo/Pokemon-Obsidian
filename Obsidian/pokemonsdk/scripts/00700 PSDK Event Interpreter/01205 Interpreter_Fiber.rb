class Interpreter
  # Show a message with eventually a choice
  # @param string [String] message to show
  # @param cancel_type [Integer] option used to cancel (1 indexed position, 0 means no cancel)
  # @param choices [Array<String>] all the possible choice
  # @note This function should only be called from text events!
  # @example Simple message
  #   message("It's a message!")
  # @example Message from CSV files
  #   message(ext_text(csv_id, index))
  # @example Message with choice
  #   choice_result = message("You are wonkru or you are the enemy of wonkru!\nChoose !", 1, 'Wonkru', '*Knifed*')
  # @return [Integer] the choosen choice (0 indexed this time)
  def message(string, cancel_type = 0, *choices)
    return rmxp_message(string, 1, *choices) unless @fiber # RMXP Compatibility
    choice_result = 0
    # Return false to the interpreter while the last message is shown
    Fiber.yield(false) while $game_temp.message_text
    $game_player.look_to(@event_id) unless $game_switches[::Yuki::Sw::MSG_Noturn]
    # Give info to allow the interpreter to work correctly
    @message_waiting = true
    $game_temp.message_proc = proc { @message_waiting = false }
    # Give the message info to the message engine
    $game_temp.message_text = string
    # Give the choice info
    if choices.any?
      $game_temp.choice_cancel_type = cancel_type
      $game_temp.choices = choices
      $game_temp.choice_max = choices.size
      $game_temp.choice_proc = proc { |n| choice_result = n }
    end
    # Give the control back to the interpreter
    Fiber.yield(true)
    # Return the result to the event
    return choice_result
  end

  # Show a yes no choice
  # @param message [String] message shown by the event
  # @param yes [String] string used as yes
  # @param no [String] string used as no
  # @example Simple yes/no choice (in a condition)
  #   yes_no_choice('Do you want to continue?')
  # @example Boy/Girl choice (in a condition, validation will mean boy)
  #   yes_no_choice('Are you a boy?[WAIT 60] \nOr are you a girl?', 'Boy', 'Girl')
  # @return [Boolean] if the yes option was choosen
  def yes_no_choice(message, yes = nil, no = nil)
    yes ||= text_get(11, 27)
    no ||= text_get(11, 28)
    return rmxp_message(message, 1, yes.dup, no.dup) == 0 unless @fiber # RMXP Compatibility
    return message(message, 2, yes.dup, no.dup) == 0
  end

  private

  # Call the RMXP message
  # @param message [String] message to display
  # @param start [Integer] choice start
  # @param choices [Array<String>] choices
  # @return [Integer]
  def rmxp_message(message, start, *choices)
    @message_waiting = true
    result = $scene.display_message(message, start, *choices)
    @message_waiting = false
    return result
  end
end
