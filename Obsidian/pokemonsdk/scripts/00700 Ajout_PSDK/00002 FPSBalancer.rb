module Graphics
  # Class helping to balance FPS on FPS based things
  class FPSBalancer
    @globally_enabled = true
    @last_f3_up = Time.new - 10
    # Create a new FPSBalancer
    def initialize
      # Tell the number of frame to execute
      @frame_to_execute = 0
      # Get the last framerate
      @last_frame_rate = 0
      # Get the frame delta in usec
      @frame_delta = 1
      # Get the last interval index when the graphics were updated
      @last_interval_index = 0
    end

    # Update the metrics of the FPSBalancer
    def update
      update_intervals if @last_frame_rate != Graphics.frame_rate
      current_index = (Graphics.current_time.usec / @frame_delta).floor
      if current_index == @last_interval_index
        @frame_to_execute = 0
      elsif current_index > @last_interval_index
        @frame_to_execute = current_index - @last_interval_index
      else
        @frame_to_execute = Graphics.frame_rate - @last_interval_index + current_index
      end
      @last_interval_index = current_index
      if Sf::Keyboard.press?(Sf::Keyboard::F3)
        FPSBalancer.last_f3_up = Graphics.current_time
      elsif FPSBalancer.last_f3_up == Graphics.last_time
        FPSBalancer.globally_enabled = !FPSBalancer.globally_enabled
        FPSBalancer.last_f3_up -= 1
      end
    end

    # Run code according to FPS Balancing (block will be executed only if it's ok)
    # @param block [Proc] code to execute as much as needed
    def run(&block)
      return unless block_given?
      return block.call unless FPSBalancer.globally_enabled

      @frame_to_execute.times(&block)
    end

    # Tell if the balancer is skipping frames
    def skipping?
      FPSBalancer.globally_enabled && @frame_to_execute == 0
    end

    private

    def update_intervals
      @last_frame_rate = Graphics.frame_rate
      @frame_delta = 1_000_000.0 / @last_frame_rate
      @last_interval_index = (Graphics.current_time.usec / @frame_delta).floor - 1
      @last_interval_index += Graphics.frame_rate if @last_interval_index < 0
    end

    Hooks.register(Graphics, :post_transition, 'Reset interval after transition') do
      FPSBalancer.global.send(:update_intervals)
    end

    class << self
      # Get if the FPS balancing is globally enabled
      # @return [Boolean]
      attr_accessor :globally_enabled
      # Get last time F3 was pressed
      # @return [Time]
      attr_accessor :last_f3_up
      # Get the global balancer
      # @return [FPSBalancer]
      attr_reader :global
    end

    module Marker
      # Function telling the object is supposed to be frame balanced
      def frame_balanced?
        return true
      end
    end

    @global = new
  end

  class << self
    alias original_update update
    # Update with fps balancing
    def update
      FPSBalancer.global.update
      if FPSBalancer.global.skipping? && !frozen? && $scene.is_a?(FPSBalancer::Marker)
        fps_update if respond_to?(:fps_update, true)
        update_no_input
        fps_gpu_update if respond_to?(:fps_gpu_update, true)
      else
        original_update
      end
    end
  end
end
