module RPG
  # Class that display weather
  class Weather
    # Tone used to simulate the sun weather
    SunnyTone = Tone.new(90, 50, 0, 40)
    # Array containing all the texture initializer in the order of the type
    INIT_TEXTURE = %i[init_rain init_rain init_zenith init_sand_storm init_snow init_fog]
    # Array containing all the weather update methods in the order of the type
    UPDATE_METHODS = %i[update_rain update_rain update_zenith update_sandstorm update_snow update_fog]
    # Methods symbols telling how to set the new type of weather according to the index
    SET_TYPE_METHODS = []
    # Boolean telling if the set_type is managed by PSDK or not
    SET_TYPE_PSDK_MANAGED = []
    # Number of sprite to generate
    MAX_SPRITE = 61
    # Top factor of the max= adjustment (max * top / bottom)
    MAX_TOP = 3
    # Bottom factor of the max= adjustment (max * top / bottom)
    MAX_BOTTOM = 2
    # Return the weather type
    # @return [Integer]
    attr_reader :type
    # Return the max amount of sprites
    # @return [Integer]
    attr_reader :max
    # Return the origin x
    # @return [Numeric]
    attr_reader :ox
    # Return the origin y
    # @return [Numeric]
    attr_reader :oy
    # Create the Weather object
    # @param viewport [LiteRGSS::Viewport]
    # @note : type 0 = None, 1 = Rain, 2 = Sun/Zenith, 3 = Darud Sandstorm, 4 = Hail, 5 = Foggy
    def initialize(viewport = nil)
      @type = 0
      @max = 0
      @ox = 0
      @oy = 0
      init_sprites(viewport)
    end

    # Update the sprite display
    def update
      return if @type == 0
      send(UPDATE_METHODS[@type])
    end

    # Dispose the interface
    def dispose
      @sprites.each(&:dispose)
      @snow_bitmap&.dispose if SET_TYPE_PSDK_MANAGED[4]
    end

    # Update the ox
    # @param ox [Numeric]
    def ox=(ox)
      return if @ox == (ox / 2)
      @ox = ox / 2
      @sprites.each { |sprite| sprite.ox = @ox}
    end

    # Update the oy
    # @param oy [Numeric]
    def oy=(oy)
      return if @oy == (oy / 2)
      @oy = oy / 2
      @sprites.each { |sprite| sprite.oy = @oy }
    end

    # Update the max number of sprites to show
    # @param max [Integer]
    def max=(max)
      max = max * MAX_TOP / MAX_BOTTOM # Upscale to 60
      return if @max == max
      @max = [[max, 0].max, MAX_SPRITE - 1].min
      @sprites.each_with_index do |sprite, i|
        sprite.visible = (i <= @max) if sprite
      end
    end

    # Change the Weather type
    # @param type [Integer]
    def type=(type)
      @last_type = @type
      return if @type == type
      @type = type
      # Init the bitmap
      send(symbol = INIT_TEXTURE[type])
      log_debug("init_texture called : #{symbol}")
      # Call the set type proc
      send(symbol = SET_TYPE_METHODS[type])
      log_debug("set_type called : #{symbol}")
      if SET_TYPE_PSDK_MANAGED[2] && @last_type == 2 && !$game_switches[Yuki::Sw::TJN_Enabled]
        $game_screen.start_tone_change(Yuki::TJN::TONE[3], 40)
      end
    ensure
      if @last_type != @type
        @sprites.first.set_origin(@ox, @oy) if @type != 5 && SET_TYPE_PSDK_MANAGED[5]
        Yuki::TJN.force_update_tone(0) if @type != 2 && SET_TYPE_PSDK_MANAGED[2]
      end
    end

    private

    # Initialize the sprites
    # @param viewport [LiteRGSS::Viewport]
    def init_sprites(viewport)
      @sprites = Array.new(MAX_SPRITE) do
        sprite = Sprite.new(viewport)
        sprite.z = 1000
        sprite.visible = false
        sprite.opacity = 0
        class << sprite
          attr_accessor :counter
        end
        sprite.counter = 0
        next(sprite)
      end
    end

    # Create the sand_storm bitmap
    def init_sand_storm
      return if @sand_storm_bitmaps && !@sand_storm_bitmaps.first.disposed? && !@sand_storm_bitmaps.last.disposed?
      @sand_storm_bitmaps = [RPG::Cache.animation('sand_storm_big'), RPG::Cache.animation('sand_storm_sm')]
    end

    # Create the rain bitmap
    def init_rain
      return if @rain_bitmap && !@rain_bitmap.disposed?
      @rain_bitmap = RPG::Cache.animation('rain_frames')
    end

    # Create the snow bitmap
    def init_snow
      return if @snow_bitmap && !@snow_bitmap.disposed?
      color1 = Color.new(255, 255, 255, 255)
      color2 = Color.new(255, 255, 255, 128)
      @snow_bitmap = Bitmap.new(6, 6)
      @snow_bitmap.fill_rect(0, 1, 6, 4, color2)
      @snow_bitmap.fill_rect(1, 0, 4, 6, color2)
      @snow_bitmap.fill_rect(1, 2, 4, 2, color1)
      @snow_bitmap.fill_rect(2, 1, 2, 4, color1)
      @snow_bitmap.update
    end

    # Initialize the zenith stuff
    def init_zenith
      return
    end

    # Initialize the fog bitmap
    def init_fog
      return if @fog_bitmap && !@fog_bitmap.disposed?
      @fog_bitmap = RPG::Cache.animation('fog')
    end

    # Set the weather type as rain (special animation)
    def set_type_rain
      @type = 1
      bitmap = @rain_bitmap
      @sprites.each_with_index do |sprite, i|
        sprite.visible = (i <= @max)
        sprite.bitmap = bitmap
        sprite.src_rect.set(0, 0, 16, 32)
        sprite.counter = 0
      end
    end

    # Set the weather type as sandstorm (different bitmaps)
    def set_type_sandstorm
      @type = 3
      big = @sand_storm_bitmaps.first
      sm = @sand_storm_bitmaps.last
      49.times do |i|
        next unless (sprite = @sprites[i])
        sprite.visible = true
        sprite.bitmap = big
        sprite.opacity = (7 - (i % 7)) * 128 / 7
        sprite.x = 64 * (i % 7) - 64 + @ox
        sprite.y = 64 * (i / 7) - 80 + @oy
      end
      49.upto(MAX_SPRITE - 1) do |i|
        next unless (sprite = @sprites[i])
        sprite.bitmap = sm
        sprite.x = -999 + @ox
      end
    end

    # Called when type= is called with snow id
    def set_type_snow
      set_type_reset_sprite(@snow_bitmap)
    end

    # Called when type= is called with 0
    def set_type_none
      set_type_reset_sprite(nil)
    end

    # Called when type= is called with sunny id
    def set_type_sunny
      $game_screen.start_tone_change(SunnyTone, @last_type == @type ? 1 : 40)
      set_type_reset_sprite(nil)
    end

    # Set the weather type as fog
    def set_type_fog
      @type = 5
      sprite = @sprites.first
      sprite.bitmap = @fog_bitmap
      sprite.set_origin(0, 0)
      sprite.set_position(0, 0)
      sprite.src_rect.set(0, 0, 320, 240)
      sprite.opacity = 0
      1.upto(MAX_SPRITE - 1) do |i|
        next unless (sprite = @sprites[i])
        sprite.bitmap = nil
      end
    end

    # Reset the sprite when type= is called (and it's managed)
    # @param bitmap [Bitmap]
    def set_type_reset_sprite(bitmap)
      @sprites.each_with_index do |sprite, i|
        next unless sprite
        sprite.visible = (i <= @max)
        sprite.bitmap = bitmap
        sprite.src_rect.set(0, 0, bitmap.width, bitmap.height) if bitmap
        sprite.counter = 0
      end
    end

    # Update the rain weather
    def update_rain
      0.upto(@max) do |i|
        break unless (sprite = @sprites[i])
        sprite.counter += 1
        if sprite.src_rect.x < 16
          sprite.x -= 4 # 2
          sprite.y += 8 # 16
        end
        if sprite.counter > 15 && (sprite.counter % 5) == 0
          sprite.src_rect.x += (sprite.src_rect.x == 0 ? 32 : 16)
          sprite.opacity = 0 if sprite.src_rect.x >= 64
        end
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.opacity < 64 || x < -50 || x > 400 || y < -175 || y > 275 # tout divise par 2 (+25*sign())
          sprite.x = rand(400) - 25 + @ox
          sprite.y = rand(400) - 100 + @oy
          sprite.opacity = 255
          sprite.counter = 0
          sprite.src_rect.x = ((rand(15) == 0) ? 16 : 0)
          sprite.counter = 15 if sprite.src_rect.x == 16
        end
      end
    end

    # Update the sunny weather
    def update_zenith
      sprite = @sprites.first
      sprite.counter += 1
      sprite.counter = 0 if sprite.counter > 320
      $game_screen.tone.blue = Integer(20 * Math.sin(Math::PI * sprite.counter / 160))
    end

    # Update the sandstorm weather
    def update_sandstorm
      0.upto(@max) do |i|
        break unless (sprite = @sprites[i])
        sprite.x += 8
        sprite.y += 1
        if i < 49
          sprite.x -= 384 if sprite.x - @ox > 320
          sprite.y -= 384 if sprite.y - @oy > 304
          sprite.opacity += 4 if sprite.opacity < 255
        else
          sprite.counter += 1
          sprite.x -= Integer(8 * Math.sin(Math::PI * sprite.counter / 10))
          sprite.y -= Integer(4 * Math.cos(Math::PI * sprite.counter / 10))
          sprite.opacity -= 8
        end
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.opacity < 64 || x < -50 || x > 400 || y < -175 || y > 275 # tout divise par 2 (+25*sign())
          next if i < 49
          sprite.x = rand(400) - 25 + @ox
          sprite.y = rand(400) - 100 + @oy
          sprite.opacity = 255
          sprite.counter = 0
        end
      end
    end

    # Update the snow weather
    def update_snow
      0.upto(@max) do |i|
        break unless (sprite = @sprites[i])
        sprite.x -= 1
        sprite.y += 4
        sprite.opacity -= 8
        x = sprite.x - @ox
        y = sprite.y - @oy
        if sprite.opacity < 64 || x < -50 || x > 400 || y < -175 || y > 275 # tout divise par 2 (+25*sign())
          sprite.x = rand(400) - 25 + @ox
          sprite.y = rand(400) - 100 + @oy
          sprite.opacity = 255
          sprite.counter = 0
        end
      end
    end

    # Update the fog weather
    def update_fog
      sprite = @sprites.first
      sprite.set_origin(0, 0)
      sprite.opacity = @max * 255 / 60
    end

    class << self
      # Register a new type= method call
      # @param type [Integer] the type of weather
      # @param symbol [Symbol] if the name of the method to call
      # @param psdk_managed [Boolean] if it's managed by PSDK (some specific code in the type= method)
      def register_set_type(type, symbol, psdk_managed)
        SET_TYPE_METHODS[type] = symbol
        SET_TYPE_PSDK_MANAGED[type] = psdk_managed
      end
    end

    register_set_type(0, :set_type_none, true)
    register_set_type(1, :set_type_rain, true)
    register_set_type(2, :set_type_sunny, true)
    register_set_type(3, :set_type_sandstorm, true)
    register_set_type(4, :set_type_snow, true)
    register_set_type(5, :set_type_fog, true)
  end
end
