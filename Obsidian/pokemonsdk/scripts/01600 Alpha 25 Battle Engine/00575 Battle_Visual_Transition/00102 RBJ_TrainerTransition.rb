module Battle
  class Visual
    # Show the Trainer Battle transtion
    class RBJ_TrainerTransition < RBJ_WildTransition
      # Set the Transition in pre_transition mode
      # Create the necessary sprites for the pre_transition
      def pre_transition
        @update_method = :update_pre_transition
        @transition_sprite = Sprite.new(@viewport)
        @transition_sprite.bitmap = make_pre_transition_bitmap
        @transition_sprite.zoom = 8
        @counter = 0
        @done = false
      end

      private

      # Method that creates the pre_transition bitmap & image in order to animate this transition
      # @return [Bitmap]
      def make_pre_transition_bitmap
        bmp_width = (@viewport.rect.width / 8.0).ceil
        bmp_height = (@viewport.rect.height / 8.0).ceil
        @pix_to_draw = (bmp_width * bmp_height / 160.0).ceil
        @image = Image.new(bmp_width, bmp_height)
        @x = 0
        @y = 0
        @dir = 2
        @color = Color.new(0, 0, 0, 255)
        return Bitmap.new(bmp_width, bmp_height)
      end

      # Update the pre_transition
      # @return [Boolean] if the animation is finished
      def update_pre_transition
        if @counter < 160
          update_pre_transition_sprite
        elsif @counter == 160
          @viewport.color.set(0, 0, 0, 255)
          dispose_pre_transition
        else
          @battle_scene&.visual&.unlock
          @done = true # We're done
        end
        @counter += 1
      end

      # Update the sprite part of the pre transition
      def update_pre_transition_sprite
        @pix_to_draw.times do
          @image.set_pixel(@x, @y, @color)
          update_xy
        end
        @image.copy_to_bitmap(@transition_sprite.bitmap)
      end

      # Update the x/y position
      def update_xy
        case @dir
        when 2
          if test_xy(0, 1)
            @dir = 6
            @x += 1
          else
            @y += 1
          end
        when 6
          if test_xy(1, 0)
            @dir = 8
            @y -= 1
          else
            @x += 1
          end
        when 8
          if test_xy(0, -1)
            @dir = 4
            @x -= 1
          else
            @y -= 1
          end
        else
          if test_xy(-1, 0)
            @dir = 2
            @y += 1
          else
            @x -= 1
          end
        end
      end

      # Test if we should change our x/y direction
      # @param dx [Integer] what to add in x
      # @param dy [Integer] what to add in y
      # @return [Boolean] if the direction should be changed
      def test_xy(dx, dy)
        x = @x + dx
        return true if x < 0 || x >= @image.width
        y = @y + dy
        return true if y < 0 || y >= @image.height
        return @image.get_pixel_alpha(x, y) == 255
      end

      # Dispose the pre_transition resources
      def dispose_pre_transition
        @image.dispose
        @transition_sprite.bitmap.dispose
        @transition_sprite.dispose
        @sceenshot.bitmap.dispose
        @sceenshot.dispose
      end
    end

    TRAINER_TRANSITIONS.default = RBJ_TrainerTransition
  end
end
