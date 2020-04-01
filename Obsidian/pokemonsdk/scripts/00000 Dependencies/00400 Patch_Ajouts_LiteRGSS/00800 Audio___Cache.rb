module Audio
  # Module that cache sounds during the game
  module Cache
    # Variable that holds the cached bgm files
    @sound_cache = {}
    # Variable that holds the bgm count (auto release when felt to 0)
    @sound_count = {}
    # Variable that holds the bgm files to load
    @sound_loads = []

    module_function

    # Start the Audio cache
    def start
      return if @thread
      @thread = Thread.new do
        loop do
          sleep
          load_files
        end
      end
    end

    # Start the file loading
    def load
      @thread.wakeup
    end

    # Load the files
    def load_files
      loads = @sound_loads.clone
      @sound_loads.clear
      Thread.new do
        while (filename = loads.pop)
          next(@sound_count[filename] = 5) if @sound_cache[filename]
          t = Time.new
          @sound_cache[filename] = File.open(filename, 'rb') { |f| f.read(f.size) }
          @sound_count[filename] = 5
          log_info "\rAudio::Cache : #{filename} loaded in #{Time.new - t}s" unless PSDK_CONFIG.release?
        end
      end
    end

    # Create a bgm sound used to play the BGM
    # @param filename [String] the correct filename of the sound
    # @param flags [Integer, nil] the FMOD flags for the creation
    # @return [FMOD::Sound] the sound
    def create_sound_sound(filename, flags = nil)
      Yuki::ElapsedTime.start(:audio_load_sound)
      if (file_data = @sound_cache[filename])
        @sound_count[filename] += 1
      else
        file_data = File.binread(filename)
        Yuki::ElapsedTime.show(:audio_load_sound, 'Loading sound from disk took')
      end
      gm_filename = filename.include?('.mid') && File.exist?('gm.dls') ? 'gm.dls' : nil
      sound_info = FMOD::SoundExInfo.new(file_data.bytesize, nil, nil, nil, nil, nil, gm_filename)
      sound = FMOD::System.createSound(file_data, create_sound_get_flags(flags), sound_info)
      sound.instance_variable_set(:@extinfo, sound_info)
      Yuki::ElapsedTime.show(:audio_load_sound, 'Creating sound object took')
      return sound
    rescue Errno::ENOENT
      log_error("Failed to load sound : #{filename}")
      return nil
    end

    # Return the expected flag for create_sound_sound
    # @param flags [Integer, nil] the FMOD flags for the creation
    # @return [Integer]
    def create_sound_get_flags(flags)
      return (flags | FMOD::MODE::OPENMEMORY | FMOD::MODE::CREATESTREAM) if flags
      return (FMOD::MODE::LOOP_NORMAL | FMOD::MODE::FMOD_2D | FMOD::MODE::OPENMEMORY | FMOD::MODE::CREATESTREAM)
    end

    # Flush the sound cache if the sounds are not lapsed
    def flush_sound
      to_delete = []
      @sound_cache.each_key do |filename|
        to_delete << filename if (@sound_count[filename] -= 1) <= 0
      end
      to_delete.reverse_each do |filename|
        log_info "Audio::Cache : #{filename} released."
        @sound_count.delete(filename)
        @sound_cache.delete(filename)
      end
    end

    # Preload a sound
    # @param filename [String]
    def preload_sound(filename)
      filename = Audio.search_filename(filename)
      return unless sound_exist?(filename)
      @sound_loads << filename
    end

    # Test if a sound exist
    # @param filename [String]
    def sound_exist?(filename)
      return File.exist?(filename)
    end
  end
end

Graphics.on_start do
  Audio::Cache.start
end
