module UI
  # Class responsive of showing a blur screenshot in the current scene
  class BlurScreenshot < ShaderedSprite
    # Create a new blur Screenshot
    # @param last_scene [GamePlay::Base] base scene that should respond to #viewport
    def initialize(last_scene)
      @last_scene = last_scene
      super(guess_viewport)
      self.shader = Shader.new(Shader.load_to_string('blur'))
      self.z = 10_001
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
      @last_scene.is_a?(Scene_Map) ? @last_scene.spriteset.map_viewport : @last_scene.viewport
    end

    # Function that creates the snapshot
    # @return [Bitmap]
    def create_snapshot
      bitmap&.dispose
      self.visible = false
      viewport.sort_z
      last_shader = viewport.shader
      last_tone = viewport.tone.clone
      last_color = viewport.color.clone
      viewport.shader = nil
      viewport.tone.set(0, 0, 0, 0)
      viewport.color.set(0, 0, 0, 0)
      snapshot = viewport.snap_to_bitmap
      viewport.color = last_color
      viewport.tone = last_tone
      viewport.shader = last_shader
      self.visible = true
      return snapshot
    end
  end
end
