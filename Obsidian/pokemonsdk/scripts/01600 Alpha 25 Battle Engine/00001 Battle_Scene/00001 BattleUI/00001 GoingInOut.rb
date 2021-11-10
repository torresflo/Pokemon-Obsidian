# Module that hold all the Battle UI elements
module BattleUI
  # Module that implements the Going In & Out animation for each sprites/stacks of the UI
  #
  # To work this module requires `animation_handler` to return a `Yuki::Animation::Handler` !
  module GoingInOut
    # @!method animation_handler
    #   Get the animation handler
    #   @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    # Tell the element to go into the scene
    def go_in
      delta = go_in_out_delta
      animation_handler[:in_out] ||= go_in_animation
      animation_handler[:in_out].start(delta)
      @__in_out = :in
    end

    # Tell the element to go out of the scene
    # @param forced_delta [Float] set the forced delta to force the animation to be performed with a specific delta
    def go_out(forced_delta = nil)
      delta = forced_delta || go_in_out_delta
      animation_handler[:in_out] ||= go_out_animation
      animation_handler[:in_out].start(delta)
      @__in_out = :out
    end

    # Tell if the UI element is in
    # @note By default a UI element is considered as in because it's initialized in its in position
    # @return [Boolean]
    def in?
      return !out?
    end

    # Tell if the UI element is out
    # @return [Boolean]
    def out?
      return @__in_out == :out
    end

    private

    # Creates the go_in animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_in_animation
      return Yuki::Animation.wait(0)
    end

    # Creates the go_out animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_out_animation
      return Yuki::Animation.wait(0)
    end

    # Get the delta to use to accord with the previous going-in-out animation
    # @return [Float]
    def go_in_out_delta
      return 0 if animation_handler[:in_out]&.done?

      delta = (animation_handler[:in_out] ? animation_handler[:in_out].time_source.call - animation_handler[:in_out].end_time : 0)
      return delta.clamp(-Float::INFINITY, 0)
    end
  end
end
