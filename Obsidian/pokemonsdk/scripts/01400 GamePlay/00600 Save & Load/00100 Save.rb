module GamePlay
  # Save game scene
  class Save < Base
    # Windowskin used to save the game
    Windowskin = 'message'
    # Base filename of the save file
    BASE_FILENAME = 'Saves/Pokemon_Party'
    # Corrupted save file message
    CORRUPTED_FILE_MESSAGE = 'Corrupted Save File'
    # Unkonw location text
    UNKNOWN_ZONE = 'Zone ???'
    # Time format
    DispTime = '%02d:%02d'
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
      @answered = false
      @saved = false
    end

    # Update the save scene
    def update
      return unless super
      if @answered
        save_game
        saved_message = parse_text(26, 17, TRNAME[0] => $trainer.name)
        display_message_and_wait(saved_message)
        @running = false
        @saved = true
      else
        save_question = text_get(26, 15)
        yes = text_get(25, 20)
        no = text_get(25, 21)
        if display_message(save_question, 1, yes, no) != 0 # NO
          close_message_window
          @running = false
        end
        @answered = true
      end
    end

    # Create the save related graphics
    def create_graphics
      create_viewport
      if File.exist?(Save.save_filename)
        @window = UI::SaveWindow.new(@viewport)
        @window.data = current_pokemon_party
      end
    end

    # Create the Save Scene viewport
    def create_viewport
      @viewport = Viewport.create(:main, 10_500)
    end

    # Function creating the save directory
    def make_save_directory
      directory = File.dirname(Save.save_filename)
      Dir.mkdir!(directory)
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

    class << self
      # @return [Integer] index of the save file (to allow multi-save)
      attr_accessor :save_index
      # @return [Hash] all the before save hooks
      BEFORE_SAVE_HOOKS = { game_map: proc { $game_map.begin_save } }
      # @return [Hash] all the after save hooks
      AFTER_SAVE_HOOKS = { game_map: proc { $game_map.end_save } }
      # Save a game
      # @param filename [String, nil] name of the save file (nil = auto name the save file)
      def save(filename = nil)
        # Fix the filename for event processing
        filename ||= Save.save_filename
        # Clear states
        $game_temp.message_proc = nil
        $game_temp.choice_proc = nil
        $game_temp.battle_proc = nil
        $game_temp.message_window_showing = false
        # Update informations about the save and make the game ready to save
        $game_system.save_count += 1
        $trainer.update_play_time
        $trainer.current_version = PSDK_Version
        $trainer.game_version = PSDK_CONFIG.game_version
        # Call the hooks that make the save data safer and lighter
        BEFORE_SAVE_HOOKS.each_value(&:call)
        # Build the save data
        save_data = 'PKPRT'
        save_data << Marshal.dump($pokemon_party)
        # Save the game
        File.binwrite(filename, save_data)
        # Call the hooks that restore all the data
        AFTER_SAVE_HOOKS.each_value(&:call)
      end

      # Load a game
      # @param filename [String, nil] name of the save file (nil = auto name the save file)
      # @return [PFM::Pokemon_Party, nil] The save data (nil = no save data / data corruption)
      # @note Change $pokemon_party
      def load(filename = nil)
        filename ||= Save.save_filename
        return nil unless File.exist?(filename)
        File.open(filename, 'rb') do |save_file|
          raise LoadError, 'Fichier corrompu' if save_file.read(5) != 'PKPRT'
          $pokemon_party = Marshal.load(save_file)
          $pokemon_party.load_parameters
          return $pokemon_party
        end
      rescue LoadError, StandardError
        return nil
      end

      def save_root_path
        SAVE_ROOT_PATHS.find(&File.method(:writable?)) || ''
      end

      def save_filename
        root = save_root_path.tr('\\', '/').encode(Encoding::UTF_8)
        game_name = root.start_with?('.') ? '' : ".#{PSDK_CONFIG.game_title}/"
        filename = (@save_index > 0 ? format(MULTI_SAVE_FORMAT, BASE_FILENAME, @save_index) : BASE_FILENAME)
        return format('%<root>s/%<game_name>s%<filename>s', root: root, game_name: game_name, filename: filename)
      end
    end
  end
end
