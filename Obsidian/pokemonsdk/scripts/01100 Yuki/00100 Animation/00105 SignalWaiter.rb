module Yuki
  module Animation
    # Animation that wait for a signal in order to start the sub animation
    class SignalWaiter < Command
      # Create a new SignalWaiter
      # @param name [Symbol] name of the block in resolver to call to know if the signal is there
      # @param args [Array] optional arguments to the block
      # @param block [Proc] if provided, name will be ignored and this block will be used (it prevents this animation from being savable!)
      def initialize(name = nil, *args, &block)
        super()
        @name = name || block
        @args = args
      end

      # Start the animation (initialize it)
      # @param begin_offset [Float] offset that prevents the animation from starting before now + begin_offset seconds
      def start(begin_offset = 0)
        @temp_sub_animation = @sub_animation
        @sub_animation = nil
        super
        # @type [Proc]
        @block_to_call = resolve(@name)
      end

      private

      # Indicate if this animation in particular is done (not the parallel, not the sub, this one)
      # @return [Boolean]
      def private_done?
        @played_until_end || @block_to_call.call(*@args)
      end

      # Perform the animation action
      def update_internal
        @sub_animation = @temp_sub_animation
        @sub_animation&.start
      end
    end

    module_function

    # Create a new SignalWaiter animation
    # @param name [Symbol] name of the block in resolver to call to know if the signal is there
    # @param args [Array] optional arguments to the block
    # @param block [Proc] if provided, name will be ignored and this block will be used (it prevents this animation from being savable!)
    # @return [SignalWaiter]
    def wait_signal(name = nil, *args, &block)
      return SignalWaiter.new(name, *args, &block)
    end
  end
end
