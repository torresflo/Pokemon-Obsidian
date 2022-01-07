module GamePlay
  # Scene responsive of playing a movie (video file)
  class Movie < BaseCleanUpdate::FrameBalanced
    # Constant telling if the BGM should automatically be stopped
    AUTO_STOP_BGM = true
    # Constant telling if the map scene should automatically be hidden
    AUTO_HIDE_MAP = true
    # Create a new Movie scene
    # @param filename [String] name of the file to play
    # @param aliased [Boolean] if the scene should use a viewport to ensure the video gets played in native resolution
    # @param skip_delay [Float] number of seconds the player has to wait before being able to skip the video
    def initialize(filename, aliased = false, skip_delay = Float::INFINITY)
      super(true)
      auto_require_movie_player
      @video = SFE::Movie.new
      @video.open_from_file(filename)
      @skip_delay = skip_delay
      @aliased = aliased
      @mutex = Mutex.new
    end

    def update_inputs
      return false unless @start_time

      dt = Graphics.current_time - @start_time
      if dt > @skip_delay && (Input.trigger?(:A) || Input.trigger?(:B) || Mouse.trigger?(:LEFT))
        @video.stop
        @running = false
      end

      return false
    end

    def update_graphics
      return start_video unless @start_time
      return @running = false unless @video.playing?
      @mutex.synchronize { @video.update_bitmap(@sprite.bitmap) }
      @video_thread.wakeup if @video_thread.status
    end

    private

    # Redefine main_end to show map again & clean up the space a bit
    def main_end
      @video_thread.kill
      @video_thread = nil
      @video = nil
      @__last_scene.sprite_set_visible = true if AUTO_HIDE_MAP && @__last_scene.is_a?(Scene_Map)
      super
    end

    # Function that create an aliased viewport
    def create_viewport
      super
      @viewport.blendmode = BlendMode.new if @aliased
    end

    # Create all the graphics for the UI
    def create_graphics
      create_viewport
      @sprite = Sprite.new(@viewport)
      add_disposable @sprite.bitmap = Texture.new(*@video.get_size.map(&:to_i))
      add_disposable @sprite unless @aliased
      width = @aliased ? @viewport.rect.width : Graphics.width
      height = @aliased ? @viewport.rect.height : Graphics.height
      @sprite.zoom = width / @sprite.width.to_f
      @sprite.y = (height - @sprite.height * @sprite.zoom_y).to_i / 2
      @__last_scene.sprite_set_visible = false if AUTO_HIDE_MAP && @__last_scene.is_a?(Scene_Map)
    end

    def auto_require_movie_player
      filename = PSDK_RUNNING_UNDER_WINDOWS ? "#{ENV['GAMEDEPS'] || '.'}/lib/SFEMovie" : 'SFEMovie'
      filename += PSDK_RUNNING_UNDER_MAC ? '.bundle' : '.so'
      require filename
    end

    def start_video
      Audio.bgm_stop if AUTO_STOP_BGM
      @video.play
      @video.update
      @video.update_bitmap(@sprite.bitmap)
      @video_thread = Thread.new do
        while @video.playing?
          @mutex.synchronize { @video.update }
          sleep
        end
      end
      @start_time = Time.new
    end
  end
end
