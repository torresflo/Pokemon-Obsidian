module GamePlay
  class Save
    class << self
      # @return [Integer] index of the save file (to allow multi-save)
      attr_accessor :save_index

      # @return [Hash] all the before save hooks
      BEFORE_SAVE_HOOKS = { game_map: proc { $game_map.begin_save } }
      # @return [Hash] all the after save hooks
      AFTER_SAVE_HOOKS = { game_map: proc { $game_map.end_save } }

      # Save a game
      # @param filename [String, nil] name of the save file (nil = auto name the save file)
      # @param no_file [Boolean] tell if the save should not be saved to file and just be returned
      def save(filename = nil, no_file = false)
        return 'NONE' unless $game_temp

        clear_states
        update_save_info
        # Call the hooks that make the save data safer and lighter
        BEFORE_SAVE_HOOKS.each_value(&:call)
        # Build the save data
        save_data = Configs.save_config.save_header.dup.force_encoding(Encoding::ASCII_8BIT)
        save_data << encrypt(Marshal.dump($pokemon_party))
        # Save the game
        save_file(filename || Save.save_filename, save_data) unless no_file
        # Call the hooks that restore all the data
        AFTER_SAVE_HOOKS.each_value(&:call)
        return save_data
      end

      # Load a game
      # @param filename [String, nil] name of the save file (nil = auto name the save file)
      # @param no_load_parameter [Boolean] if the system should not call load_parameters
      # @return [PFM::Pokemon_Party, nil] The save data (nil = no save data / data corruption)
      # @note Change $pokemon_party
      def load(filename = nil, no_load_parameter: false)
        filename ||= Save.save_filename
        return nil unless File.exist?(filename)

        header = Configs.save_config.save_header
        data = File.binread(filename)
        file_header = data[0...(header.size)]
        return nil if file_header != header

        $pokemon_party = Marshal.load(encrypt(data[header.size..-1]))
        $pokemon_party.load_parameters unless no_load_parameter
        return $pokemon_party
      rescue LoadError, StandardError
        return nil
      end

      def save_root_path
        SAVE_ROOT_PATHS.find(&File.method(:writable?)) || ''
      end

      def save_filename
        root = save_root_path.tr('\\', '/').encode(Encoding::UTF_8)
        game_name = root.start_with?('.') ? '' : ".#{PSDK_CONFIG.game_title}/"
        base_filename = Configs.save_config.base_filename
        filename = (@save_index > 0 ? format(MULTI_SAVE_FORMAT, base_filename, @save_index) : base_filename)
        return format('%<root>s/%<game_name>s%<filename>s', root: root, game_name: game_name, filename: filename)
      end

      private

      # Function that encrypt / decrypt the save
      # @param data [String]
      # @return [String]
      def encrypt(data)
        return data if Configs.save_config.save_key == 0

        data << "\x00\x00\x00"
        key = Configs.save_config.save_key

        return data.unpack('I*').map { |i| i ^ key }.pack('I*')
      end

      # Function that clears the sate
      def clear_states
        $game_temp.message_proc = nil
        $game_temp.choice_proc = nil
        $game_temp.battle_proc = nil
        $game_temp.message_window_showing = false
      end

      # Function that update the save info (current game version, current PSDK version etc...)
      def update_save_info
        $game_system.save_count += 1
        $trainer.update_play_time
        $trainer.current_version = PSDK_Version
        $trainer.game_version = PSDK_CONFIG.game_version
      end

      # Function that actually save the file
      # @param filename [String]
      # @param save_data [String] save_data
      def save_file(filename, save_data)
        backup_filename = "#{filename}.bak"
        File.delete(backup_filename) if File.exist?(backup_filename)
        File.rename(filename, backup_filename) if File.exist?(filename)
        File.binwrite(filename, save_data)
        # Check file integrity
        if File.binread(filename) != save_data
          $scene.display_message_and_wait(text_get(26, 19))
          File.rename(backup_filename, filename) if File.exist?(backup_filename)
        end
      rescue Exception
        $scene.display_message_and_wait(text_get(26, 19))
      end
    end
  end
end
