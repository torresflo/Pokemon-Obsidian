module GamePlay
  # Save game scene
  class Save < Load
    # MultiSave file format
    MULTI_SAVE_FORMAT = '%s-%d'
    # List of the usable root path for the save state
    SAVE_ROOT_PATHS = [
      '.',
      ENV['APPDATA'] || Dir.home,
      Dir.home
    ]
    # @return [Integer] index of the save file (to allow multi-save)
    @save_index = 0
    # @return [Boolean] if the game was saved
    attr_reader :saved

    # Create a new GamePlay::Save
    def initialize
      super
      make_save_directory
      @saved = false
      @index = Configs.save_config.single_save? ? 0 : Save.save_index - 1
    end

    # Return the current Pokemon_Party object
    # @return [Pokemon_Party, nil]
    def current_pokemon_party
      $pokemon_party || Save.load
    end

    # Save the game (method allowing hooks on the save)
    def save_game
      Save.save
    end

    private

    def create_frame
      @frame = Sprite.new(@viewport)
      @frame.load('load/frame_save', :interface)
    end

    def button_texts
      [
        text_get(14, 4),
        nil,
        nil,
        ext_text(9000, 115)
      ]
    end

    # Function creating the save directory
    def make_save_directory
      directory = File.dirname(Save.save_filename)
      Dir.mkdir!(directory)
    end

    undef create_new_game
  end
end
