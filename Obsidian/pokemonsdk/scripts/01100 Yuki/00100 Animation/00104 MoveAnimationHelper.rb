module Yuki
  module Animation
    module_function

    # Animation resposive of positinning a sprite between two other sprites
    class MoveSpritePosition < ScalarAnimation
      # Create a new ScalarAnimation
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param on [Object] object that will receive the property
      # @param a [Symbol] origin sprite position
      # @param b [Symbol] destination sprite position
      # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
      # convert it to another number (between 0 & 1) in order to distord time
      # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
      def initialize(time_to_process, on, a, b, distortion: :UNICITY_DISTORTION,
                     time_source: :GENERIC_TIME_SOURCE)
        super(time_to_process, on, :x=, 0, 1, distortion: distortion, time_source: time_source)
        @origin_sprite = a
        @destination_sprite = b
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        super
        # @type [Sprite]
        origin_sprite = resolve(@origin_sprite)
        # @type [Sprite]
        destination_sprite = resolve(@destination_sprite)
        @delta_x = destination_sprite.x - origin_sprite.x
        @origin_x = origin_sprite.x
        @delta_y = destination_sprite.y - origin_sprite.y
        @origin_y = origin_sprite.y
        @delta_z = destination_sprite.z - origin_sprite.z
        @origin_z = origin_sprite.z
      end

      # Method you should always overwrite in order to perform the right animation
      # @param time_factor [Float] number between 0 & 1 indicating the progression of the animation
      def update_internal(time_factor)
        @on.set_position(@origin_x + @delta_x * time_factor, @origin_y + @delta_y * time_factor)
        @on.z = @origin_z + @delta_z * time_factor
      end
    end

    # Create a new ScalarAnimation
    # @param time_to_process [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property
    # @param a [Symbol] origin sprite position
    # @param b [Symbol] destination sprite position
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    # @return [MoveSpritePosition]
    def move_sprite_position(time_to_process, on, a, b, distortion: :UNICITY_DISTORTION, time_source: :GENERIC_TIME_SOURCE)
      MoveSpritePosition.new(time_to_process, on, a, b, distortion: :UNICITY_DISTORTION, time_source: :GENERIC_TIME_SOURCE)
    end

    # Create a new TimedLoopAnimation
    # @param time_to_process [Float] number of seconds (with generic time) to process the animation
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def timed_loop_animation(time_to_process, distortion = :UNICITY_DISTORTION, time_source = :GENERIC_TIME_SOURCE)
      TimedLoopAnimation.new(time_to_process, distortion, time_source)
    end

    # Class that help to handle animations that depends on sprite creation commands
    #
    # @example Create a fully resolved animation
    #   root_anim = Yuki::Animation.create_sprite(:viewport, :sprite, Sprite)
    #   resolved_animation = Yuki::Animation.resolved
    #   root_anim.play_before(resolved_animation)
    #   resolved_animation.play_before(...)
    #   resolved_animation.play_before(...)
    #   resolved_animation.parallel_play(...)
    #   root_anim.play_before(Yuki::Animation.dispose_sprite(:sprite))
    #
    # @note The play command of all animation played before resolved animation will be called after all previous animation were called.
    #       It's a good practice not to put something else than dispose command after a fully resolved animation.
    class FullyResolvedAnimation < TimedAnimation
      # Create a new fully resolved animation
      def initialize
        super(0)
      end

      alias timed_animation_start start
      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        @begin_offset = begin_offset
      end

      # Tell if the animation is done
      # @return [Boolean]
      def done?
        !@begin_offset && super
      end

      # Update the animation internal time and call update_internal with a parameter between
      # 0 & 1 indicating the progression of the animation
      # @note should always be called after start
      def update
        timed_animation_start(@begin_offset) if @begin_offset
        @begin_offset = nil
        super
      end
    end

    # Create a fully resolved animation
    # @return [FullyResolvedAnimation]
    def resolved
      return FullyResolvedAnimation.new
    end
  end
end
