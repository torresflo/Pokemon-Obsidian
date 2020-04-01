module Util
  class Animation
    # Command animation used to trigger the given block when executed (it's instant so delta will be entierly transmitted to after)
    #
    # Example :
    #   animation.after(Util::Animation::Command.new(object, &:close))
    #   # The close method of object will be called after "animation" is done
    class Command < Animation
      # Create a new Command animation
      # @param object [Object] object affected by the animation
      # @param block [Proc] the block executed by the command animation
      def initialize(object, &block)
        super(object)
        @block = block
      end

      private

      def tick(_delta)
        @done = true
        @block.call(@object)
        return 0
      end
    end
  end
end
