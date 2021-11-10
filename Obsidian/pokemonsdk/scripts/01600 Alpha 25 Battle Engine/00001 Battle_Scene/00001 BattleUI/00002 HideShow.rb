module BattleUI
  # Module that implements the Hide & Show animation for each sprites/stacks of the UI
  #
  # To work this module requires `animation_handler` to return a `Yuki::Animation::Handler` !
  #
  # You can specify a `hide_show_duration` function to overwrite the duration of this animation
  module HideShow
    # @!method animation_handler
    #   Get the animation handler
    #   @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    # Tell the element to show in the scene
    def show
      delta = hide_show_delta
      animation_handler[:hide_show] = show_animation
      animation_handler[:hide_show].start(delta)
    end

    # Tell the element to hide from scene
    def hide
      delta = hide_show_delta
      animation_handler[:hide_show] = hide_animation
      animation_handler[:hide_show].start(delta)
    end

    private

    # Creates the hide animation
    # @return [Yuki::Animation::TimedAnimation]
    def hide_animation
      ya = Yuki::Animation
      animation = ya.opacity_change(hide_show_duration, self, opacity, 0)
      animation.play_before(ya.send_command_to(self, :visible=, false))
      return animation
    end

    # Creates the show animation
    # @param target_opacity [Integer] the desired opacity (if you need non full opacity)
    # @return [Yuki::Animation::TimedAnimation]
    def show_animation(target_opacity = 255)
      ya = Yuki::Animation
      animation = ya.send_command_to(self, :visible=, true)
      animation.play_before(ya.opacity_change(hide_show_duration, self, 0, target_opacity))
      return animation
    end

    # Get the delta to use to accord with the previous hiding/showing animation
    # @return [Float]
    def hide_show_delta
      return 0 if animation_handler[:hide_show]&.done?

      delta = (animation_handler[:hide_show]&.end_time ? animation_handler[:hide_show].time_source.call - animation_handler[:hide_show].end_time : 0)
      return delta.clamp(-Float::INFINITY, 0)
    end

    # get the duration of the hide show animation
    # @return [Float]
    def hide_show_duration
      return 0.1
    end
  end
end
