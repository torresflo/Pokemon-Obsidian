module GamePlay
  class Hall_of_Fame < BaseCleanUpdate
    # The default BGM to play
    DEFAULT_BGM = 'audio/bgm/Hall-of-Fame'
    # Initialize the scene
    # @param filename_bgm [String] the bgm to play during the Hall of Fame
    # @param context_of_victory [Symbol] the symbol to put as the context of victory
    def initialize(filename_bgm = DEFAULT_BGM, context_of_victory = :league)
      super()
      @filename_bgm = filename_bgm
      @anim_count = 0
      @animation_state = 0
      @graveyard = PFM.game_state.nuzlocke.graveyard
      @nuz_anim = Graveyard_Animation_Stack
      @pkm_sprite_anim = Pokemon_Battler_Stack
      @parallel_update = false
      PFM.game_state.hall_of_fame.register_victory(context_of_victory)
      play_music
      # Do something
    end

    # Play the music, nothing else
    def play_music
      Audio.bgm_play(@filename_bgm) unless @filename_bgm.empty?
    end

    # Get the cry's filename of the Pokemon at index equal to @anim_count
    # @return [String] the filename of the cry
    def pkm_cry_filename
      str = $actors[@anim_count].cry.sub('Audio/SE/', '')
      return str
    end
  end
end

GamePlay.hall_of_fame_class = GamePlay::Hall_of_Fame
