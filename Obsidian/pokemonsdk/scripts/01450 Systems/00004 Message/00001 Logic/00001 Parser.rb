# frozen_string_literal: true

module PFM
  # Module responsive of holding the whole Message logic
  module Message
    # Module parsing a message to a set of instruction the message displayer can show
    module Parser
      # List of code replacer for easier parsing
      @code_replacer = []

      # Function that parses the message text so it's easier to work with it
      # @param text [String] original message text
      # @return [Message::Properties] the initial message properties
      def convert_text_to_properties(text)
        parsed_text = Text.parse_string_for_messages(text.dup).dup
        Parser.code_replacer.each { |replacer| replacer&.call(parsed_text) }
        return Properties.new(parsed_text)
      end

      # Function that generate the instructions based on properties & text surface
      # @param properties [Properties] Message box properties
      # @param width [Integer] width of the surface used to draw the message
      # @param width_computer [WidthComputer] object helping to compute the width of the words
      def make_instructions(properties, width, width_computer)
        instructions = Instructions.new(properties, width, width_computer)
        instructions.parse
        return instructions
      end

      class << self
        # Get the list of code replacer
        # @return [Array<Proc>]
        attr_reader :code_replacer

        # Register a text marker to make text easier to parse
        # @param regexp [Regexp] regexp to parse
        # @param code [Integer] code to use for easier parsing (must be positive integer)
        # @yieldparam captures [Array<String>] list of all captures from the regexp
        # @yieldreturn [Array] array of element not containing "[" or "]"
        # @note If no block is given, the function will assume the regexp has 1 match
        def register_marker(regexp, code)
          if block_given?
            @code_replacer[code] = proc do |text|
              text.gsub!(regexp) do
                parameters = yield(Regexp.last_match.captures)
                parameters = [parameters] unless parameters.is_a?(Array)
                next "#{code.chr}[#{parameters.join(',')}]"
              end
            end
          else
            @code_replacer[code] = proc { |text| text.gsub!(regexp, "#{code.chr}[\\1]") }
          end
        end
      end

      # Color
      register_marker(/\\c\[([0-9]+)\]/i, 1)
      # Wait
      register_marker(/\[WAIT ([0-9]+)\]/i, 2)
      # Style
      register_marker(/\\s\[([bir]+)\]/i, 3) do |(style)|
        next 0 if style.include?('r')
        next 1 if style == 'b'
        next 2 if style == 'i'

        next 3
      end
      # Make text bigger
      register_marker(/\\\^/, 4) { 0 }
      # Change message speed
      register_marker(/\\spd\[([0-9]+)\]/, 5)
      # Show a picture in the message
      register_marker(/\\img\[([^\]]+)\]/, 15)
    end
  end
end
