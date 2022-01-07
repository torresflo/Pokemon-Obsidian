# frozen_string_literal: true

module PFM
  module Message
    # Parse & List all the instructions to draw the message box content
    class Instructions
      # Regexp used to detect markers
      MARKER_REGEXP = /([\x01-\x0F]\[[^\]]+\])/
      # Regexp to grab the marker data
      MARKER_DATA = /\[([^\]]+)\]/
      # Regexp that split text with space but preserver space in split output
      SPACE_SPLIT_PRESERVE_REGEXP = /( )/
      # ID of image marker
      IMAGE_MARKER_ID = 15
      # ID of big text marker
      BIG_TEXT_MARKER_ID = 4

      # Create a new Instructions instance
      # @param properties [Properties] Message box properties
      # @param width [Integer] width of the surface used to draw the message
      # @param width_computer [WidthComputer] object helping to compute the width of the words
      def initialize(properties, width, width_computer)
        @properties = properties
        @width = width
        @width_computer = width_computer
        @is_big = false
        @lines = []
      end

      # Parse the message
      def parse
        @total_width = 0
        @current_line = []
        split_text_and_markers.each do |data|
          next parse_marker(data) if marker?(data)

          next parse_text(data)
        end
        push_line # Ensure the current line gets pushed if message does not terminate with \n
        @lines.pop while @lines.any? && (@lines.last.empty? || @lines.last.first == NewLine) # Remove all non-necessary lines
        @lines.last.pop if @lines.any? && @lines.last.any? && @lines.last.last == NewLine # Remove the last new line (unecessary)
      end

      # Start instruction procesing
      def start_processing
        @line = 0
        @index = 0
      end

      # Tell if processing is done
      # @return [Boolean]
      def done_processing?
        return true unless @line && @index

        return @lines[@line].nil?
      end

      # Get current instruction and prepare next instruction
      # @return [Text, Marker, NewLine, nil]
      def get
        return nil if done_processing?

        instruction = @lines[@line][@index]
        @index += 1
        if @lines[@line].size <= @index
          @index = 0
          @line += 1
        end

        return instruction
      end

      # Get the width of the current line
      # @return [Integer]
      def current_line_width
        return 0 if done_processing?

        return @lines[@line].sum(&:width)
      end

      private

      # Split the text in a way markers can be converted to marker instruction easilly
      # @return [Array<String>]
      def split_text_and_markers
        return @properties.parsed_text.split(MARKER_REGEXP).reject(&:empty?)
      end

      # Detect if the string is a marker
      # @param string [String]
      # @return [Boolean]
      def marker?(string)
        string.match?(MARKER_REGEXP)
      end

      # Get the width of the text
      # @param text [String]
      # @return [Integer]
      def width_of(text)
        @is_big ? @width_computer.big_width(text) : @width_computer.normal_width(text)
      end

      # Function that parse a marker
      # @param marker [String]
      def parse_marker(marker)
        marker_id = marker.getbyte(0)
        return parse_image_marker(marker) if marker_id == IMAGE_MARKER_ID

        @is_big = true if marker_id == BIG_TEXT_MARKER_ID
        @current_line << Marker.new(marker_id, marker.match(MARKER_DATA).captures.first)
      end

      # Function that parse a image marker
      # @param marker [String]
      def parse_image_marker(marker)
        marker_id = marker.getbyte(0)
        data = marker.match(MARKER_DATA).captures.first
        image_name, cache, * = data.split(',')
        cache ||= :picture

        image = RPG::Cache.send(cache, image_name)
        will_overflow?(image.width) ? push_line(image.width) : @total_width += image.width
        @current_line << Marker.new(marker_id, data, image.width)
      end

      # Function that parses text
      # @param text [String]
      def parse_text(text)
        text.include?("\n") ? parse_text_with_new_line(text) : parse_text_without_new_line(text)
      end

      # Function that parses text containing new lines.
      # Will not push new line if a new line was created by the last word or will be created by next word.
      # @param text [String]
      def parse_text_with_new_line(text)
        text.split(/(\n)/).each do |sub_text|
          if sub_text == "\n"
            push_line unless @total_width == 0 || @total_width == @width
          else
            parse_text_without_new_line(sub_text)
          end
        end
      end

      # Function that parses text not containing new lines
      # @param text [String]
      def parse_text_without_new_line(text)
        text_width = width_of(text)
        return parse_text_that_break_in_several_lines(text) if will_overflow?(text_width)

        @total_width += text_width
        @current_line << Text.new(text, text_width)
      end

      # Function that parse a text that will break in several line because it's long
      # @param text [String]
      def parse_text_that_break_in_several_lines(text)
        sub_texts = text.split(SPACE_SPLIT_PRESERVE_REGEXP).reverse
        buffer = ''.dup
        while (sub_text = sub_texts.pop)
          sub_text_width = width_of(sub_text)
          if will_overflow?(sub_text_width)
            @current_line << Text.new(buffer.dup, width_of(buffer)) unless buffer.empty?
            buffer.clear
            push_line
            next if sub_text == ' ' # Don't push space when at end of line
          end
          @total_width += sub_text_width
          buffer << sub_text
        end
        # Push the last bit of the buffer remaining after the multi line operation
        @current_line << Text.new(buffer, width_of(buffer)) unless buffer.empty?
      end

      # Test if the current element width will overflow
      # @param width [Integer]
      # @return [Boolean]
      def will_overflow?(width)
        @total_width + width > @width
      end

      # Function that pushes a new line
      # @param new_line_total_width [Integer] current width of the new line
      def push_line(new_line_total_width = 0)
        @total_width = new_line_total_width
        @lines << @current_line
        @current_line << NewLine unless @current_line.last == NewLine
        @current_line = []
      end

      # Class that describes a Marker
      class Marker
        # Get the marker ID
        # @return [Integer]
        attr_reader :id
        # Get the marker data
        # @return [String]
        attr_reader :data
        # Get the width of the marker
        # @return [Integer]
        attr_reader :width

        # Create a new Marker
        # @param id [Integer] ID of the marker
        # @param data [String] data of the marker
        # @param width [Integer] width of the marker
        def initialize(id, data, width = 0)
          @id = id
          @data = data
          @width = width
        end
      end

      # Class that describe a text object
      class Text
        # Get the text to show
        # @return [String]
        attr_reader :text
        # Get the width of the text
        # @return [Integer]
        attr_reader :width

        # Create a new text object
        # @param text [String] text to show
        # @param width [Integer] width of the text to show
        def initialize(text, width)
          @text = text
          @width = width
        end
      end

      # Module that describe a new line
      module NewLine
        module_function

        # Get the width of the new line
        # @return [Integer]
        def width
          return 0
        end
      end
    end
  end
end
