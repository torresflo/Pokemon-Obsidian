module NuriYuri
  module DynamicLight
    # Sprite that simulate the dynamic light
    class DynamicLightSprite < ::Sprite
      # Offset of the light in :direction mode
      DIRECTION_OFFSET = -12
      # Offset of the light in other modes
      NORMAL_OFFSET = -8

      # @return [Integer] ID of the light in the stack
      attr_accessor :light_id

      # Create a new DynamicLightSprite
      # @param character [Game_Character]
      # @param light_type [Integer] Type of the light we'll display on the character
      # @param animation_type [Integer] Type of the animation performed on the light
      # @param zoom_count [Integer] initial value of the zoom_count
      # @param opacity_count [Integer] initial value of the opacity_count
      def initialize(character, light_type, animation_type = 0, zoom_count = 0, opacity_count = 0)
        super(DynamicLight.viewport)
        @character = character
        load_light(LIGHTS[light_type])
        animation = ANIMATIONS[animation_type]
        @zoom_list = animation[:zoom]
        @zoom_count = zoom_count
        @opacity_list = animation[:opacity]
        @opacity_count = opacity_count
        @zoom = PSDK_CONFIG.specific_zoom || 2
      end

      # Update the sprite
      def update
        @opacity_count = (@opacity_count + 1) % @opacity_list.size
        @zoom_count = (@zoom_count + 1) % @zoom_list.size
        return unless visible

        self.zoom = @zoom_list[@zoom_count]
        self.opacity = @opacity_list[@opacity_count]
        set_position(@character.screen_x / @zoom, @character.screen_y / @zoom + @offset_y)
        sub_sprite_update if @sub_sprite
        update_direction if @mode == :direction
      end

      # Return if the light is on or not
      alias on visible

      # Change the sprite visibility
      # @parma value [Boolean]
      def visible=(value)
        super
        @sub_sprite.visible = value if @sub_sprite
      end

      # Dispose the sprite
      def dispose
        @sub_sprite&.dispose
        super
      end

      alias on= visible=

      private

      # Update the direction of the sprite
      def update_direction
        if @direction != @character.direction
          @direction = @character.direction
          case @direction
          when 2
            self.angle = 180
          when 4
            self.angle = 90
          when 6
            self.angle = -90
          else
            self.angle = 0
          end
          update_sub_sprite_angle
        end
      end

      # Update the sub sprite
      def sub_sprite_update
        return unless visible

        @sub_sprite.zoom = zoom_x
        # self.opacity = opacity # Not required since the work will be done by the blendmode
        @sub_sprite.set_position(x, y)
      end

      # Update the sub sprite angle
      def update_sub_sprite_angle
        return unless @sub_sprite

        @sub_sprite.angle = angle
        if angle == 0
          @sub_sprite.z = @character.screen_z - 1
        else
          @sub_sprite.z = 10_000
        end
      end

      # Load the light images
      # @param light_array [Array] informations about the light
      def load_light(light_array)
        @mode = light_array.first
        # Load the main image
        set_bitmap(light_array[1], :particle)
        if @mode == :direction
          set_origin(bitmap.width / 2, bitmap.height)
          @offset_y = DIRECTION_OFFSET
        else
          set_origin(bitmap.width / 2, bitmap.height / 2)
          @offset_y = NORMAL_OFFSET
        end
        # Load the sub sprite
        if light_array[2]
          @sub_sprite = Sprite.new($scene.spriteset.map_viewport)
          @sub_sprite.set_bitmap(light_array[2], :particle)
          if @mode == :direction
            @sub_sprite.set_origin(@sub_sprite.bitmap.width / 2, @sub_sprite.bitmap.height)
          else
            @sub_sprite.set_origin(@sub_sprite.bitmap.width / 2, @sub_sprite.bitmap.height / 2 + NORMAL_OFFSET)
          end
        end
      end
    end
  end
end
