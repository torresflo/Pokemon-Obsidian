#encoding: utf-8

# Class that manage Music playing, save and menu access, timer and interpreter
class Game_System
  attr_reader   :map_interpreter          # マップイベント用インタプリタ
  attr_reader   :battle_interpreter       # バトルイベント用インタプリタ
  attr_accessor :timer                    # タイマー
  attr_accessor :timer_working            # タイマー作動中フラグ
  attr_accessor :save_disabled            # セーブ禁止
  attr_accessor :menu_disabled            # メニュー禁止
  attr_accessor :encounter_disabled       # エンカウント禁止
  attr_accessor :message_position         # 文章オプション 表示位置
  attr_accessor :message_frame            # 文章オプション ウィンドウ枠
  attr_accessor :save_count               # セーブ回数
  attr_accessor :magic_number             # マジックナンバー
  # Default initializer
  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
  end
  # play the cry of a Pokémon
  # @param id [Integer] the id of the Pokémon in the database
  def cry_play(id)
    Audio.cry_play(sprintf("Audio/SE/Cries/%03dCry", id.to_i))
  end
  # Plays a BGM
  # @param bgm [RPG::AudioFile] a descriptor of the BGM
  def bgm_play(bgm)
    @playing_bgm = bgm
    if bgm and !bgm.name.empty?
      Audio.bgm_play(_utf8("Audio/BGM/" + bgm.name), bgm.volume, bgm.pitch)
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end
  # Stop the BGM
  def bgm_stop
    Audio.bgm_stop
  end
  # Fade the BGM out
  # @param time [Integer] the time in seconds it takes to the BGM to fade
  def bgm_fade(time)
    @playing_bgm = nil
    Audio.bgm_fade(time * 1000)
  end
  # Memorize the BGM
  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end
  # Plays the Memorized BGM
  def bgm_restore
    bgm_play(@memorized_bgm)
  end
  # Memorize an other BGM with position
  # @author Nuri Yuri
  def bgm_memorize2
    @bgm_position = Audio.bgm_position
    @memorized_bgm2 = @playing_bgm
  end
  # Plays the other Memorized BGM at the right position (FmodEx Eclusive)
  # @author Nuri Yuri
  def bgm_restore2
    bgm_play(@memorized_bgm2)
    if @bgm_position
      Audio.bgm_position = @bgm_position
    end
  end
  # Plays a BGS
  # @param bgs [RPG::AudioFile] a descriptor of the BGS
  def bgs_play(bgs)
    @playing_bgs = bgs
    if bgs and !bgs.name.empty?
      Audio.bgs_play(_utf8("Audio/BGS/" + bgs.name), bgs.volume, bgs.pitch)
    else
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end
  # Fade the BGS out
  # @param time [Integer] the time in seconds it takes to the BGS to fade
  def bgs_fade(time)
    @playing_bgs = nil
    Audio.bgs_fade(time * 1000)
  end
  # Memorize the BGS
  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end
  # Play the memorized BGS
  def bgs_restore
    bgs_play(@memorized_bgs)
  end
  # Plays a ME
  # @param me [RPG::AudioFile] a descriptor of the ME
  def me_play(me)
    if me and !me.name.empty?
      Audio.me_play(_utf8("Audio/ME/" + me.name), me.volume, me.pitch)
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end
  # Plays a SE
  # @param se [RPG::AudioFile] a descriptor of the SE
  def se_play(se)
    if se and !se.name.empty?
      Audio.se_play(_utf8("Audio/SE/" + se.name), se.volume, se.pitch)
    end
  end
  # Stops every SE
  def se_stop
    Audio.se_stop
  end
  # Returns the playing BGM descriptor
  # @return [RPG::AudioFile]
  def playing_bgm
    return @playing_bgm
  end
  # Returns the playing BGS descriptor
  # @return [RPG::AudioFile]
  def playing_bgs
    return @playing_bgs
  end
  # Returns the name of the window skin
  # @return [String] The name of the window skin
  def windowskin_name
    return @windowskin_name || 'message'
  end
  # Sets the name of the window skin
  # @param windowskin_name [String] The name of the window skin
  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end
  # Returns the battle BGM descriptor
  # @return [RPG::AudioFile]
  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end
  # Sets the battle BGM descriptor
  # @param battle_bgm [RPG::AudioFile] descriptor
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  # Returns the battle end ME descriptor
  # @return [RPG::AudioFile]
  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end
  # Sets the battle end ME descriptor
  # @param battle_end_me [RPG::AudioFile] descriptor
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  # Updates the Game System (timer)
  def update
    # タイマーを 1 減らす
    if @timer_working and @timer > 0
      @timer -= 1
    end
  end
end

