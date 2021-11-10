module UI
  # Show a panel about the currently visited zone on the map
  class MapPanel < SpriteStack
    # Animation delta y
    DELTA_Y = 32
    # Create a new MapPanel
    # @param viewport [Viewport]
    # @param zone [GameData::Zone]
    def initialize(viewport, zone)
      super(viewport, *initial_coordinates, default_cache: :windowskin)
      @zone = zone
      create_sprites
      self.z = 5000
      viewport.sort_z
    end

    # Update the panel animation
    def update
      return if Graphics.frozen?

      create_animation unless @animation
      @animation.update
    end

    # Tell if the animation is done and the pannel should be disposed
    def done?
      return false if Graphics.frozen?
      return true unless @animation

      return @animation.done?
    end

    private

    def create_sprites
      create_background
      create_text
    end

    def create_animation
      @animation = Yuki::Animation.wait_signal { $game_temp.transition_processing == false }
      @animation.play_before(Yuki::Animation.move_discreet(0.54, self, x, y, x, y + DELTA_Y))
      @animation.play_before(Yuki::Animation.wait(1.5))
      @animation.play_before(Yuki::Animation.move_discreet(0.54, self, x, y + DELTA_Y, x, y))
      @animation.start
    end

    def create_background
      add_background(background_filename)
    end

    def create_text
      map_name = @zone.map_name
      color = 10
      map_name.gsub!(/\\c\[([0-9]+)\]/) do
        color = $1.to_i
        nil
      end
      fixed_map_name = PFM::Text.parse_string_for_messages(map_name)
      add_text(0, -2, @stack.first.width, @stack.first.height, fixed_map_name, 1, color: color)
    end

    def background_filename
      attempt = "panel_#{@zone.panel_id}"
      return attempt if RPG::Cache.windowskin_exist?(attempt)

      return "pannel_#{@zone.panel_id}"
    end

    def initial_coordinates
      return [2, -30]
    end
  end
end
