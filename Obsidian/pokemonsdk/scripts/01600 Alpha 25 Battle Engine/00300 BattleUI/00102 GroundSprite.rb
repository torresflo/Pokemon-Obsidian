module BattleUI
  # Sprite of the ground in battle
  class GroundSprite < ShaderedSprite
    # Create a new ground sprite
    # @param viewport [Viewport] the viewport where the ground is shown
    # @param name [String] the name of the background so the file will be correctly choosen
    # @param bank [Integer] the bank of the ground
    def initialize(viewport, name, bank)
      super(viewport)
      @bank = bank
      set_bitmap(ground_name(name), :battleback)
      reset_position
    end

    # Reset the Trainer Sprite position
    def reset_position
      set_position(basic_x_position, basic_y_position)
      reset_origin
      self.z = basic_z_position
    end

    private

    # Return the correct name of the ground
    # @param name [String] the background name
    # @return [String] the correct name
    def ground_name(name)
      name = name.sub('back_', 'ground_')
      name << '_back' if @bank == 0
      return name
    end

    # Reset the origin x/y
    def reset_origin
      set_origin(width / 2, height)
    end

    # Return the basic x position
    # @return [Integer]
    def basic_x_position
      return @bank == 0 ? 88 : 233
    end

    # Return the basic y position
    # @return [Integer]
    def basic_y_position
      y = @bank == 0 ? 192 : 124
      y += offset_y
      return y
    end

    # Return the offset_y of the battler
    # @return [Integer]
    def offset_y
      0
    end

    # Return the basic z position of the battler
    def basic_z_position
      return 1
    end
  end
end
