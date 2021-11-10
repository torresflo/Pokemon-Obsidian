module LiteRGSS
  class Text
    # Utility module to manage text easly in user interfaces.
    # @deprecated DO NOT FUCKING USE THIS. Use SpriteStack instead.
    module Util
      # Default outlinesize, nil gives a 0 and keep shadow processing, 0 or more disable shadow processing
      DEFAULT_OUTLINE_SIZE = nil
      # Offset induced by the Font
      FOY = 2#4
      # Returns the text viewport
      # @return [Viewport]
      def text_viewport
        return @text_viewport
      end
      # Change the text viewport
      def text_viewport=(v)
        @text_viewport = v if v.is_a?(Viewport)
      end
      # Initialize the texts
      # @param font_id [Integer] the default font id of the texts
      # @param viewport [Viewport, nil] the viewport
      def init_text(font_id = 0, viewport = nil, z = 1000)
        log_error('init_text is deprecated')
        @texts = [] unless @texts.class == Array
        @text_viewport = viewport
        @font_id = font_id
        @text_z = z
      end
      # Add a text inside the window, the offset x/y will be adjusted
      # @param x [Integer] the x coordinate of the text surface
      # @param y [Integer] the y coordinate of the text surface
      # @param width [Integer] the width of the text surface
      # @param height [Integer] the height of the text surface
      # @param str [String] the text shown by this object
      # @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
      # @param outlinesize [Integer, nil] the size of the text outline
      # @param type [Class] the type of text
      # @return [Text] the text object
      def add_text(x, y, width, height, str, align = 0, outlinesize = DEFAULT_OUTLINE_SIZE, type: Text)
        log_error('add_text from Text::Util is deprecated')
        if @window and @window.viewport == @text_viewport
          x += (@ox + @window.x)
          y += (@oy + @window.y)
        end
        # voir pout y - FOY
        text = type.new(@font_id, @text_viewport, x, y - FOY, width, height, str.to_s, align, outlinesize)
        text.z = @window ? @window.z + 1 : @text_z
        text.draw_shadow = outlinesize.nil?
        @texts << text
        return text
      end
      # Dispose the texts
      def text_dispose
        log_error('text_dispose is deprecated')
        @texts.each { |text| text.dispose unless text.disposed? }
        @texts.clear
      end
      # Yield a block on each undisposed text
      def text_each
        log_error('text_each is deprecated')
        return unless block_given?
        @texts.each { |text| yield(text) unless text.disposed? }
      end
    end
  end
end
