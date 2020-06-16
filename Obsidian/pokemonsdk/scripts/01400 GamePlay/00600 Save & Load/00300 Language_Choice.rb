module GamePlay
  # Scene responsive of displaying the language choice when creating a new game
  class Language_Choice < BaseCleanUpdate
    # If the change of index is animated
    ANIME_CHANGE = true
    # Number of frame for index change
    ANIME_FRAMES = 6

    # Initialize the scene
    def initialize
      super()
      @running = true
      @lang_list = PSDK_CONFIG.choosable_language_code
      @index = @lang_list.find_index(PSDK_CONFIG.default_language_code)
      @counter = 0
    end

    # Create the graphics
    def create_graphics
      create_viewport
      @stack = UI::SpriteStack.new(@viewport)
      @frame = @stack.add_sprite(0, 0, 'language/frame')

      @flag_left = @stack.add_sprite(-76, 85, nil)
      @flag_left.zoom = 0.9
      @flag_left.opacity = 192

      @flag_center = @stack.add_sprite(91, 81, nil)
      @flag_center.opacity = 255

      @flag_right = @stack.add_sprite(258, 85, nil)
      @flag_right.opacity = 192

      # @type [SpriteSheet]
      @cursor = @stack.add_sprite(91 - 4, 81 - 4, 'language/cursors', 1, 2, type: SpriteSheet)

      @base_ui = UI::GenericBase.new(@viewport, hide_background_and_button: true)

      update_index
    end

    # Update the graphics
    def update_graphics
      @base_ui.update_background_animation
      @counter += 1
      if @counter >= 60
        @counter = 0
      elsif @counter >= 30
        @cursor.sy = 0
      else
        @cursor.sy = 1
      end
    end

    # Update the inputs
    def update_inputs
      if Input.repeat?(:LEFT)
        @index = @index != 0 ? @index - 1 : @lang_list.size - 1
        move(false) if ANIME_CHANGE
        update_index
      elsif Input.repeat?(:RIGHT)
        @index = @index != @lang_list.size - 1 ? @index + 1 : 0
        move(true) if ANIME_CHANGE
        update_index
      end

      if Input.trigger?(:A)
        @running = false
        $pokemon_party = PFM::Pokemon_Party.new(false, @lang_list[@index])
      end
    end

    private

    # Update the index
    def update_index
      left_index = @index != 0 ? @index - 1 : @lang_list.size - 1
      right_index = @index != @lang_list.size - 1 ? @index + 1 : 0
      @flag_left.set_bitmap("language/flags/flag_#{@lang_list[left_index]}", :interface)
      @flag_center.set_bitmap("language/flags/flag_#{@lang_list[@index]}", :interface)
      @flag_right.set_bitmap("language/flags/flag_#{@lang_list[right_index]}", :interface)
    end

    # Move animation
    # TODO: Use real animation istead of code!
    # @param left [Boolean] if we're moving left
    def move(left)
      @cursor.visible = false
      @flag_center.zoom = 0.9
      @flag_center.x = 85
      @flag_center.opacity = 192
      left ? move_left_animation : move_right_animation
      @flag_left.x = -76
      @flag_center.x = 91
      @flag_center.opacity = 255
      @flag_center.y = 81
      @flag_center.zoom = 1.0
      @flag_right.x = 258
      update_index
      @cursor.visible = true
      @stack.stack.pop.dispose
    end

    # Animation when moving left
    def move_left_animation
      filename = "language/flags/flag_#{@lang_list[(@index - 2) % @lang_list.size]}"
      tmp = @stack.add_sprite(@flag_right.x + @flag_right. width + 37, 85, filename)
      tmp.opacity = 192
      tmp.zoom = 0.9
      ANIME_FRAMES.times do
        @flag_center.x -= 167 / ANIME_FRAMES
        @flag_left.x -= 167 / ANIME_FRAMES
        @flag_right.x -= 167 / ANIME_FRAMES
        tmp.x -= 167 / ANIME_FRAMES
        update_graphics
        Graphics.update
      end
    end

    # Animation when moving right
    def move_right_animation
      filename = "language/flags/flag_#{@lang_list[(@index + 2) % @lang_list.size]}"
      tmp = @stack.add_sprite(@flag_left.x - @flag_left. width - 37, 85, filename)
      tmp.opacity = 192
      tmp.zoom = 0.9
      ANIME_FRAMES.times do
        @flag_center.x += 167 / ANIME_FRAMES
        @flag_left.x += 167 / ANIME_FRAMES
        @flag_right.x += 167 / ANIME_FRAMES
        tmp.x += 167 / ANIME_FRAMES
        update_graphics
        Graphics.update
      end
    end
  end
end
