# Module that holds parse and holds all the arguments
module PARGV
  @arguments = {}
  
  @data = {}
  
  module_function
  
  # Return a parsed argument
  # @param key [Symbol] the argument name
  # @return [Object]
  def [](key)
    return @arguments[key]
  end
  
  # Add an argument to parse
  # @param key [Symbol] the argument name
  # @param description [String] description of the argument
  # @param convert_func [Symbol] the convert func to call on the received object
  # @param expected_values [Array, Range] the expected values after conversion
  # @param multiple [Boolean] if the argument accept multiple instances
  # @param flag [Boolean] indicate it's a flag (prensence => true)
  # @param default [Object] default value
  def add(key, description, convert_func: nil, expected_values: nil, multiple: false, default: nil, flag: false)
    @data[key] = {
      description: description,
      convert_func: convert_func,
      expected_values: expected_values,
      multiple: multiple,
      default: default,
      flag: flag
    }
  end
  
  # Parse the arguments
  def parse
    show_help if ARGV.grep(/^(-h|--help)$/).size > 0
    expecting_val = false
    key = nil
    ARGV.each do |arg|
      if arg.start_with?('--')
        key = arg.match(/--([^=]+)/)[1].to_s.to_sym
        next unless @data.has_key?(key)
        if arg.include?('=')
          parse_arg(key, arg.split('=')[1..-1].join('='))
          expecting_val = false
        else
          if @data[key][:flag]
            parse_arg(key, true)
            expecting_val = false
          else
            expecting_val = true
          end
        end
      elsif expecting_val
        parse_arg(key, arg)
        expecting_val = false
      end
    end
    @data.each { |key, data| @arguments[key] = data[:default] if @arguments[key].nil? }
  end
  
  # Parse an argument
  # @param key [Symbol] the argument key
  # @param value [String] the argument value
  def parse_arg(key, value)
    data = @data[key]
    if data
      value = value.send(data[:convert_func]) if data[:convert_func]
      if data[:expected_values]
        unless data[:expected_values].include?(value)
          puts format('Argument %<arg>s outside the expected values (%<values>s)', arg: key, values: data[:expected_values])
          show_help
        end
      end
      if data[:multiple]
        @arguments[key] ||= []
        @arguments[key] << value
      else
        @arguments[key] = value
      end
    end
  end
  
  # show the help
  def show_help
    print "\e[37m\e[40m"
    puts " PSDK Help ".center(80, "=")
    puts "List of arguments".ljust(80)
    @data.each do |key, data|
      default = (data[:default].nil? || data[:flag]) ? '' : format('(default: %<default>s)', default: data[:default])
      if data[:expected_values]
        puts format("  \e[36m--%<arg>s\e[37m %<description>s %<default>s values in %<expected>s", 
          arg: key, description: data[:description], default: default, expected: data[:expected_values]).ljust(80 + 10)
      else
        puts format("  \e[36m--%<arg>s\e[37m %<description>s %<default>s", 
          arg: key, description: data[:description], default: default).ljust(80 + 10)
      end
    end
    exit!
  end
  
  # Add all the arguments
  add(:scale, "value : Change the screen scale", convert_func: :to_f, expected_values: 0.1..4, multiple: false, default: 2)
  add(:smooth, "     : Smooth textures", default: false, flag: true)
  add(:fullscreen, " : Show the game in fullscreen", default: false, flag: true)
  add(:"no-vsync", "   : Use sleep instead of VSYNC", default: false, flag: true)
  add(:"show-fps", "   : Show the ingame FPS counter", default: false, flag: true)
  add(:tags, "       : Start the SystemTag editor", default: false, flag: true)
  add(:worldmap, "   : Start the World Map editor", default: false, flag: true)
  add(:"animation-editor", ": Start the Animation editor", default: false, flag: true)
  add(:test, "scriptname : Test a script located in the tests folder", multiple: false)
  add(:util, "scriptname : Load a util script from the plugins folder", multiple: true)
  
  # Parse the arguments
  parse
end