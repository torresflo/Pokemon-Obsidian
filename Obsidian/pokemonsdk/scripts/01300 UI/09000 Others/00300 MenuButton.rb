module UI
  # Button that is shown in the main menu
  class PSDKMenuButton < SpriteStack
    # Basic coordinate of the button on screen
    BASIC_COORDINATE = [192, 16]
    # Offset between each button
    OFFSET_COORDINATE = [0, 24]
    # Offset between selected position and unselected position
    SELECT_POSITION_OFFSET = [-6, 0]
    # List of text message to send in order to get the right text
    TEXT_MESSAGES =
      [
        [:text_get, 14, 1], # Dex
        [:text_get, 14, 0], # PARTY
        [:text_get, 14, 2], # BAG
        [:text_get, 14, 3], # TCARD
        [:text_get, 14, 5], # Options
        [:text_get, 14, 4], # Save
        [:ext_text, 9000, 26], # Quit
        [:text_get, 14, 2] # BAG (girl)
      ]
    # Angle variation of the icon in one direction
    ANGLE_VARIATION = 15
    # @return [Boolean] selected
    attr_reader :selected
    # Create a new PSDKMenuButton
    # @param viewport [Viewport]
    # @param real_index [Integer] real index of the button in the menu
    # @param positional_index [Integer] index used to position the button on screen
    def initialize(viewport, real_index, positional_index)
      x = BASIC_COORDINATE.first + positional_index * OFFSET_COORDINATE.first
      y = BASIC_COORDINATE.last + positional_index * OFFSET_COORDINATE.last
      super(viewport, x, y)
      @real_index = real_index
      @real_index = 7 if real_index == 2 && $trainer.playing_girl
      @selected = false
      add_background('menu_button')
      # @type [SpriteSheet]
      @icon = add_sprite(12, 0, 'menu_icons', 2, 8, type: SpriteSheet)
      @icon.select(0, @real_index)
      @icon.set_origin(@icon.width / 2, @icon.height / 2)
      @icon.set_position(@icon.x + @icon.ox, @icon.y + @icon.oy)
      add_text(40, 0, 0, 23, send(*TEXT_MESSAGES[@real_index]).sub(PFM::Text::TRNAME[0], $trainer.name))
    end

    # Update the button animation
    def update
      return unless @selected
      if @counter < (2 * ANGLE_VARIATION)
        @icon.angle -= 1
      elsif @counter < (4 * ANGLE_VARIATION)
        @icon.angle += 1
      else
        return @counter = 0
      end
      @counter += 1
    end

    # Set the selected state
    # @param value [Boolean]
    def selected=(value)
      return if value == @selected
      if value
        move(*SELECT_POSITION_OFFSET)
        @icon.select(1, @real_index)
        @icon.angle = ANGLE_VARIATION
      else
        move(-SELECT_POSITION_OFFSET.first, -SELECT_POSITION_OFFSET.last)
        @icon.select(0, @real_index)
        @icon.angle = 0
      end
      @selected = value
      @counter = 0
    end
  end
end
