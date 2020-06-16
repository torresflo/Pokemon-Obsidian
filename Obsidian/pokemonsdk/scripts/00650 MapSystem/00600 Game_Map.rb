# Describe the Map processing
class Game_Map

  # The list of ability that decrease the encounter frequency
  ENC_FREQ_DEC = %i[white_smoke quick_feet stench]
  # The list of ability that increase the encounter frequency
  ENC_FREQ_INC = %i[no_guard illuminate arena_trap]
  # Ability that decrese the encounter during hail weather
  ENC_FREQ_DEC_HAIL = [:snow_cloak]
  # Ability that decrese the encounter during sandstorm weather
  ENC_FREQ_DEC_SANDSTORM = [:sand_veil]
  # Audiofile to play when the player is on mach bike
  # @return [RPG::AudioFile]
  MACH_BIKE_BGM = RPG::AudioFile.new('09 Bicycle', 100, 100)
  # Audiofile to play when the player is on acro bike
  # @return [RPG::AudioFile]
  ACRO_BIKE_BGM = MACH_BIKE_BGM.clone
  # If the Path Finding system is enabled
  PATH_FINDING_ENABLED = true
  # If the player is always on the center of the screen
  CenterPlayer = PSDK_CONFIG.player_always_centered
  # Number of tiles the player can see in x
  NUM_TILE_VIEW_Y = 15
  # Number of tiles the player can see in y
  NUM_TILE_VIEW_X = 20
  attr_accessor :tileset_name             # タイルセット ファイル名
  attr_accessor :autotile_names           # オートタイル ファイル名
  attr_accessor :panorama_name            # パノラマ ファイル名
  attr_accessor :panorama_hue             # パノラマ 色相
  attr_accessor :fog_name                 # フォグ ファイル名
  attr_accessor :fog_hue                  # フォグ 色相
  attr_accessor :fog_opacity              # フォグ 不透明度
  attr_accessor :fog_blend_type           # フォグ ブレンド方法
  attr_accessor :fog_zoom                 # フォグ 拡大率
  attr_accessor :fog_sx                   # フォグ SX
  attr_accessor :fog_sy                   # フォグ SY
  attr_accessor :battleback_name          # バトルバック ファイル名
  attr_accessor :display_x                # 表示 X 座標 * 128
  attr_accessor :display_y                # 表示 Y 座標 * 128
  attr_accessor :need_refresh             # リフレッシュ要求フラグ
  attr_reader   :passages                 # 通行 テーブル
  attr_reader   :priorities               # プライオリティ テーブル
  attr_reader   :terrain_tags             # 地形タグ テーブル
  # @return [Hash{Integer => Game_Event}] all the living events
  attr_reader   :events
  # Return the hash of symbol associate to event id
  # @return [Hash<Symbol, Integer>]
  attr_accessor :events_sym_to_id
  attr_reader   :fog_ox                   # フォグ 原点 X 座標
  attr_reader   :fog_oy                   # フォグ 原点 Y 座標
  attr_reader   :fog_tone                 # フォグ 色調
  # @return [Boolean] if the maplinker was disabled when the map was setup
  attr_reader :maplinker_disabled
  # Initialize the default Game_Map object
  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
    @maplinker_disabled = false
  end

  # setup the Game_Map object with the right Map data
  # @param map_id [Integer] the ID of the map
  def setup(map_id)
    Yuki::ElapsedTime.start(:map_loading)
    @map_id = map_id
    # We save events to make sure they'll be correctly transfered on the with the MapLinker
    save_events_offset unless @events_info
    # We store the new state of the map linker enable state
    @maplinker_disabled = $game_switches[Yuki::Sw::MapLinkerDisabled]
    # マップをファイルからロードし、@map に設定
    @map = Yuki::MapLinker.load_map(@map_id)
    Yuki::ElapsedTime.show(:map_loading, 'MapLinker.load_map took')
    # 公開インスタンス変数にタイルセットの情報を設定
    load_systemtags
    tileset = $data_tilesets[@map.tileset_id]
    # -- Scheduler.start(:on_getting_tileset_name)
    @tileset_name = Yuki::MapLinker.tileset_name # -- get_tileset_name($game_temp.tileset_name || tileset.tileset_name)
    # -- $game_temp.tileset_name = nil
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    # Force the first tile to be properly configured
    @passages[0] = 0
    @priorities[0] = 5
    @terrain_tags = tileset.terrain_tags
    # 表示座標を初期化
    @display_x = 0
    @display_y = 0
    # リフレッシュ要求フラグをクリア
    @need_refresh = false
    # マップイベントのデータを設定
    env = $env
    @events = {}
    @events_sym_to_id = { player: -1 }
    @map.events.each do |i, event|
      next if env.get_event_delete_state(i)

      event.name.force_encoding(Encoding::UTF_8) # £EncodingPatch
      e = @events[i] = Game_Event.new(@map_id, event)
      if e.sym_alias
        log_error("Alias #{e.sym_alias} appear multiple time in the map #{@map_id}.\n\tPlease use uniq aliases.") if @events_sym_to_id.key?(e.sym_alias)
        @events_sym_to_id[e.sym_alias] = i
      end
    end
    load_events
    Yuki::ElapsedTime.show(:map_loading, 'Loading events took')
    # コモンイベントのデータを設定
    @common_events = {}
    1.upto($data_common_events.size - 1) do |i|
      @common_events[i] = Game_CommonEvent.new(i)
    end
    Yuki::ElapsedTime.show(:map_loading, 'Loading common events took')
    # フォグの各情報を初期化
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # スクロール情報を初期化
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    load_follower if @next_setup_followers
  end

  # Returns the ID of the Map
  # @return [Integer]
  def map_id
    return @map_id
  end

  # Returns the width of the map
  # @return [Integer]
  def width
    return @map.width
  end

  # Returns the height of the map
  # @return [Integer]
  def height
    return @map.height
  end

  # Returns the encounter list
  # @deprecated Not used by the Core of PSDK because not precise enough to be used
  def encounter_list
    return @map.encounter_list
  end

  # Returns the encounter steps from RMXP data
  # @return [Integer]
  def rmxp_encounter_steps
    @map.encounter_step
  end

  # Returns the encounter step of the map (including ability modifier)
  # @return [Integer] number of step the player must do before each encounter
  def encounter_step
    return rmxp_encounter_steps unless $actors

    ability = $actors[0]&.ability_db_symbol || :__undef__ # the first pokemon in the party's ability

    # if the ability matches the encounter increasing ability the encounter rate is doubled
    return rmxp_encounter_steps / 2 if ENC_FREQ_INC.include?(ability)

    # if the ability matches the encounter lowering ability the encounter rate is halved
    if ENC_FREQ_DEC.include?(ability) ||
       (ENC_FREQ_DEC_HAIL.include?(ability) && $env.hail?) ||
       (ENC_FREQ_DEC_SANDSTORM.include?(ability) && $env.sandstorm?)
      return rmxp_encounter_steps * 2
    end

    return rmxp_encounter_steps # else the normal encounter rate is returned
  end

  # Returns the tile matrix of the Map
  # @return [Table] a 3D table containing ids of tile
  def data
    return @map.data
  end

  # Auto play bgm and bgs of the map if defined
  def autoplay
    $game_system.bgm_play(current_bgm) if autoplay_bgm?
    $game_system.bgs_play(current_bgs) if autoplay_bgs?
  end

  # Refresh events and common events of the map
  def refresh
    # マップ ID が有効なら
    if @map_id > 0
      # すべてのマップイベントをリフレッシュ
      @events.each_value(&:refresh)
      # すべてのコモンイベントをリフレッシュ
      @common_events.each_value(&:refresh)
    end
    # リフレッシュ要求フラグをクリア
    @need_refresh = false
  end

  # Scrolls the map down
  # @param distance [Integer] distance in y to scroll
  # @param is_priority [Boolean] used if there is a prioratary scroll running
  def scroll_down(distance, is_priority = false)
    return if @scroll_y_priority && !is_priority

    if @maplinker_disabled
      @display_y = (@display_y + distance).clamp(0, (height - NUM_TILE_VIEW_Y) * 128)
    else
      @display_y += distance
    end
  end

  # Scrolls the map left
  # @param distance [Integer] distance in -x to scroll
  # @param is_priority [Boolean] used if there is a prioratary scroll running
  def scroll_left(distance, is_priority = false)
    return if @scroll_x_priority && !is_priority

    if @maplinker_disabled
      @display_x = (@display_x - distance).clamp(0, @display_x)
    else
      @display_x -= distance
    end
  end

  # Scrolls the map right
  # @param distance [Integer] distance in x to scroll
  # @param is_priority [Boolean] used if there is a prioratary scroll running
  def scroll_right(distance, is_priority = false)
    return if @scroll_x_priority && !is_priority

    if @maplinker_disabled
      @display_x = (@display_x + distance).clamp(0, (width - NUM_TILE_VIEW_X) * 128)
    else
      @display_x += distance
    end
  end

  # Scrolls the map up
  # @param distance [Integer] distance in -y to scroll
  # @param is_priority [Boolean] used if there is a prioratary scroll running
  def scroll_up(distance, is_priority = false)
    return if @scroll_y_priority && !is_priority

    if @maplinker_disabled
      @display_y = (@display_y - distance).clamp(0, @display_y)
    else
      @display_y -= distance
    end
  end

  # Tells if the x,y coordinate is valid or not (inside of bounds)
  # @param x [Integer] the x coordinate
  # @param y [Integer] the y coordinate
  # @return [Boolean] if it's valid or not
  def valid?(x, y)
    return ((x >= 0) && (x < width) && (y >= 0) && (y < height))
  end

  # Tells if the tile front/current tile is passsable or not
  # @param x [Integer] x position on the Map
  # @param y [Integer] y position on the Map
  # @param d [Integer] direction : 2, 4, 6, 8, 0. 0 = current position
  # @param self_event [Game_Event, nil] the "tile" event to ignore
  # @return [Boolean] if the front/current tile is passable
  def passable?(x, y, d, self_event = nil)
    # 与えられた座標がマップ外の場合
    unless valid?(x, y)
      # 通行不可
      return false
    end

    # 方向 (0,2,4,6,8,10) から 障害物ビット (0,1,2,4,8,0) に変換
    bit = (1 << (d / 2 - 1)) & 0x0f
    # すべてのイベントでループ
    events.each_value do |event|
      # 自分以外のタイルと座標が一致した場合
      if (event.tile_id >= 0) && (event != self_event) &&
         (event.x == x) && (event.y == y) && !event.through
        # 障害物ビットがセットされている場合
        if @passages[event.tile_id] & bit != 0
          # 通行不可
          return false
        # 全方向の障害物ビットがセットされている場合
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          # 通行不可
          return false
        # それ以外で プライオリティが 0 の場合
        elsif @priorities[event.tile_id] == 0
          # 通行可
          return true
        end
      end
    end
    # レイヤーの上から順に調べるループ
    2.downto(0) do |i|
      # タイル ID を取得
      tile_id = data[x, y, i]
      # タイル ID 取得失敗
      if tile_id.nil?
        # 通行不可
        return false
      # 障害物ビットがセットされている場合
      elsif @passages[tile_id] & bit != 0
        # 通行不可
        return false
      # 全方向の障害物ビットがセットされている場合
      elsif @passages[tile_id] & 0x0f == 0x0f
        # 通行不可
        return false
      # それ以外で プライオリティが 0 の場合
      elsif @priorities[tile_id] == 0
        # 通行可
        return true
      end
    end
    # 通行可
    return true
  end

  # Tells if the tile is a bush tile
  # @param x [Integer] x coordinate of the tile
  # @param y [Integer] y coordinate of the tile
  # @return [Boolean]
  def bush?(x, y)
    if @map_id != 0
      2.downto(0) do |i|
        tile_id = data[x, y, i]
        if tile_id.nil?
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end

  # カウンター判定 (no idea, need GTranslate)
  # @param x [Integer] x coordinate of the tile
  # @param y [Integer] y coordinate of the tile
  # @return [Boolean]
  def counter?(x, y)
    if @map_id != 0
      2.downto(0) do |i|
        tile_id = data[x, y, i]
        if tile_id.nil?
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end

  # Returns the tag of the tile
  # @param x [Integer] x coordinate of the tile
  # @param y [Integer] y coordinate of the tile
  # @return [Integer, nil] Tag of the tile
  def terrain_tag(x, y)
    if @map_id != 0
      2.downto(0) do |i|
        tile_id = data[x, y, i]
        if tile_id.nil?
          return 0
        elsif @terrain_tags[tile_id] && (@terrain_tags[tile_id] > 0)
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end

  # Starts a scroll processing
  # @param direction [Integer] the direction to scroll
  # @param distance [Integer] the distance to scroll
  # @param speed [Integer] the speed of the scroll processing
  # @param x_priority [Boolean] true if the scroll is prioritary in x axis, be careful using this
  # @param y_priority [Boolean] true if the scroll is prioritary in y axis, be careful using this
  def start_scroll(direction, distance, speed, x_priority = false, y_priority = false)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
    @scroll_x_priority = x_priority
    @scroll_y_priority = y_priority
  end

  # is the map scrolling ?
  # @return [Boolean]
  def scrolling?
    return @scroll_rest > 0
  end

  # Starts a fog tone change process
  # @param tone [Tone] the new tone of the fog
  # @param duration [Integer] the number of frame the tone change will take
  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    @fog_tone = @fog_tone_target.clone if @fog_tone_duration == 0
  end

  # Starts a fog opacity change process
  # @param opacity [Integer] the new opacity of the fog
  # @param duration [Integer] the number of frame the opacity change will take
  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    @fog_opacity = @fog_opacity_target if @fog_opacity_duration == 0
  end

  # Update the Map processing
  def update
    Pathfinding.update if PATH_FINDING_ENABLED
    # 必要ならマップをリフレッシュ
    refresh if $game_map.need_refresh
    # スクロール中の場合
    if @scroll_rest > 0
      # スクロール速度からマップ座標系での距離に変換
      distance = 2**@scroll_speed
      # スクロールを実行
      case @scroll_direction
      when 2  # 下
        scroll_down(distance, @scroll_y_priority)
      when 4  # 左
        scroll_left(distance, @scroll_x_priority)
      when 6  # 右
        scroll_right(distance, @scroll_x_priority)
      when 8  # 上
        scroll_up(distance, @scroll_y_priority)
      end
      # スクロールした距離を減算
      @scroll_rest -= distance
      @scroll_y_priority = @scroll_x_priority = nil unless scrolling?
    end
    # >Partie édition des SystemTag
    #    return if Yuki::SystemTag.running?
    # マップイベントを更新
    @events.each_value(&:update)
    # コモンイベントを更新
    @common_events.each_value(&:update)
    #    t2=Time.new
    #    p t2-t1 if Input.trigger?(Input::F6)
    # フォグのスクロール処理
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # フォグの色調変更処理
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # フォグの不透明度変更処理
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end

  private

  # Return the current Autoplay BGM state
  # @return [Boolean]
  def autoplay_bgm?
    @map.autoplay_bgm || $game_player.cycling?
  end

  # Return the current Autoplay BGS state
  # @return [Boolean]
  def autoplay_bgs?
    @map.autoplay_bgs
  end

  # Return the current BGM to play
  # @return [RPG::AudioFile]
  def current_bgm
    cycling_bgm || @map.bgm
  end

  # Return the current BGS to play
  # @return [RPG::AudioFile]
  def current_bgs
    @map.bgs
  end

  # Get the cycle audio file matching the current bike or nil
  # @return [RPG::AudioFile, nil]
  def cycling_bgm
    return nil unless $game_player.cycling?
    return ACRO_BIKE_BGM if $game_player.on_acro_bike

    return MACH_BIKE_BGM
  end
end
