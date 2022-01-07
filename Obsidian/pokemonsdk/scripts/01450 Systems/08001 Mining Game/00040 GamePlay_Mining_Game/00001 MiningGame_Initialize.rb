module GamePlay
  # Class that describes the functionment of the scene
  class MiningGame < BaseCleanUpdate::FrameBalanced
    # Constant that stock the Database of the Mining Game
    DATA = GameData::MiningGame::DATA_ITEM
    # The base music of the scene
    DEFAULT_MUSIC = 'audio/bgm/mining_game'
    # The number of tiles per lines in the table
    NB_X_TILES = 16
    # The number of tiles per columns in the table
    NB_Y_TILES = 13
    # IDs of the text displayed when playing for the first time
    FIRST_TIME_TEXT = [[9005, 6], [9005, 7], [9005, 8], [9005, 10], [9005, 11], [9005, 12]]
    # IDs of the text displayed when playing for the first time (dynamite mode)
    FIRST_TIME_TEXT_ALTERNATIVE = [9005, 9]
    # List of the usable tools
    TOOLS = %i[pickaxe mace dynamite]
    # Pathname of the SE folder
    SE_PATH = 'audio/se/mining_game'
    # @return [UI::MiningGame::Tiles_Stack]
    attr_accessor :tiles_stack
    # @return [Array<PFM::MiningGame::Diggable>]
    attr_accessor :arr_items_won

    # Initialize the UI
    # @overload initialize(item_count, music_filename = DEFAULT_MUSIC)
    #   @param item_count [Integer, nil] the number of items to search (nil for random between 2 and 5)
    #   @param music_filename [String] the filename of the music to play
    # @overload initialize(wanted_item_db_symbols, music_filename = DEFAULT_MUSIC)
    #   @param wanted_item_db_symbols [Array<Symbol>] the array containing the specific items (comprised between 1 and 5 items)
    #   @param music_filename [String] the filename of the music to play
    def initialize(param = nil, music_filename = DEFAULT_MUSIC)
      super()
      PFM.game_state.mining_game.nb_game_launched += 1
      @handler = PFM::MiningGame::GridHandler.new(param.is_a?(Array) ? param : nil, param.is_a?(Integer) ? param : nil, NB_X_TILES, NB_Y_TILES)
      @current_tool = :pickaxe
      @arr_items_won = []
      # @type [Yuki::Animation::TimedAnimation]
      @animation = nil
      # @type [Yuki::Animation::TimedAnimation]
      @transition_animation = nil
      # States are :mouse, :animation
      @ui_state = :mouse
      @mbf_type = :mining_game
      Audio.bgm_play(music_filename)
      @running = true
    end

    private

    # Method that execute the ping sound and might trigger the texts displayed the first time the player plays
    def launch_ping_text
      @transition_animation = nil
      Audio.se_play(File.join(SE_PATH, 'ping'))
      Graphics.wait(60)
      ping_text
      if PFM.game_state.mining_game.first_time
        Graphics.wait(60)
        first_time_text
      end
    end
  end
end
