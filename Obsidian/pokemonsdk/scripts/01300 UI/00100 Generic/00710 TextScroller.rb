module UI
  class TextScroller < SpriteStack
    # Separator for double column
    DOUBLE_COLUMN_SEP = ' || '
    # Create a new text scroller
    # @param viewport [Viewport]
    # @param texts [Array<String>]
    # @param line_height [Integer] height of a line of text
    # @param speed [Float] number of pixels / seconds
    def initialize(viewport, texts, line_height, speed)
      super(viewport, 0, 0)
      @texts = texts
      @line_height = line_height
      @speed = speed
      @next_check = 0
      @index = 0
      @h1_pool = []
      @h2_pool = []
      @h3_pool = []
      @p_pool = []
    end

    # Start the text scroll
    # @param until_all_text_hidden [Boolean] if the animation should last until the last text is offscreen
    def start(until_all_text_hidden: true)
      size = @texts.size * @line_height
      size += @viewport.rect.height if until_all_text_hidden
      preload_texts
      @animation = Yuki::Animation.move_discreet(size / @speed, self, 0, 0, 0, -size)
      @animation.start
    end

    # Update the scrolling
    def update
      spawn_next_text if y <= @next_check
      @animation.update
    end

    # Tell if the scrolling is done
    # @return [Boolean]
    def done?
      return true unless @animation

      return @animation.done?
    end

    private

    # Function responsive of spawning the next text to the screen
    def spawn_next_text
      stack.each { |text| text.visible = text.y > -@line_height }
      load_text(@texts[@index]) if @index < @texts.size
      @next_check -= @line_height
      @index += 1
    end

    # Function responsive of loading the text to the screen
    # @param text [String] markdown styled text (h1, h2, h3 or p)
    def load_text(text)
      *h, real_text = (text.start_with?('#') ? text.split(' ', 2) : text)
      if h.empty?
        return load_text_by_kind(@p_pool, :p, real_text.strip) unless real_text.include?(DOUBLE_COLUMN_SEP)

        return load_double_text(@p_pool, real_text.strip.split(DOUBLE_COLUMN_SEP))
      end

      h_type = h.first.count('#').clamp(1, 3)
      case h_type
      when 1
        load_text_by_kind(@h1_pool, :h1, real_text.strip)
      when 2
        load_text_by_kind(@h2_pool, :h2, real_text.strip)
      when 3
        load_text_by_kind(@h3_pool, :h3, real_text.strip)
      end
    end

    # Function that load a text depending on its kind
    # @param pool [Array<Text>]
    # @param kind [Symbol]
    # @param text [String]
    # @return [Text]
    def load_text_by_kind(pool, kind, text)
      recycled_text = pool.find { |txt| txt.visible == false }
      if recycled_text
        recycled_text.text = text
        recycled_text.visible = true
        recycled_text.align = text_align
      else
        @font_id = font_id(kind)
        pool << (recycled_text = add_text(0, 0, *text_surface, text, text_align, outline_size(kind), color: color_id(kind)))
      end
      recycled_text.set_position(*next_text_coordinate)
      return recycled_text
    end

    # Function that load text on double column
    # @param pool [Array<Text>]
    # @param texts [Array<String>]
    def load_double_text(pool, texts)
      recycled_text = load_text_by_kind(pool, :p, texts.first)
      recycled_text.x -= 10
      recycled_text.align = 2
      recycled_text = load_text_by_kind(pool, :p, texts.last)
      recycled_text.x += 10
      recycled_text.align = 0
    end

    # Function that give the text coordinate for the next text to show
    # @return [Array<Integer>]
    def next_text_coordinate
      return viewport.rect.width / 2, viewport.rect.height
    end

    # Function that give the text surface & align
    # @return [Array<Integer>]
    def text_surface
      return 0, @line_height
    end

    # Function that give the text align
    # @return [Integer]
    def text_align
      return 1
    end

    # Function that gives the font for a text
    # @param kind [Symbol]
    # @return [Integer]
    def font_id(kind)
      case kind
      when :h1, :h2, :h3
        return 20
      else
        return 0
      end
    end

    # Function that gives the color for a text
    # @param kind [Symbol]
    # @return [Integer]
    def color_id(kind)
      case kind
      when :h1
        return 11
      when :h2
        return 12
      when :h3
        return 13
      else
        return 10
      end
    end

    # Function that gives the outline_size for a text
    # @param kind [Symbol]
    # @return [Integer]
    def outline_size(kind)
      case kind
      when :h1, :h2, :h3
        return 1
      else
        return nil
      end
    end

    # Function that preload some text in order to make the starting a bit smoother
    def preload_texts
      nb_text = @viewport.rect.height / @line_height * 2
      nb_text.times { load_text(' ') }
      5.times do
        load_text('#  ')
        load_text('##  ')
        load_text('###  ')
      end
      stack.each { |text| text.visible = false }
    end
  end
end
