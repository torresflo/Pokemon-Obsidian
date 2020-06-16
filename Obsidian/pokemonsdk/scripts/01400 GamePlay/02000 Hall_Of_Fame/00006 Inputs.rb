module GamePlay
  class Hall_of_Fame
    # Update the inputs only at the end of the animation
    def update_inputs
      if @animation_state == 3
        if Input.trigger?(:B) || Input.trigger?(:A)
          Audio.bgm_stop
          @running = false
        end
      end
    end
  end
end
