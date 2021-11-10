module Yuki
  module Animation
    module_function

    # Function that creates a message locked animation
    def message_locked_animation
      return MessageLocked.new(0)
    end

    # Animation that doesn't update when message box is still visible
    class MessageLocked < TimedAnimation
      # Update the animation (if message window is not visible)
      def update
        return if $game_temp.message_window_showing || $game_temp.message_text

        super
      end
    end
  end
end
