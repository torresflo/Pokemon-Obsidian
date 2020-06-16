module Yuki
  # Module containing all the animation utility
  module Animation
    pi_div2 = Math::PI / 2
    # Hash describing all the distrotion procs
    DISTORTIONS = {
      # Proc defining the SMOOTH Time distortion
      SMOOTH_DISTORTION: proc { |x| 1 - Math.cos(pi_div2 * x**1.5)**5 },
      # Proc defining the UNICITY Time distortion (no distortion at all)
      UNICITY_DISTORTION: proc { |x| x }
    }
    # Hash describing all the time sources
    TIME_SOURCES = {
      # Generic time source (callable object that gives the current time)
      GENERIC_TIME_SOURCE: Graphics.method(:current_time) # Time.method(:now)
    }
    # Default object resolver (make the game crash)
    DEFAULT_RESOLVER = proc { |x| raise "Couldn't resolve object :#{x}" }

    module_function

    # Create a "wait" animation
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def wait(during, time_source: :GENERIC_TIME_SOURCE)
      TimedAnimation.new(during, :UNICITY_DISTORTION, time_source)
    end

    # Class calculating time offset for animation.
    #
    # This class also manage parallel & sub animation. Example :
    #   (TimedAnimation.new(1) | TimedAnimation.new(2) > TimedAnimation.new(3)).root
    #   # Is equivalent to
    #   TimedAnimation.new(1).parallel_play(TimedAnimation.new(2)).play_before(TimedAnimation.new(3)).root
    #   # Which is equivalent to : play 1 & 2 in parallel and then play 3
    #   # Note that if 2 has sub animation, its sub animation has to finish in order to see animation 3
    class TimedAnimation
      # @return [Array<TimedAnimation>] animation playing in parallel
      attr_reader :parallel_animation
      # @return [TimedAnimation, nil] animation that plays after
      attr_reader :sub_animation
      # @return [TimedAnimation] the root animation
      #   (to retreive the right animation to play when building animation using operators)
      attr_accessor :root
      # Create a new TimedAnimation
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
      #   convert it to another number (between 0 & 1) in order to distord time
      # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
      def initialize(time_to_process, distortion = :UNICITY_DISTORTION, time_source = :GENERIC_TIME_SOURCE)
        @time_to_process = time_to_process.to_f
        @distortion = distortion
        @time_source = time_source
        @sub_animation = nil
        @parallel_animations = []
        @root = self # We make self as default root so the animations will always have a root
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        # Resolve the distortion & time source
        @distortion = DISTORTIONS[@distortion] || resolve(@distortion) if @distortion.is_a?(Symbol)
        @time_source = TIME_SOURCES[@time_source] || resolve(@time_source) if @time_source.is_a?(Symbol)
        # @type [Time] time when the animation started
        @begin_time = @time_source.call + begin_offset
        # @type [Time] time when the animation ends
        @end_time = @begin_time + @time_to_process
        # Start all the parallel animation
        @parallel_animations.each { |animation| animation.start(begin_offset) }
        # Start the sub animation
        @sub_animation&.start(begin_offset + @time_to_process)
        # Boolean telling if the animation has been processed until the end (to prevent some display error)
        @played_until_end = false
      end

      # Indicate if the animation is done
      # @note should always be called after start
      # @return [Boolean]
      def done?
        private_done? && @parallel_animations.all?(&:done?) && (@sub_animation ? @sub_animation.done? : true) &&
          @played_until_end
      end

      # Update the animation internal time and call update_internal with a parameter between
      # 0 & 1 indicating the progression of the animation
      # @note should always be called after start
      def update
        return unless private_began?
        return if done?
        @parallel_animations.each(&:update)
        # Update the sub animation if the current animation is actually done
        if private_done?
          unless @played_until_end
            update_internal(1)
            @played_until_end = true
          end
          return unless @parallel_animations.all?(&:done?)
          return @sub_animation&.update
        end
        # Calculate the time progression value, apply it the distortion and send it to update_internal
        update_internal(@distortion.call((@time_source.call - @begin_time) / @time_to_process))
      end

      # Add a parallel animation
      # @param other [TimedAnimation] the parallel animation to add
      # @return [self]
      def |(other)
        @parallel_animations << other
        return self
      end

      alias_method :<<, :|
      alias_method :parallel_add, :|
      alias_method :parallel_play, :|

      # Add this animation in parallel of another animation
      # @param other [TimedAnimation] the parallel animation to add
      # @return [TimedAnimation] the animation parameter
      def >>(other)
        other.parallel_add(self)
        return other
      end

      alias_method :in_parallel_of, :>>

      # Add a sub animation
      # @param other [TimedAnimation]
      # @return [TimedAnimation] the animation parameter
      def >(other)
        if @sub_animation
          @sub_animation.play_before(other)
        else
          @sub_animation = other
        end
        other.root = root
        return other
      end

      alias_method :play_before, :>

      # Define the resolver (and transmit it to all the childs / parallel)
      # @param resolver [#call] callable that takes 1 parameter and return an object
      def resolver=(resolver)
        @resolver = resolver
        @sub_animation&.resolver = resolver
        @parallel_animations.each { |animation| animation.resolver = resolver }
      end

      private

      # Indicate if this animation in particular is done (not the parallel, not the sub, this one)
      # @return [Boolean]
      def private_done?
        @time_source.call > @end_time
      end

      # Indicate if this animation in particular has started
      def private_began?
        @time_source.call >= @begin_time
      end

      # Method you should always overwrite in order to perform the right animation
      # @param time_factor [Float] number between 0 & 1 indicating the progression of the animation
      def update_internal(time_factor)
        # Does nothing
      end

      # Resolve an object from a symbol using the resolver
      # @param param [Symbol, Object]
      # @return [Object]
      def resolve(param)
        return param unless param.is_a?(Symbol)
        return (@resolver || DEFAULT_RESOLVER).call(param)
      end
    end

    # Create a rotation animation
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property
    # @param angle_start [Float, Symbol] start angle
    # @param angle_end [Float, Symbol] end angle
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def rotation(during, on, angle_start, angle_end, distortion: :UNICITY_DISTORTION, time_source: :GENERIC_TIME_SOURCE)
      ScalarAnimation.new(during, on, :angle=, angle_start, angle_end, distortion: distortion, time_source: time_source)
    end

    # Create a opacity animation
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property
    # @param opacity_start [Float, Symbol] start opacity
    # @param opacity_end [Float, Symbol] end opacity
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def opacity_change(during, on, opacity_start, opacity_end, distortion: :UNICITY_DISTORTION,
                       time_source: :GENERIC_TIME_SOURCE)
      ScalarAnimation.new(during, on, :opacity=, opacity_start, opacity_end,
                          distortion: distortion, time_source: time_source)
    end

    # Class that perform a scalar animation (set object.property to a upto b depending on the animation)
    class ScalarAnimation < TimedAnimation
      # Create a new ScalarAnimation
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param on [Object] object that will receive the property
      # @param property [Symbol] name of the property to affect (add the = sign in the symbol name)
      # @param a [Float, Symbol] origin position
      # @param b [Float, Symbol] destination position
      # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
      # convert it to another number (between 0 & 1) in order to distord time
      # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
      def initialize(time_to_process, on, property, a, b, distortion: :UNICITY_DISTORTION,
                     time_source: :GENERIC_TIME_SOURCE)
        super(time_to_process, distortion, time_source)
        @origin = a
        @end = b
        @on = on
        @property = property
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        super
        @on = resolve(@on)
        @origin = resolve(@origin)
        @delta = resolve(@end) - @origin
      end

      private

      # Update the scalar animation
      # @param time_factor [Float] number between 0 & 1 indicating the progression of the animation
      def update_internal(time_factor)
        @on.send(@property, @origin + @delta * time_factor)
      end
    end

    # Create a move animation (from a to b)
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property
    # @param start_x [Float, Symbol] start x
    # @param start_y [Float, Symbol] start y
    # @param end_x [Float, Symbol] end x
    # @param end_y [Float, Symbol] end y
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def move(during, on, start_x, start_y, end_x, end_y, distortion: :UNICITY_DISTORTION,
             time_source: :GENERIC_TIME_SOURCE)
      Dim2Animation.new(during, on, :set_position, start_x, start_y, end_x, end_y,
                        distortion: distortion, time_source: time_source)
    end

    # Create a move animation (from a to b) with discreet values (Integer)
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property
    # @param start_x [Float, Symbol] start x
    # @param start_y [Float, Symbol] start y
    # @param end_x [Float, Symbol] end x
    # @param end_y [Float, Symbol] end y
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def move_discreet(during, on, start_x, start_y, end_x, end_y, distortion: :UNICITY_DISTORTION,
                      time_source: :GENERIC_TIME_SOURCE)
      Dim2AnimationDiscreet.new(during, on, :set_position, start_x, start_y, end_x, end_y,
                                distortion: distortion, time_source: time_source)
    end

    # Create a origin pixel shift animation (from a to b inside the bitmap)
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property
    # @param start_x [Float, Symbol] start ox
    # @param start_y [Float, Symbol] start oy
    # @param end_x [Float, Symbol] end ox
    # @param end_y [Float, Symbol] end oy
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def shift(during, on, start_x, start_y, end_x, end_y, distortion: :UNICITY_DISTORTION,
              time_source: :GENERIC_TIME_SOURCE)
      Dim2Animation.new(during, on, :set_origin, start_x, start_y, end_x, end_y,
                        distortion: distortion, time_source: time_source)
    end

    # Class that perform a 2D animation (from point a to point b)
    class Dim2Animation < TimedAnimation
      # Create a new ScalarAnimation
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param on [Object] object that will receive the property
      # @param property [Symbol] name of the property to affect (add the = sign in the symbol name)
      # @param a [Float, Symbol] origin position
      # @param b [Float, Symbol] destination position
      # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
      # convert it to another number (between 0 & 1) in order to distord time
      # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
      def initialize(time_to_process, on, property, a_x, a_y, b_x, b_y, distortion: :UNICITY_DISTORTION,
                     time_source: :GENERIC_TIME_SOURCE)
        super(time_to_process, distortion, time_source)
        @origin_x = a_x
        @origin_y = a_y
        @end_x = b_x
        @end_y = b_y
        @on = on
        @property = property
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        super
        @on = resolve(@on)
        @origin_x = resolve(@origin_x)
        @origin_y = resolve(@origin_y)
        @delta_x = resolve(@end_x) - @origin_x
        @delta_y = resolve(@end_y) - @origin_y
      end

      private

      # Update the scalar animation
      # @param time_factor [Float] number between 0 & 1 indicating the progression of the animation
      def update_internal(time_factor)
        @on.send(@property, @origin_x + @delta_x * time_factor, @origin_y + @delta_y * time_factor)
      end
    end

    # Create a src_rect.x animation
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property (please give sprite.src_rect)
    # @param cell_start [Integer, Symbol] start opacity
    # @param cell_end [Integer, Symbol] end opacity
    # @param width [Integer, Symbol] width of the cell
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def cell_x_change(during, on, cell_start, cell_end, width, distortion: :UNICITY_DISTORTION,
                      time_source: :GENERIC_TIME_SOURCE)
      DiscreetAnimation.new(during, on, :x=, cell_start, cell_end, width,
                            distortion: distortion, time_source: time_source)
    end

    # Create a src_rect.y animation
    # @param during [Float] number of seconds (with generic time) to process the animation
    # @param on [Object] object that will receive the property (please give sprite.src_rect)
    # @param cell_start [Integer, Symbol] start opacity
    # @param cell_end [Integer, Symbol] end opacity
    # @param width [Integer, Symbol] width of the cell
    # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
    # convert it to another number (between 0 & 1) in order to distord time
    # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
    def cell_y_change(during, on, cell_start, cell_end, width, distortion: :UNICITY_DISTORTION,
                      time_source: :GENERIC_TIME_SOURCE)
      DiscreetAnimation.new(during, on, :y=, cell_start, cell_end, width,
                            distortion: distortion, time_source: time_source)
    end

    # Class that perform a discreet number animation (set object.property to a upto b using integer values only)
    class DiscreetAnimation < TimedAnimation
      # Create a new ScalarAnimation
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param on [Object] object that will receive the property
      # @param property [Symbol] name of the property to affect (add the = sign in the symbol name)
      # @param a [Integer, Symbol] origin position
      # @param b [Integer, Symbol] destination position
      # @param factor [Integer, Symbol] factor applied to a & b to produce stuff like src_rect animation (sx * width)
      # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
      # convert it to another number (between 0 & 1) in order to distord time
      # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
      def initialize(time_to_process, on, property, a, b, factor = 1, distortion: :UNICITY_DISTORTION,
                     time_source: :GENERIC_TIME_SOURCE)
        super(time_to_process, distortion, time_source)
        @origin = a
        @end = b
        @factor = factor
        @on = on
        @property = property
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        super
        @on = resolve(@on)
        @origin = resolve(@origin)
        @base = @origin
        @end = resolve(@end)
        @delta = resolve(@end) - @origin + 1
        @end, @origin = @origin, @end if @end < @origin
        @factor = resolve(@factor)
      end

      private

      # Update the scalar animation
      # @param time_factor [Float] number between 0 & 1 indicating the progression of the animation
      def update_internal(time_factor)
        @on.send(@property, (@base + @delta * time_factor).to_i.clamp(@origin, @end) * @factor)
      end
    end

    # Class that perform a 2D animation (from point a to point b)
    class Dim2AnimationDiscreet < TimedAnimation
      # Create a new ScalarAnimation
      # @param time_to_process [Float] number of seconds (with generic time) to process the animation
      # @param on [Object] object that will receive the property
      # @param property [Symbol] name of the property to affect (add the = sign in the symbol name)
      # @param a [Float, Symbol] origin position
      # @param b [Float, Symbol] destination position
      # @param distortion [#call, Symbol] callable taking one paramater (between 0 & 1) and
      # convert it to another number (between 0 & 1) in order to distord time
      # @param time_source [#call, Symbol] callable taking no parameter and giving the current time
      def initialize(time_to_process, on, property, a_x, a_y, b_x, b_y, distortion: :UNICITY_DISTORTION,
                     time_source: :GENERIC_TIME_SOURCE)
        super(time_to_process, distortion, time_source)
        @origin_x = a_x
        @origin_y = a_y
        @end_x = b_x
        @end_y = b_y
        @on = on
        @property = property
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        super
        @on = resolve(@on)
        @origin_x = resolve(@origin_x)
        @origin_y = resolve(@origin_y)
        @delta_x = resolve(@end_x) - @origin_x
        @delta_y = resolve(@end_y) - @origin_y
      end

      private

      # Update the scalar animation
      # @param time_factor [Float] number between 0 & 1 indicating the progression of the animation
      def update_internal(time_factor)
        @on.send(@property, (@origin_x + @delta_x * time_factor).to_i, (@origin_y + @delta_y * time_factor).to_i)
      end
    end
  end
end
