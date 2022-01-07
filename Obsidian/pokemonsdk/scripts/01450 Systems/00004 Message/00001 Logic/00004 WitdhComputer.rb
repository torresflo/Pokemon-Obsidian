# frozen_string_literal: true

module PFM
  module Message
    # Class that helps to compute the width of the words
    class WidthComputer
      # Create a new WidthComputer
      # @param text_normal [LiteRGSS::Text]
      # @param text_big [LiteRGSS::Text]
      def initialize(text_normal, text_big)
        @text_normal = text_normal
        @text_big = text_big
      end

      # Get the normal width of the text
      # @param text [String]
      # @return [Integer]
      def normal_width(text)
        @text_normal.text_width(text)
      end

      # Get the width of the text when it's big
      # @param text [String]
      # @return [Integer]
      def big_width(text)
        @text_big.text_width(text)
      end

      # Tell if any of the text is disposed
      # @return [Boolean]
      def disposed?
        return @text_big.disposed? || @text_normal.disposed?
      end
    end
  end
end
