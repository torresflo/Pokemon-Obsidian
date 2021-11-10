# Ruby's Kernel module
module Kernel
  # Debug print command, prints each args using puts
  # @param args [Array<Object>]
  def pc(*args)
    return
  end

  # Change the color of the text in the terminal
  # @param code [Integer] code & 0xF0 define the background, code & 0x0F define the text color
  # @example setting the background in purple and the text in white
  #   cc 0x57
  def cc(code)
    return
  end

  # Display the arguments with color in the last slot
  # @param *args [Object, Integer] object to display, last integer is the color
  # @example Display a message in red
  #   pcc 'Message', 0x01
  # @author Leikt
  def pcc(*args)
    return
  end

  # Display an error
  # @param message [String]
  # @return [String] the message
  def log_error(message)
    return message
  end

  # Display an information
  # @param message [String]
  # @return [String] the message
  def log_info(message)
    return message
  end

  # Display a debug message
  # @param message [String]
  # @return [String] the message
  def log_debug(message)
    return message
  end

  # Display a debug message
  # @param message [String]
  # @return [String] the message
  def log_data(message)
    return message
  end

  # Display the colors and their codes
  def colors
    return
  end
end
