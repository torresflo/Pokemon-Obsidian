module BattleUI
  # Class that allow a choice do be made
  #
  # The object tells the player validated on #validated? and the result is stored inside #result
  #
  # The object should be updated through #update otherwise no validation is possible
  #
  # When result was taken, the scene should call #reset to undo the validated state
  #
  # The goal of this class is to provide the cursor handling. You have to define the buttons!
  # Here's the list of methods you should define
  #   - create_buttons
  #   - create_sub_choice (add the subchoice as a stack item! & store it in @sub_choice)
  #   - validate (set the result to the proper value)
  #   - update_key_index
  #
  # To allow flexibility (sub actions) this generic choice allow you to define a "sub generic" choice
  # that only needs to responds to #update, #reset and #done? in @sub_choice
  class GenericChoice < UI::SpriteStack
    include UI
    include HideShow
    include GoingInOut
    # Offset X of the cursor compared to the element it shows
    CURSOR_OFFSET_X = -10
    # Offset Y of the cursor compared to the element it shows
    CURSOR_OFFSET_Y = 6
    # Get the animation handler
    # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    attr_reader :animation_handler
    # Get the scene
    # @return [Battle::Scene]
    attr_reader :scene

    # Create a new GenericChoice
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    def initialize(viewport, scene)
      super(viewport, viewport.rect.width)
      @scene = scene
      @animation_handler = Yuki::Animation::Handler.new
      @index = 0
      create_sprites
      @__in_out = :out
    end

    # Update the Window cursor
    def update
      @animation_handler.update
      return unless in?

      super
      return unless done?
      return if validated?
      return validate if validating?
      return cancel if canceling?

      last_index = @index
      update_key_index
      update_mouse_index
      update_cursor if last_index != @index
    end

    # Tell if all animations are done
    # @return [Boolean]
    def done?
      return false if @sub_choice && !@sub_choice.done?

      return @animation_handler.done?
    end

    # Reset the choice
    def reset
      @result = nil
      @sub_choice&.reset
      update_cursor(true)
    end

    private

    def create_sprites
      create_buttons
      create_sub_choice
      create_cursor
    end

    def create_sub_choice
      return nil
    end

    def create_cursor
      # @type [Cursor]
      @cursor = add_sprite(0, 0, 'battle/arrow', type: Cursor)
    end

    # Get the buttons
    # @return [Array<Sprite>]
    def buttons
      return @buttons
    end

    # Update the cursor position
    # @param silent [Boolean] if the update shouldn't make noise
    def update_cursor(silent = false)
      if silent
        @cursor.set_position(buttons[@index].x + cursor_offset_x, buttons[@index].y + cursor_offset_y)
        @cursor.register_positions
        update_button_opacity
      else
        root = (ya = Yuki::Animation).send_command_to(@cursor, :stop_animation)
        root.play_before(ya.move(0.1, @cursor, @cursor.x, @cursor.y, buttons[@index].x + cursor_offset_x, buttons[@index].y + cursor_offset_y))
        root.play_before(ya.send_command_to(@cursor, :register_positions))
        root.play_before(ya.send_command_to(@cursor, :start_animation))
        root.play_before(ya.send_command_to(self, :update_button_opacity))
        root.start
        animation_handler[:cursor] = root
        $game_system.se_play($data_system.cursor_se)
      end
      self.data = @data
    end

    # Set the button opacity
    def update_button_opacity
      buttons.each_with_index { |button, index| button.opacity = index == @index ? 255 : 179 }
    end

    # Get the cursor offset x
    # @return [Integer]
    def cursor_offset_x
      return CURSOR_OFFSET_X
    end

    # Get the cursor offset y
    # @return [Integer]
    def cursor_offset_y
      return CURSOR_OFFSET_Y
    end

    # Tell if the player is validating his choice
    def validating?
      return Input.trigger?(:A) || (Mouse.trigger?(:LEFT) && @buttons.any?(&:simple_mouse_in?))
    end

    # Tell if the player is canceling his choice
    def canceling?
      return Input.trigger?(:B) || Mouse.trigger?(:RIGHT)
    end

    # Update the mouse index if the mouse moved
    def update_mouse_index
      return unless Mouse.moved

      @buttons.each_with_index do |sp, index|
        break @index = index if sp.simple_mouse_in? && sp.visible
      end
    end

    # Creates the go_in animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_in_animation
      ya = Yuki::Animation
      root = ya.move_discreet(0.1, self, @viewport.rect.width, y, 0, y)
      root.play_before(ya.send_command_to(@cursor, :register_positions))
      root.play_before(ya.send_command_to(@cursor, :start_animation))
      return root
    end

    # Creates the go_out animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_out_animation
      ya = Yuki::Animation
      root = ya.send_command_to(@cursor, :stop_animation)
      root.play_before(ya.move_discreet(0.1, self, 0, y, @viewport.rect.width, y))
      return root
    end

    # Make the button bounce
    def bounce_button
      button = buttons[@index]
      ya = Yuki::Animation
      ttl = 0.05
      root = ya.move_discreet(ttl, button, button.x, button.y, button.x, button.y - 3)
      root.play_before(ya.move_discreet(ttl, button, button.x, button.y - 3, button.x, button.y))
      root.start
      animation_handler[:button_bounce] = root
    end
  end
end
