module UI
  # Class responsive of showing a blur screenshot in the current scene
  class BlurScreenshot < ShaderedSprite
    # Create a new blur Screenshot
    # @param last_scene [GamePlay::Base] base scene that should respond to #viewport
    def initialize(last_scene)
      @last_scene = last_scene
      super(guess_viewport)
      self.shader = Shader.new(Shader.load_to_string('blur'))
      update_snapshot
    end

    # Dispose the sprite
    def dispose
      bitmap.dispose
      super
    end

    # Update the snapshot
    def update_snapshot
      self.bitmap = create_snapshot
      shader.set_float_uniform('resolution', [width, height])
    end

    private

    # Function that detects the viewport to use
    # @return [Viewport]
    def guess_viewport
      $scene.viewport
    end

    # Function that creates the snapshot
    # @return [Bitmap]
    def create_snapshot
      bitmap&.dispose
      return @last_scene.viewport.snap_to_bitmap if @last_scene.is_a?(Scene_Battle)

      return @last_scene.snap_to_bitmap
    end
  end
end
