module NuriYuri
  module DynamicLight
    # Sprite that simulate the dynamic light and can be scaled
    class ScalableDLS < DynamicLightSprite
      # Create a new ScalableDynamicLightSprite
      # @param character [Game_Character]
      # @param light_type [Integer] Type of the light we'll display on the character
      # @param animation_type [Integer] Type of the animation performed on the light
      # @param zoom_count [Integer] initial value of the zoom_count
      # @param opacity_count [Integer] initial value of the opacity_count
      # @param init_scale [Numeric] initial scale of the object
      def initialize(character, light_type, animation_type = 0, zoom_count = 0, opacity_count = 0, init_scale = 1)
        super(character, light_type, animation_type, zoom_count, opacity_count)
        @scale = init_scale
        @init_scale = init_scale
        @target_scale = init_scale
        @target_scale_count = 0
        @target_scale_max = 0
      end

      # Change the zoom of the sprite
      # @param value [Numeric] New zoom
      def zoom=(value)
        super(@scale == 1 ? value : value * @scale)
      end

      # Retrieve the current scale of the sprite (without the animation effect)
      # @return [Numeric]
      def scale
        @target_scale
      end

      # Update the sprite
      def update
        if visible
          if @target_scale_count < @target_scale_max
            @scale = @init_scale + @target_scale_count * (@target_scale - @init_scale) / @target_scale_max
            @target_scale_count += 1
          end
        end
        super
      end

      # Tell the sprite to scale
      # @param target_scale [Numeric] target value the sprite should scale
      # @param duration [Integer] number of frame the sprite should take to scale
      def scale_to(target_scale, duration = 0)
        @target_scale_count = 0
        if duration < 1
          @init_scale = @scale = @target_scale = target_scale
          @target_scale_max = 0
        else
          @init_scale = @scale
          @target_scale = target_scale.to_f
          @target_scale_max = duration
        end
        $pokemon_party.nuri_yuri_dynamic_light[@light_id][:params][5] = target_scale
      end
    end
  end
end
