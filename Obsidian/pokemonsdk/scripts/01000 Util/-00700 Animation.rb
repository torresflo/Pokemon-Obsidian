module Util
  # Class that aim to perform some animations on sprite (or other stuff) in quasi-real-time
  class Animation
    # @return [Boolean] if the animation use an internal time source (otherwise rely on Graphics)
    attr_accessor :internal_time

    # Create a new animation
    # @param object [Object] affected by the animation
    # @param duration [Numeric] amount of time to perform the animation
    def initialize(object, duration = 0)
      @object = object
      @done = false
      # @type [Util::Animation, nil] the chained animation
      @after = nil
      # @type [Array<Util::Animation>]
      @parallel = nil
      # @type [Numeric]
      @duration = duration
      # @type [Numeric]
      @elapsed_time = 0
    end

    # Update the animation
    # @param delta [Float] the amount of time elapsed since the last call
    def update(delta = current_time - last_time)
      if @done
        @after&.update(delta)
      else
        consumed = tick(delta)
        if @done
          @after&.reset
          @after&.update(delta - consumed) if consumed < delta
        end
        @last_time = current_time if @internal_time
      end
      if @parallel
        @parallel.each { |animation| animation.update(delta) }
        @parallel.delete_if(&:done?)
      end
    end

    # Is the animation done ?
    # @return [Boolean]
    def done?
      if @done
        return true unless @after
        return @after.done?
      end
      return false
    end

    # Set the animation that comes after
    # @param animation [Util::Animation] animation that comes after
    # @return [Util::Animation] the given argument
    def after(animation)
      @after = animation
      return animation
    end

    # Set a parallel animation
    # @param animation [Util::Animation] animation that is executed in parallel (in update)
    # @return [self]
    def in_parallel_with(animation)
      @parallel ||= []
      @parallel << animation
      return self
    end

    # Stop the current animation
    # @return [self]
    def stop
      @done = true
      @after&.stop
      @parallel&.each(&:stop)
      return self
    end

    # Reset the animation
    # @return [self]
    def reset
      @done = false
      @elapsed_time = 0
      return self
    end

    private

    # Execute the animation
    # @param delta [Float] the amount of time since the last call of tick
    # @return [Float] the consumed time in delta (to allow chain animation)
    def tick(delta)
      @done = true
      return delta
    end

    # Current time when the animation is updated
    # @return [Time]
    def current_time
      @internal_time ? Time.new : Graphics.current_time
    end

    # Last time the animation was updated
    # @return [Time]
    def last_time
      @internal_time ? @last_time : Graphics.last_time
    end

    # Perform a termination test. It'll set @done to true if terminated and return the amount of time consumed in delta.
    # @param delta [Float] the amount of time since the last call of tick
    # @return [Float]
    def termination_test(delta)
      if @elapsed_time >= @duration
        @done = true
        overflow = @elapsed_time - @duration
        return delta if overflow > delta
        return delta - overflow
      end
      return delta
    end

    # Return the elapsed time
    # @return [Float]
    def elapsed_time
      @elapsed_time < @duration ? @elapsed_time : @duration
    end
  end
end
