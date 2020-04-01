class Game_Map
  # If an event has been erased (helps removing it)
  # @return [Boolean]
  attr_accessor :event_erased

  # Retrieve the ID of the SystemTag on a specific tile
  # @param x [Integer] x position of the tile
  # @param y [Integer] y position of the tile
  # @return [Integer]
  # @author Nuri Yuri
  def system_tag(x, y)
    if @map_id != 0
      tiles = self.data
      2.downto(0) do |i|
        tile_id = tiles[x, y, i]
        return 0 unless tile_id
        tag_id = @system_tags[tile_id]
        return tag_id if tag_id and tag_id > 0
      end
    end
    return 0
  end

  # Check if a specific SystemTag is present on a specific tile
  # @param x [Integer] x position of the tile
  # @param y [Integer] y position of the tile
  # @param tag [Integer] ID of the SystemTag
  # @return [Boolean]
  # @author Nuri Yuri
  def system_tag_here?(x, y, tag)
    if @map_id != 0
      tiles = self.data
      2.downto(0) do |i|
        tile_id = tiles[x, y, i]
        next unless tile_id
        return true if @system_tags[tile_id] == tag
      end
    end
    return false
  end

  # Loads the SystemTags of the map
  # @author Nuri Yuri
  def load_systemtags
    @system_tags = $data_system_tags[@map.tileset_id]
    unless @system_tags
      print "Les tags du tileset #{@map.tileset_id} n'existent pas. 
PSDK va entrer en configuration des SystemTags merci de les sauvegarder"
      Yuki::SystemTagEditor.start
      @system_tags = $data_system_tags[@map.tileset_id]
    end
  end

  # Retrieve the id of a specific tile
  # @param x [Integer] x position of the tile
  # @param y [Integer] y position of the tile
  # @return [Integer] id of the tile
  # @author Nuri Yuri
  def get_tile(x, y)
    2.downto(0) do |i|
      tile = data[x, y, i]
      return tile if tile and tile > 0
    end
    return 0
  end

  # Check if the player can jump a case with the acro bike
  # @param x [Integer] x position of the tile
  # @param y [Integer] y position of the tile
  # @param d [Integer] the direction of the player
  # @return [Boolean]
  # @author Nuri Yuri
  def jump_passable?(x, y, d)
    z = $game_player.z
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    sys_tag = system_tag(new_x, new_y)
    systemtags = GameData::SystemTags
    if z <= 1 and (system_tag(x, y) == systemtags::AcroBike or sys_tag == systemtags::AcroBike)
      return true
    elsif z > 1 and (Game_Player::AccroTag.include?(sys_tag) or sys_tag == systemtags::BridgeUD)
      return true
    end
    case d
    when 2
      new_d = 8
    when 6
      new_d = 4
    when 4
      new_d = 6
    else
      new_d = 2
    end
    # 与えられた座標がマップ外の場合
    unless valid?(x, y) and valid?(new_x, new_y)
      # 通行不可
      return false
    end
    # 方向 (0,2,4,6,8,10) から 障害物ビット (0,1,2,4,8,0) に変換
    bit = (1 << (d / 2 - 1)) & 0x0f
    bit2 = (1 << (new_d / 2 - 1)) & 0x0f
    # レイヤーの上から順に調べるループ
    2.downto(0) do |i|
      # タイル ID を取得
      tile_id = data[x, y, i]
      tile_id2 = data[new_x, new_y, i]
      if @passages[tile_id] & bit != 0 or @passages[tile_id2] & bit2 != 0
        # 通行不可
        return false
      elsif @priorities[tile_id] == 0
        # 通行可
        return true
      end
    end
    # 通行可
    return true
  end

  # List of variable to remove in order to keep the map data safe
  IVAR_TO_REMOVE_FROM_SAVE_FILE = %i[@map @tileset_name @autotile_names @panorama_name @panorama_hue @fog_name @fog_hue @fog_opacity @fog_blend_type @fog_zoom @fog_sx @fog_sy @battleback_name @passages @priorities @terrain_tags @events @common_events @system_tags]

  # Method that prevent non wanted data save of the Game_Map object
  # @author Nuri Yuri
  def begin_save
    Pathfinding.save
    save_follower
    save_events
    arr = []
    IVAR_TO_REMOVE_FROM_SAVE_FILE.each do |ivar_name|
      arr << instance_variable_get(ivar_name)
      remove_instance_variable(ivar_name)
    end
    arr << $game_player.follower
    $game_player.instance_variable_set(:@follower, nil)
    $TMP_MAP_DATA = arr
  end

  # Method that end the save state of the Game_Map object
  # @author Nuri Yuri
  def end_save
    arr = $TMP_MAP_DATA
    IVAR_TO_REMOVE_FROM_SAVE_FILE.each_with_index do |ivar_name, index|
      instance_variable_set(ivar_name, arr[index])
    end
    $game_player.instance_variable_set(:@follower, arr.last)
    @events_info = nil
  end

  private

  # Method that save the Follower Event of the player
  def save_follower
    return unless $game_player.follower.is_a?(Game_Event)
    @next_setup_followers = []
    follower = $game_player
    while (follower = follower.follower).is_a?(Game_Event)
      @next_setup_followers << follower.id
    end
  end

  # Method that load the follower Event of the player when the map is loaded
  def load_follower
    $game_player.reset_follower
    x = $game_player.x
    y = $game_player.y
    @next_setup_followers.each do |id|
      next unless (event = @events[id])
      event.moveto(x, y)
      $game_player.set_follower(event)
    end
    remove_instance_variable(:@next_setup_followers)
  end

  # Method that save the event position, direction & move_route info
  def save_events
    return unless @events
    @events_info = {}
    @events.each_value do |event|
      next if event.original_map != @map_id
      index = event.instance_variable_get(:@move_route_index)
      @events_info[event.original_id] = [event.x, event.y, event.z, event.direction, index, event.__bridge]
    end
    @events_info[:player] = $game_player.z
  end

  # Method that save the events & fix the event offset added by the MapLinker
  def save_events_offset
    return unless @events
    @events_info = {}
    ml_ox = Yuki::MapLinker.current_OffsetX
    ml_oy = Yuki::MapLinker.current_OffsetY
    @events.each_value do |event|
      next if event.original_map != @map_id
      # @type [RPG::Event]
      event_data = event.event
      index = event.instance_variable_get(:@move_route_index)
      x = event.x - event_data.offset_x.to_i + ml_ox
      y = event.y - event_data.offset_y.to_i + ml_oy
      @events_info[event.original_id] = [x, y, event.z, event.direction, index, event.__bridge]
    end
    @events_info[:player] = $game_player.z
  end

  # Method that load the event
  def load_events
    return unless @events_info
    $game_player.z = @events_info[:player]
    @events_info.each do |id, info|
      next unless (event = @events[id])
      next unless event.original_map == @map_id
      event.moveto(info[0], info[1])
      event.z = info[2]
      event.direction = info[3]
      event.instance_variable_set(:@move_route_index, info[4])
      event.__bridge = info[5]
      event.clear_starting
      event.check_event_trigger_auto
    end
    $game_player.check_event_trigger_here([1, 2])
    @events_info = nil
  end
end
