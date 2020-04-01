module Battle
  class Visual
    # Show the Wild Battle transtion
    class RBJ_WildTransition
      # Create a new Wild Transition
      # @param battle_scene [Battle::Scene]
      # @param screenshot [Bitmap]
      # @param viewport [Viewport]
      def initialize(battle_scene, screenshot, viewport)
        @viewport = viewport
        @done = false
        create_screenshot(screenshot)
        @battle_scene = battle_scene
        @grounds = battle_scene.visual.grounds
        Graphics.transition(1)
      end

      # Update the transition
      def update
        return (@done = true) unless @update_method
        send(@update_method)
      end

      # Is the animation done
      # @return [Boolean]
      def done?
        return @done
      end

      # Set the Transition in pre_transition mode
      # Create the necessary sprites for the pre_transition
      def pre_transition
        @update_method = :update_pre_transition
        @transition_sprite = Sprite.new(@viewport).set_bitmap(pre_transition_sprite_name, :transition)
        @transition_sprite.src_rect.set(0, 0, *pre_transition_sprite_size)
        @transition_sprite.zoom = @viewport.rect.width / @transition_sprite.width.to_f
        @transition_sprite.y = (@viewport.rect.height - @transition_sprite.height * @transition_sprite.zoom_y) / 2
        @transition_sprite.visible = false
        @counter = 0
        @done = false
      end

      private

      # Return the pre_transtion sprite size
      # @return [Array]
      def pre_transition_sprite_size
        return 40, 30
      end

      # Return the pre_transtion sprite name
      # @return [String]
      def pre_transition_sprite_name
        'rbj/pre_wild'
      end

      # Duration of the flash transition
      FLASH_TRANSITION_DURATION = 91
      # End date of the Sprite transition
      SPRITE_TRANSITION_END = FLASH_TRANSITION_DURATION + 30
      # End of the black transition
      BLACK_TRANSITION_END = SPRITE_TRANSITION_END + 15
      # Update the pre_transition
      def update_pre_transition
        if @counter < FLASH_TRANSITION_DURATION
          update_pre_transition_flash
        elsif @counter < SPRITE_TRANSITION_END
          update_pre_transition_sprite
        elsif @counter == SPRITE_TRANSITION_END
          @viewport.color.set(0, 0, 0, 255)
          dispose_pre_transition
        elsif @counter == BLACK_TRANSITION_END
          @battle_scene&.visual&.unlock
          @done = true
        end
        @counter += 1
      end

      # Update the flash part of the pre transition
      def update_pre_transition_flash
        if @counter % 15 == 0
          col = @viewport.color.red == 0 ? 255 : 0
          @viewport.color.set(col, col, col)
        end
        @viewport.color.alpha = (Math.sin(2 * Math::PI * @counter / 30).abs2.round(2) * 180).to_i
      end

      # Update the sprite part of the pre transition
      def update_pre_transition_sprite
        if @counter == FLASH_TRANSITION_DURATION
          @viewport.color.set(0, 0, 0, 0)
          @transition_sprite.visible = true
        else
          @transition_sprite.src_rect.x += @transition_sprite.width
          if @transition_sprite.src_rect.x >= @transition_sprite.bitmap.width
            @transition_sprite.src_rect.y += @transition_sprite.height
            @transition_sprite.src_rect.x = 0
          end
        end
      end

      # Dispose the pre_transition resources
      def dispose_pre_transition
        @transition_sprite.dispose
        @sceenshot.bitmap.dispose
        @sceenshot.dispose
      end

      # Create the screenshot sprite
      # @param screenshot [Bitmap]
      def create_screenshot(screenshot)
        @sceenshot = Sprite.new(@viewport).set_bitmap(screenshot)
        @sceenshot.set_origin(@viewport.rect.x, @viewport.rect.y)
        @sceenshot.zoom = Graphics.width / screenshot.width.to_f
      end
    end
    WILD_TRANSITIONS.default = RBJ_WildTransition
  end
end
