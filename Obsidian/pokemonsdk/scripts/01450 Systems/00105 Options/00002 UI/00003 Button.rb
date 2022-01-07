module UI
  module Options
    class Button < SpriteStack
      OPTION_OFFSET_Y = 40
      OPTION_BASE_X = 19
      OPTION_OFFSET_X = 4
      # Option modified by the button
      # @return [GamePlay::Options::Helper]
      attr_reader :option
      # Current value shown by the button
      # @return [Option]
      attr_reader :value
      # Create a new Option Button
      # @param viewport [Viewport]
      # @param index [Integer] index of the option in the order
      # @param option [GamePlay::Options::Helper]
      def initialize(viewport, index, option)
        super(viewport, OPTION_BASE_X, OPTION_OFFSET_Y * index)
        @option = option
        @value = option.current_value
        @option_background = add_background('options/option')
        @option_name = add_text(8, 3, 0, 16, @option.name, color: 10)
        @option_value = add_text(14, 19, 96, 16, value_text, 1)
      end

      # Return the value index
      # @return [Integer]
      def value_index
        return @value if @option.type == :slider
        @option.values.index(@value) || 0
      end

      # Set the current value shown by the button
      # @param new_value [Object]
      def value=(new_value)
        @value = new_value
        @option_value.text = value_text
      end

      # Retreive the option value text
      # @return [String]
      def value_text
        return format(@option.values_text, @value) if @option.type == :slider
        @option.values_text[value_index]
      end
    end
  end
end
