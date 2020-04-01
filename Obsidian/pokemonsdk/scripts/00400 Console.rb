# Ruby's Kernel module
module Kernel
  # Stack containing the log lines
  @log_stack = []
  # Logger
  if STDOUT.tty? || !STDOUT.closed?
    @logger = Thread.new do
      loop do
        sleep
        Kernel.process_log_stack
      end
    end
  end

  # Return the log stack
  # @return [Array]
  def log_stack
    @log_stack
  end

  # Process the log stack
  def process_log_stack
    @log_stack.each do |element|
      send(*element)
    end
    @log_stack.clear
  end

  # Debug print command, prints each args using puts
  # @param args [Array<Object>]
  def pc(*args)
    return if PSDK_CONFIG.release?
    args.each { |arg| puts arg.to_s }
  end

  # Change the color of the text in the terminal
  # @param code [Integer] code & 0xF0 define the background, code & 0x0F define the text color
  # @example setting the background in purple and the text in white
  #   cc 0x57
  def cc(code)
    return if PSDK_CONFIG.release?
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
    return if PSDK_CONFIG.release?
    print "\r"
    cc args.pop if args.last.is_a?(Integer)
    pc(*args)
    cc 0x07
  end

  # Display an error
  # @param message [String]
  # @return [String] the message
  def log_error(message)
    return message if PSDK_CONFIG.release?
    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    Kernel.log_stack << [:pcc, "[#{rc}] #{message}", 0x01]
    return message
  end

  # Display an information
  # @param message [String]
  # @return [String] the message
  def log_info(message)
    return message if PSDK_CONFIG.release?
    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    Kernel.log_stack << [:pcc, "[#{rc}] #{message}", 0x02]
    return message
  end

  # Display a debug message
  # @param message [String]
  # @return [String] the message
  def log_debug(message)
    return message if PSDK_CONFIG.release?
    return unless debug?
    rc = binding.receiver
    rc = rc.is_a?(Module) ? rc : rc.class
    # Immediate because of the debug purpose
    Kernel.process_log_stack
    pcc "[#{rc}] #{message}", 0x06
    return message
  end

  # Display the colors and their codes
  def colors
    return if PSDK_CONFIG.release?
    0.upto(100) do |code|
      pcc "Text with code #{code}", code
    end
  end

  # Wake the logger thread up
  # @note The log stack is cleared if the logger does not exists
  def wakeup_log
    return ::Kernel.wakeup_log unless self == ::Kernel
    if @logger
      @logger.wakeup
    else
      @log_stack.clear
    end
  end

  unless PSDK_CONFIG.release?
    # Shortcuts for console commands
    # @example Calling a method of the map interpreter from the console
    #   S.MI.add_pokemon(:pikachu)
    module ConsoleShortcuts
      module_function

      # Shortcut to get the Map Interpreter
      # @return [Interpreter_RMXP]
      def MI
        return $game_system.map_interpreter
      end

      # Shortcuts to game player
      # @return [Game_Player]
      def PL
        return $game_player
      end
    end
    # Shortcut to the shortcut module
    S = ConsoleShortcuts
  end
end
