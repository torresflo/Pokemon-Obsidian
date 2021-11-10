# Ruby's Kernel module
module Kernel
  # Debug print command, prints each args using puts
  # @param args [Array<Object>]
  def pc(*args)
    args.each { |arg| puts arg.to_s }
  end

  # Change the color of the text in the terminal
  # @param code [Integer] code & 0xF0 define the background, code & 0x0F define the text color
  # @example setting the background in purple and the text in white
  #   cc 0x57
  def cc(code)
    bg = (code & 0xF0) >> 4
    fg = code & 0x0F
    # Change the background
    print bg < 8 ? "\e[4#{bg & 0x7}m" : "\e[10#{bg & 0x7}m"
    # Change the text color
    print fg < 8 ? "\e[3#{fg & 0x7}m" : "\e[9#{fg & 0x7}m"
  end

  # Display the arguments with color in the last slot
  # @param *args [Object, Integer] object to display, last integer is the color
  # @example Display a message in red
  #   pcc 'Message', 0x01
  # @author Leikt
  def pcc(*args)
    print "\r"
    Kernel.send(:cc, args.pop) if args.last.is_a?(Integer)
    Kernel.send(:pc, *args)
    Kernel.send(:cc, 0x07)
  end

  # Display an error
  # @param message [String]
  # @return [String] the message
  def log_error(message)
    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    pcc("[#{rc}] #{message}", 0x01)
    return message
  end

  # Display an information
  # @param message [String]
  # @return [String] the message
  def log_info(message)
    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    pcc("[#{rc}] #{message}", 0x02)
    return message
  end

  # Display a debug message
  # @param message [String]
  # @return [String] the message
  def log_debug(message)
    return nil.to_s unless debug?

    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    pcc "[#{rc}] #{message}", 0x06
    return message
  end

  # Display a data message in debug
  # @param message [String]
  # @return [String] the message
  def log_data(message)
    return nil.to_s unless debug?

    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    pcc "[#{rc}] #{message}", 0x03
    return message
  end

  # Display the colors and their codes
  def colors
    0.upto(100) do |code|
      pcc "Text with code #{code}", code
    end
  end

  # Shortcuts for console commands
  # @example Calling a method of the map interpreter from the console
  #   S.MI.add_pokemon(:pikachu)
  module ConsoleShortcuts
    module_function

    # Shortcut to get the Map Interpreter
    # @return [Interpreter_RMXP]
    def MI
      log_error('Please do not use this function in Events/Scripts')
      return $game_system.map_interpreter
    end

    # Shortcuts to game player
    # @return [Game_Player]
    def PL
      log_error('Please do not use this function in Events/Scripts')
      return $game_player
    end
  end
  # Shortcut to the shortcut module
  S = ConsoleShortcuts
end
