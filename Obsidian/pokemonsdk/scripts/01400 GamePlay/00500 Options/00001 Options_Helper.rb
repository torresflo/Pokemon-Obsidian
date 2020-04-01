module GamePlay
  class Options < BaseCleanUpdate
    # List of valid option type
    VALID_OPTION_TYPE = %i[choice slider]

    private

    # Add an option to the option stack
    # @param name [Symbol] name used in order to "sort" the options
    # @param type [Symbol] type of option (:choice, :slider)
    # @param options_info [Array, Hash, String] info telling the option system what value to take
    # @param options_text [Array, String] texts or getter used to show the values
    # @param option_name [Array, String] GamePlay::Base#get_text argument for the option name
    # @param option_descr [Array, String] GamePlay::Base#get_text argument for the option description
    # @param attribute [Symbol] attribute used inside $options
    # @note If the parameter name is not inside PSDK_CONFIG#options#order this option will not be shown
    def add_option(name, type, options_info, options_text, option_name, option_descr, attribute)
      raise 'Invalid option type' unless VALID_OPTION_TYPE.include?(type)
      options_info = parse_string(options_info) if options_info.is_a?(String)
      options_text = parse_string(options_text) if options_text.is_a?(String)
      options_text.map! { |option_text| get_text(option_text) } unless options_text.is_a?(String)
      option_name = get_text(option_name)
      option_descr = get_text(option_descr)
      getter = attribute
      setter = "#{getter}="
      return if options_info.is_a?(Array) && options_info.size <= 1
      @options[name] = Helper.new(type, options_info, options_text, option_name, option_descr, getter, setter)
    end

    # Parser allowing to retrieve the right value
    # @param str [String]
    def parse_string(str)
      return str if str.include?('%')
      constants, *attributes = str.split('#')
      value = Object.const_get(constants)
      while (attribute = attributes.shift)
        value = value.send(attribute) unless attribute.empty?
      end
      return value
    end

    class Helper
      # Option type
      # @return [Symbol]
      attr_reader :type
      # Option values
      # @return [Array]
      attr_reader :values
      # Option value text(s)
      # @return [Array<String>, String]
      attr_reader :values_text
      # Option name
      # @return [String]
      attr_reader :name
      # Option description
      # @return [String]
      attr_reader :description
      # Option getter (on $options)
      # @return [Symbol]
      attr_reader :getter
      # Option setter (on $options)
      # @return [Symbol]
      attr_reader :setter
      # Create a new option
      # @param args [Array] options arguments
      def initialize(*args)
        @type = args[0]
        @values = args[1]
        @values_text = args[2]
        @name = args[3]
        @description = args[4]
        @getter = args[5]
        @setter = args[6]
      end

      # Retreive the current value
      # @return [Object]
      def current_value
        value = $options.send(getter)
        if @type == :slider
          value = value.clamp(@values[:min], @values[:max])
          return value - (value % @values[:increment])
        end
        value_index = @values.index(value)
        return @values[value_index || 0]
      end

      # Retreive the next value
      # @return [Object]
      def next_value
        value = $options.send(getter)
        return (value + @values[:increment]).clamp(@values[:min], @values[:max]) if @type == :slider
        value_index = @values.index(value)
        new_value = @values[(value_index || 0) + 1]
        new_value = @values.first if new_value.nil?
        return new_value
      end

      # Retreive the prev value
      # @return [Object]
      def prev_value
        value = $options.send(getter)
        return (value - @values[:increment]).clamp(@values[:min], @values[:max]) if @type == :slider
        value_index = @values.index(value)
        return @values.last if value_index == 0
        new_value = @values[(value_index || 0) - 1]
        new_value = @values.first if new_value.nil?
        return new_value
      end

      # Update the option value
      # @param new_value [Object]
      def update_value(new_value)
        if @type != :slider
          value_index = @values.index(new_value)
          new_value = @values[value_index || 0]
        end
        $options.send(setter, new_value)
      end
    end
  end
end
