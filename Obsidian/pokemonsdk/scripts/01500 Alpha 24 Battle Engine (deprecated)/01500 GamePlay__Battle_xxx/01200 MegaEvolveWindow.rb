class Scene_Battle
  class MegaEvolveWindow < UI::Window
    # Create a new MegaEvolveWindow
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 2, 192 - 32 - 2, 120, 32)
      @button = push(0, 0, nil, :X, type: UI::KeyShortcut)
      @text = add_text(@button.width, 0, 0, 16, 'MEGA EVOLVE')
      hide
      self.z = 10_000
    end

    # Show the Mega Evolve Window
    # @param is_active [Boolean] set or not the active state
    def show(is_active = false)
      self.visible = true
      @text.load_color(is_active ? 2 : 0)
    end

    # Hide the Mega Evolve Window
    def hide
      self.visible = false
    end
  end
end
