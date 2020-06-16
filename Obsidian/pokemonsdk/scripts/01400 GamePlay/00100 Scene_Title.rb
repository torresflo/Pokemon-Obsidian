# The title screen scene
class Scene_Title
  # @return [Integer] ID of the map to display as intro movie (0 = no intro)
  INTRO_MOVIE_MAP_ID = 0
  # @return [Integer] lenght of the Title BGM
  TITLE_BGM_LENGTH = 4_418_000
  # @return [String] name of the Title BGM
  TITLE_BGM_NAME = 'audio/bgm/rosa_title'
  # @return [Boolean] if the title screen use random font
  RANDOM_TITLE_FONT = true
  # Entry point of the scene. If player hit X + B + UP the GamePlay::Load scene will ask the save deletion.
  def main
    data_load
    title_animation unless debug? && (ARGV.include?('skip_title') || PSDK_CONFIG.skip_title_in_debug)
    if $scene == self
      Yuki::MapLinker.reset
      GamePlay::Load.new(#> Suppression de sauvegarde : X+B+Haut
        Input.press?(:X) &
        Input.press?(:B) &
        Input.press?(:UP)).main
    end
  end

  # Show the title animation
  def title_animation
    @loop = true
    while @loop and $scene == self
      init_sprites
      play_splash
      init_title
      play_title
      dispose_sprites
    end
    RPG::Cache.load_title(true)
    GC.start
  end

  # Init the title screen sprites
  def init_sprites
    @viewport = Viewport.create(:main, 100)
    #@viewport.tone.set(-255, -255, -255, 0)
    @viewport.color.set(0, 0, 0, 255)
    @main_sprite = Sprite.new(@viewport)
    @main_sprite.z = 0
    @start_sprite = Sprite.new(@viewport)
    @start_sprite.z = 1
    @main_sprite.bitmap = RPG::Cache.title("splash")
  end

  # Dispose the title screen sprites
  def dispose_sprites
    Graphics.freeze
    @main_sprite.dispose
    @start_sprite.dispose
    @viewport.dispose
    @main_sprite = @start_sprite = @viewport = nil
  end

  # Init the title display part
  def init_title
    Graphics.freeze
    @viewport.color.alpha = 0
    #@viewport.tone.set(0,0,0,0)
    @fnt = RANDOM_TITLE_FONT ? rand(3) : 0
    @main_sprite.bitmap = RPG::Cache.title("fond_#@fnt")
    lang = (GamePlay::Save.load&.options&.language || 'en')
    lang = 'en' unless RPG::Cache.title_exist?("start#{lang}")
    @start_sprite.bitmap = RPG::Cache.title("start#{lang}")
    @start_sprite.visible = false
    @counter = 0
    Graphics.transition
  end

  # Play the splash part
  def play_splash
    Graphics.transition
    count = 60
    down_col = - 255 / count * 2
    Audio.se_play("Audio/SE/Nintendo")
    (count * 2).times do |i|
      down_col  *= -1 if i == count
      @viewport.color.alpha += down_col
      Graphics.update
    end
    start_intro_movie(INTRO_MOVIE_MAP_ID) unless INTRO_MOVIE_MAP_ID == 0
  end

  # Play the title display part
  def play_title
    Audio.bgm_play(TITLE_BGM_NAME)
    until Input.trigger?(:A) or Input.trigger?(:X) or Mouse.trigger?(:left)
      if(@counter += 1) == 45
        @start_sprite.visible = !@start_sprite.visible
        @counter = 0
      end
      Graphics.update
      if Audio.bgm_position > TITLE_BGM_LENGTH or $scene != self
        Audio.bgm_stop
        return
      end
    end
    $game_system.se_play($data_system.decision_se)
    @loop = false
    Audio.bgm_stop
  end

  # Show the intro movie map
  # @param map_id [Integer] ID of the map
  def start_intro_movie(map_id)
    Graphics.freeze
    @viewport.visible = false
    $tester = true # No new GameMap hack
    $pokemon_party = PFM::Pokemon_Party.new(false, GamePlay::Load::DEFAULT_GAME_LANGUAGE)
    $tester = nil
    Yuki::MapLinker.reset
    $pokemon_party.expand_global_var
    $game_party.setup_starting_members
    $game_map.setup(map_id)
    $game_player.moveto(Yuki::MapLinker.get_OffsetX, Yuki::MapLinker.get_OffsetY)
    $game_player.refresh
    $game_map.autoplay
    scene = $scene
    $scene = Scene_Map.new
    $scene.main
    $scene = scene
    GamePlay::Save.load
    @viewport.visible = true
  end

  # Load the RMXP Data
  def data_load
    unless $data_actors
      $data_actors        = _clean_name_utf8(load_data("Data/Actors.rxdata"))
      $data_classes       = _clean_name_utf8(load_data("Data/Classes.rxdata"))
      #$data_skills        = load_data("Data/Skills.rxdata")
      #$data_items         = load_data("Data/Items.rxdata")
      #$data_weapons       = load_data("Data/Weapons.rxdata")
      #$data_armors        = load_data("Data/Armors.rxdata")
      $data_enemies       = _clean_name_utf8(load_data("Data/Enemies.rxdata"))
      $data_troops        = _clean_name_utf8(load_data("Data/Troops.rxdata"))
      #$data_states        = load_data("Data/States.rxdata")
      #$data_animations    = load_data("Data/Animations.rxdata")
      $data_tilesets      = _clean_name_utf8(load_data("Data/Tilesets.rxdata"))
      $data_common_events = _clean_name_utf8(load_data("Data/CommonEvents.rxdata"))
      # @type [RPG::System]
      $data_system        = load_data_utf8("Data/System.rxdata")
    end
    # @type [GameSystem]
    $game_system = Game_System.new
    # @type [GameTemp]
    $game_temp = Game_Temp.new
  end
end
