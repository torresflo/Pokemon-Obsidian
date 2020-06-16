# Class that describe a Character Sprite on the Map
class Sprite_Character < RPG::Sprite
  # Zoom conversion array
  ZoomDiv = [1, 2, 1, 2 / 3.0, 1, 1]
  # Zoom of a tile
  TILE_ZOOM = PSDK_CONFIG.tilemap.character_tile_zoom
  # Tag that disable shadow
  Shadow_Tag = '§'
  # Name of the shadow file
  Shadow_File = '0 Ombre Translucide'
  # Tag that add 1 to the superiority of the Sprite_Character
  Sup_Tag = '¤'
  # Character displayed by the Sprite_Character
  # @return [Game_Character]
  attr_accessor :character
  # Return the Sprite bush_depth
  # @return [Integer]
  attr_reader :bush_depth
  # Initialize a new Sprite_Character
  # @param viewport [Viewport] the viewport where the sprite will be shown
  # @param character [Game_Character, Game_Event, Game_Player] the character shown
  def initialize(viewport, character = nil)
    super(viewport)
    @bush_depth_sprite = Sprite.new(viewport)
    @bush_depth_sprite.opacity = 128
    @height = 0
    init(character)
  end

  # Initialize the specific parameters of the Sprite_Character (shadow, add_z etc...)
  # @param character [Game_Character, Game_Event, Game_Player] the character shown
  def init(character)
    @character = character
    dispose_shadow
    @bush_depth_sprite.visible = false
    @bush_depth = 0
    init_add_z_shadow
    init_zoom
    @tile_id = 0
    @character_name = nil
    @pattern = 0
    @direction = 0
    update
  end

  # Initialize the zoom info of the Sprite_Character
  def init_zoom
    self.zoom = 1 # $zoom_factor
    @zoom = PSDK_CONFIG.specific_zoom || ZoomDiv[1] # $zoom_factor.to_i]
  end

  # Initialize the add_z info & the shadow sprite of the Sprite_Character
  def init_add_z_shadow
    event = character.instance_variable_get(:@event)
    return @add_z = 2 if event && event.name.index(Sup_Tag) == 0
    @add_z = 0
    return unless $game_switches[::Yuki::Sw::CharaShadow]
    return if character.shadow_disabled && event && event.pages.size == 1
    init_shadow if !event || event.name.index(Shadow_Tag) != 0
  end

  # Initialize the shadow display
  def init_shadow
    @shadow = Sprite.new(viewport)
    @shadow.bitmap = bmp = RPG::Cache.character(Shadow_File)
    @shadow.src_rect.set(0, 0, bmp.width / 4, bmp.height / 4)
    @shadow.ox = bmp.width / 8
    @shadow.oy = bmp.height / 4
  end

  # Update every informations about the Sprite_Character
  def update
    super if @_animation || @_loop_animation
    # Check if the graphic info where updated
    update_graphics if @character_name != @character.character_name || @tile_id != @character.tile_id

    return unless update_position

    update_pattern if @tile_id == 0

    self.bush_depth = @character.bush_depth
    self.opacity = (@character.transparent ? 0 : @character.opacity)

    update_load_animation if @character.animation_id != 0
    update_bush_depth if @bush_depth > 0
    update_shadow if @shadow
  end

  # Update the graphics of the Sprite_Character
  def update_graphics
    @tile_id = @character.tile_id
    @character_name = @character.character_name
    self.visible = !@character_name.empty? || @tile_id > 0
    if @tile_id >= 384
      update_tile_graphic
    else
      self.bitmap = RPG::Cache.character(@character_name, 0)
      @cw = bitmap.width / 4
      @height = @ch = bitmap.height / 4
      self.ox = @cw / 2
      self.oy = @ch
      self.zoom = 1 if zoom_x != 1
      src_rect.set(@character.pattern * @cw, (@character.direction - 2) / 2 * @ch, @cw, @ch)
      @pattern = @character.pattern
      @direction = @character.direction
    end
  end

  # Update the tile graphic of the sprite
  def update_tile_graphic
    map_data = Yuki::MapLinker.map_datas
    if !map_data || map_data.empty?
      self.bitmap = RPG::Cache.tileset($game_map.tileset_name)
      tile_id = @tile_id - 384
      tlsy = tile_id / 8 * 32
      max_size = 4096 # Graphics::MAX_TEXTURE_SIZE
      src_rect.set((tile_id % 8 + tlsy / max_size * 8) * 32, tlsy % max_size, 32, @height = 32)
    else
      x = @character.x
      y = @character.y
      # @type [Yuki::Tilemap::MapData]
      event_map = map_data.find { |map| map.x_range.include?(x) && map.y_range.include?(y) } || map_data.first
      event_map.assign_tile_to_sprite(self, @tile_id)
      @height = 32
    end
    self.zoom = TILE_ZOOM # _x=self.zoom_y=(16*$zoom_factor)/32.0
    self.ox = 16
    self.oy = 32
    @ch = 32
  end

  # Update the position of the Sprite_Character on the screen
  # @return [Boolean] if the update can continue after the call of this function or not
  def update_position
    set_position(@character.screen_x / @zoom, @character.screen_y / @zoom)
    self.z = @character.screen_z(@ch) + @add_z
    return true
  end

  # Update the pattern animation
  def update_pattern
    pattern = @character.pattern
    if @pattern != pattern
      src_rect.x = pattern * @cw
      @pattern = pattern
    end
    direction = @character.direction
    if @direction != direction
      src_rect.y = (direction - 2) / 2 * @ch
      @direction = direction
    end
  end

  # Load the animation when there's one on the character
  def update_load_animation
    $data_animations ||= load_data('Data/Animations.rxdata')
    Sprite_Character.fix_rmxp_animations
    animation = $data_animations[@character.animation_id]
    animation(animation, true)
    @character.animation_id = 0
  end

  # Update the bush depth effect
  def update_bush_depth
    bsp = @bush_depth_sprite
    bsp.z = z
    bsp.set_position(x, y)
    bsp.zoom = zoom_x
    bsp.bitmap = bitmap if bsp.bitmap != bitmap
    rc = bsp.src_rect
    h = @height
    bd = @bush_depth / 2
    (rc2 = src_rect).height = h - bd
    bsp.set_origin(ox, bd)
    rc.set(rc2.x, rc2.y + rc2.height, rc2.width, bd)
  end

  # Update the shadow
  def update_shadow
    @shadow.opacity = opacity
    @shadow.x = @character.shadow_screen_x
    @shadow.y = @character.shadow_screen_y
    @shadow.z = z - 1
    @shadow.visible = !@character.jumping? && !@character.shadow_disabled && @character.activated?
  end

  # Change the bush_depth
  # @param value [Integer]
  def bush_depth=(value)
    @bush_depth = value.to_i
    return if (@bush_depth_sprite.visible = @bush_depth > 0)
    src_rect.height = @height
    self.oy = @height
  end

  # Dispose the Sprite_Character and its shadow
  def dispose
    super
    dispose_shadow
    @bush_depth_sprite.dispose
  end

  # Dispose the shadow sprite
  def dispose_shadow
    @shadow&.dispose
    @shadow = nil
  end

  # Fix the animation file
  def self.fix_rmxp_animations
    if File.exist?('Data/Animations.rxdata')
      if !File.exist?('Data/Animations.psdk') ||
         File.size('Data/Animations.rxdata') != File.size('Data/Animations.psdk')
        save_data($data_animations, 'Data/Animations.rxdata')
        log_info('Re-Saving animations, it\'ll take 2 second...')
        sleep(2)
        save_data($data_animations, 'Data/Animations.psdk')
      end
    end
  end
end
