module BattleUI
  # Sprite of a Trainer in the battle
  class TrainerSprite < ShaderedSprite
    include GoingInOut
    include MultiplePosition
    # Number of pixels the sprite has to move in other to fade away from the scene
    FADE_AWAY_PIXEL_COUNT = 160
    # Get the animation handler
    # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    attr_reader :animation_handler
    # Get the position of the pokemon shown by the sprite
    # @return [Integer]
    attr_reader :position
    # Get the bank of the pokemon shown by the sprite
    # @return [Integer]
    attr_reader :bank
    # Get the scene linked to this object
    # @return [Battle::Scene]
    attr_reader :scene
    # Define the number of frames inside a back trainer
    BACK_FRAME_COUNT = 2

    # Create a new TrainerSprite
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    # @param battler [String] name of the battler in graphics/battlers
    # @param bank [Integer] Bank where the Trainer is
    # @param position [Integer] position of the battler in the Array
    # @param battle_info [Battle::Logic::BattleInfo]
    def initialize(viewport, scene, battler, bank, position, battle_info)
      super(viewport)
      @animation_handler = Yuki::Animation::Handler.new
      @scene = scene
      @bank = bank
      @position = position
      @battle_info = battle_info
      set_bitmap(battler, :battler)
      src_rect.height = bitmap.height / BACK_FRAME_COUNT if @bank == 0
      reset_position
    end

    # Update the sprite
    def update
      @animation_handler.update
    end

    # Tell if the sprite animations are done
    # @return [Boolean]
    def done?
      return @animation_handler.done?
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

    private

    # Reset the battler position
    def reset_position
      set_position(*sprite_position)
      self.z = basic_z_position
      set_origin(width / 2, height)
    end

    # Return the basic z position of the battler
    def basic_z_position
      z = @bank == 0 ? 501 : 1
      z += @position
      return z
    end

    # Get the base position of the Trainer in 1v1
    # @return [Array(Integer, Integer)]
    def base_position_v1
      return 242, 108 if enemy?

      return 78, 188
    end

    # Get the base position of the Trainer in 2v2+
    # @return [Array(Integer, Integer)]
    def base_position_v2
      if enemy?
        return 202, 103 if @scene.battle_info.battlers[1].size >= 2

        return 242, 108
      end

      return 58, 188
    end

    # Get the offset position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def offset_position_v2
      return 60, 0 unless enemy?

      return 60, 10
    end

    # Creates the go_in animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_in_animation
      origin_x = sprite_position[0] + (enemy? ? FADE_AWAY_PIXEL_COUNT : -FADE_AWAY_PIXEL_COUNT)

      return Yuki::Animation.move_discreet(0.5, self, origin_x, y, *sprite_position)
    end

    # Creates the go_out animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_out_animation
      target_x = sprite_position[0] + (enemy? ? FADE_AWAY_PIXEL_COUNT : -FADE_AWAY_PIXEL_COUNT)

      return Yuki::Animation.move_discreet(0.5, self, *sprite_position, target_x, y)
    end
  end
end
