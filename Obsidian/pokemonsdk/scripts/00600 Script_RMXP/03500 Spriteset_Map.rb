# Display everything that should be displayed during the Scene_Map
class Spriteset_Map
  # Retrieve the Game Player sprite
  # @return [Sprite_Character]
  attr_reader :game_player_sprite
  # Initialize a new Spriteset_Map object
  # @param zone [Integer, nil] the id of the zone where the player is
  def initialize(zone = nil)
    @viewport1 = Viewport.create(:main, 0)
    @viewport2 = Viewport.create(:main, 200)
    @viewport3 = Viewport.create(:main, 5000)
    Yuki::ElapsedTime.start(:spriteset_map)
    init_tilemap
    init_panorama_fog
    init_psdk_add
    init_characters
    init_player
    init_weather_picture_timer
    init_quest_informer
    finish_init(zone)
  end

  # Do the same as initialize but without viewport initialization (opti)
  # @param zone [Integer, nil] the id of the zone where the player is
  def reload(zone = nil)
    Yuki::ElapsedTime.start(:spriteset_map)
    dispose_sp_map if @sp_bg
    init_tilemap
    init_psdk_add
    init_characters
    init_player
    finish_init(zone)
  end

  # Last step of the Spriteset initialization
  # @param zone [Integer, nil] the id of the zone where the player is
  def finish_init(zone)
    create_panel(zone)
    Yuki::TJN.force_update_tone
    Yuki::TJN.update
    Yuki::MapLinker.load_buildings
    Yuki::ElapsedTime.show(:spriteset_map, 'End of spriteset init took')
    update
    Graphics.sort_z
  end

  # Return the prefered tilemap class
  # @return [Class]
  def tilemap_class
    return Object.const_get(PSDK_CONFIG.tilemap.tilemap_class)
  end

  # Tilemap initialization
  def init_tilemap
    tilemap_class = self.tilemap_class
    if @tilemap.class != tilemap_class
      @tilemap&.dispose
      @tilemap = tilemap_class.new(@viewport1)
    end
    Yuki::ElapsedTime.show(:spriteset_map, 'Creating tilemap object took')
    # -- @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    # -- Yuki::ElapsedTime.show(:spriteset_map, 'Loading tileset took')
    7.times do |i|
      @tilemap.autotiles[i] = load_autotile($game_map.autotile_names[i])
    end
    Yuki::ElapsedTime.show(:spriteset_map, 'Loading autotiles took')
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    @tilemap.reset
    Yuki::ElapsedTime.show(:spriteset_map, 'Resetting the tilemap took')
  end

  # Attempt to load an autotile
  # @param filename [String] name of the autotile
  # @return [Bitmap] the bitmap of the autotile
  def load_autotile(filename)
    target_filename = filename + '_._tiled'
    if RPG::Cache.autotile_exist?(target_filename)
      filename = target_filename
    else
      if !filename.empty? && RPG::Cache.autotile_exist?(filename)
        Converter.convert_autotile("graphics/autotiles/#{filename}.png")
        filename = target_filename
      end
    end
    return RPG::Cache.autotile(filename)
  end

  # Panorama and fog initialization
  def init_panorama_fog
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
  end

  # PSDK related thing initialization
  def init_psdk_add
    Yuki::ElapsedTime.start(:spriteset_map)
    Yuki::Particles.init(@viewport1)
    Yuki::Particles.set_on_teleportation(true)
    Yuki::FollowMe.init(@viewport1)
    Yuki::ElapsedTime.show(:spriteset_map, 'Loading FollowMe & Particle took')
  end

  # Sprite_Character initialization
  def init_characters
    if (character_sprites = @character_sprites)
      return recycle_characters(character_sprites)
    end
    @character_sprites = character_sprites = []
    $game_map.events.each_value do |event|
      next unless event.can_be_shown?
      sprite = Sprite_Character.new(@viewport1, event)
      event.particle_push
      character_sprites.push(sprite)
    end
    Yuki::ElapsedTime.show(:spriteset_map, 'Slow character sprite creation took')
  end

  # Recycled Sprite_Character initialization
  # @param character_sprites [Array<Sprite_Character>] the actual stack of sprites
  def recycle_characters(character_sprites)
    # Recycle events
    i = -1
    $game_map.events.each_value do |event|
      next unless event.can_be_shown?
      character = character_sprites[i += 1]
      event.particle_push
      if character
        character.init(event)
      else
        character_sprites[i] = Sprite_Character.new(@viewport1, event)
      end
    end
    # Overflow dispose
    i += 1
    character_sprites.pop.dispose while i < character_sprites.size
    Yuki::ElapsedTime.show(:spriteset_map, 'Fast character sprite creation took')
  end

  # Player initialization
  def init_player
    Yuki::FollowMe.update
    Yuki::FollowMe.particle_push
    @character_sprites.push(@game_player_sprite = Sprite_Character.new(@viewport1, $game_player))
    $game_player.particle_push
    Yuki::Particles.update
    Yuki::Particles.set_on_teleportation(false)
    Yuki::ElapsedTime.show(:spriteset_map, 'init_player took')
  end

  # Weather, picture and timer initialization
  def init_weather_picture_timer
    @weather = RPG::Weather.new(@viewport1)
    @picture_sprites = Array.new(50) { |i| Sprite_Picture.new(@viewport2, $game_screen.pictures[i + 1]) }
    @timer_sprite = Sprite_Timer.new
  end

  # Create the quest informer array
  def init_quest_informer
    # @type [Array<UI::QuestInformer>]
    @quest_informers = []
  end

  # Spriteset_map dispose
  # @param from_warp [Boolean] if true, prepare a screenshot with some conditions and cancel the sprite dispose process
  # @return [Sprite, nil] a screenshot or nothing
  def dispose(from_warp = false)
    return take_map_snapshot if $game_switches[Yuki::Sw::WRP_Transition] && $scene.class == Scene_Map && from_warp
    return nil if from_warp
    @tilemap.dispose
    @panorama.dispose
    @fog.dispose
    @character_sprites.each(&:dispose)
    @game_player_sprite = nil
    @weather.dispose
    @picture_sprites.each(&:dispose)
    @timer_sprite.dispose
    @quest_informers.clear
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
    dispose_sp_map if @sp_bg
    return nil
  end

  # Update every sprite
  def update
    update_panorama_fog
    @tilemap.ox = $game_map.display_x / 4
    @tilemap.oy = $game_map.display_y / 4
    @tilemap.update
    Yuki::FollowMe.update
    update_events
    update_weather_picture
    @timer_sprite.update
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    @viewport3.color = $game_screen.flash_color
    @viewport1.update
    @viewport3.update
    update_panel
    update_quest_informer
    @viewport1.sort_z unless Graphics.skipping_frame?
  end

  # update event sprite
  def update_events
    @character_sprites.each(&:update)
    $game_map.event_erased = false if $game_map.event_erased
  end

  # update weather and picture sprites
  def update_weather_picture
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    @picture_sprites.each(&:update)
  end

  # update panorama and fog sprites
  def update_panorama_fog
    if @panorama_name != $game_map.panorama_name # or @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      unless @panorama.bitmap.nil?
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue) unless @panorama_name.empty? # if @panorama_name != ""
      Graphics.frame_reset
    end

    if @fog_name != $game_map.fog_name # or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      unless @fog.bitmap.nil?
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue) unless @fog_name.empty? # if @fog_name != ""
      Graphics.frame_reset
    end

    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8

    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity.to_i
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = ($game_map.display_x / 8 + $game_map.fog_ox) / 2
    @fog.oy = ($game_map.display_y / 8 + $game_map.fog_oy) / 2
    @fog.tone = $game_map.fog_tone
  end

  # create the zone panel of the current zone
  # @param zone [Integer, nil] the id of the zone where the player is
  def create_panel(zone)
    return unless zone && GameData::Zone.get(zone).panel_id > 0
    @sp_bg ||= Sprite.new
    @sp_bg.x = 2
    @sp_bg.y = -30
    @sp_bg.z = 5001
    @sp_bg.bitmap = bmp = RPG::Cache.windowskin("Pannel_#{GameData::Zone.get(zone).panel_id}")
    map_name = PFM::Text.parse_string_for_messages(GameData::Zone.get(zone).map_name)
    color = 10
    map_name.gsub!(/\\c\[([0-9]+)\]/) do
      color = $1.to_i
      nil
    end
    @sp_fg = Text.new(0, nil, 2, -30 - 4, bmp.width, bmp.height, map_name, 1,
                      Text::Util::DEFAULT_OUTLINE_SIZE, color)
    @sp_fg.z = 5002
    @counter = 0
  end

  # Dispose the zone panel
  def dispose_sp_map
    @sp_bg.dispose
    @sp_bg = nil
    @sp_fg.dispose
    @sp_fg = nil
  end

  # Update the zone panel
  def update_panel
    return unless @sp_bg
    @counter += 1
    if @counter < 32
      @sp_bg.y += 1
      @sp_fg.y += 1
    elsif @counter == 154
      dispose_sp_map
    elsif @counter > 122
      @sp_bg.y -= 1
      @sp_fg.y -= 1
    end
  end

  # Change the visible state of the Spriteset
  # @param value [Boolean] the new visibility state
  def visible=(value)
    @sp_bg&.visible = value
    @sp_fg&.visible = value
    @viewport1.visible = value
    @viewport2.visible = value
    @viewport3.visible = value
  end

  # Return the map viewport
  # @return [LiteRGSS::Viewport]
  def map_viewport
    return @viewport1
  end

  # Add a new quest informer
  # @param name [String] Name of the quest
  # @param is_new [Boolean] if the quest is new
  def inform_quest(name, is_new)
    @quest_informers << UI::QuestInformer.new(@viewport2, name, is_new, @quest_informers.size)
  end

  private

  # Take a snapshot of the map
  # @return [Sprite] the snapshot ready to be used
  def take_map_snapshot
    sp = Sprite.new(@viewport3)
    sp.z = 10**6
    sp.bitmap = Graphics.snap_to_bitmap
    sp.x = Graphics.width / 2
    sp.ox = sp.bitmap.width / 2
    sp.y = Graphics.height / 2
    sp.oy = sp.bitmap.height / 2
    sp.zoom = 1.0 / Config::ScreenScale if Config.const_defined?(:ScreenScale)
    return sp
  end

  # Update the quest informer
  def update_quest_informer
    @quest_informers.each do |informer|
      informer.update
      informer.dispose if informer.done?
    end
    @quest_informers.clear if @quest_informers.all?(&:done?)
  end
end
