module BattleUI
  # Sprite of a trainer shown in battle
  class TrainerSprite < ShaderedSprite
    # Define the number of frames inside a back trainer
    BACK_FRAME_COUNT = 2

    # Create a new TrainerSprite
    # @param viewport [Viewport]
    # @param battler [String] name of the battler in graphics/battlers
    # @param bank [Integer] Bank where the Trainer is
    # @param position [Integer] position of the battler in the Array
    # @param battle_info [Battle::Logic::BattleInfo]
    def initialize(viewport, battler, bank, position, battle_info)
      super(viewport)
      @bank = bank
      @position = position
      @battle_info = battle_info
      set_bitmap(battler, :battler)
      self.frame_height = bitmap.height / BACK_FRAME_COUNT if @bank == 0
      reset_position
    end

    # Set the battler on its next frame
    # @note Frames are ordered on the vertical axis
    def show_next_frame
      new_y = src_rect.y + src_rect.height
      src_rect.y = new_y if new_y < bitmap.height
    end

    # Set the battler on its previous frame
    # @note Frames are ordered on the vertical axis
    def show_previous_frame
      new_y = src_rect.y - src_rect.height
      src_rect.y = new_y if new_y >= 0
    end

    # Reset the Trainer Sprite position
    def reset_position
      set_position(basic_x_position, basic_y_position)
      reset_origin
      self.z = basic_z_position
    end

    # Set the src_rect of the sprite in order to animate it
    # @param value [Integer]
    def frame_height=(value)
      src_rect.height = value
      reset_origin
    end

    private

    # Reset the origin x/y
    def reset_origin
      set_origin(width / 2, height)
    end

    # Return the basic x position
    # @return [Integer]
    def basic_x_position
      battler_count = @battle_info.battlers[@bank].size
      if @bank == 0
        x = 88
        if battler_count > 1
          x -= 24
          x += @position * 48
        end
      else
        x = 233
        if battler_count > 1
          x -= 12
          x += @position * 24
        end
      end
      return x
    end

    # Return the basic y position
    # @return [Integer]
    def basic_y_position
      y = @bank == 0 ? 192 : 94
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
      return @bank == 0 ? 1001 : 2
    end
  end
end
