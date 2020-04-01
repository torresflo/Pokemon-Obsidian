if Object.const_defined?(:FMOD)
  module Audio
    # Loading the Fmod Module
    FMOD::System.init(32, FMOD::INIT::NORMAL)
    # Time it takes to fade in (in ms)
    FadeInTime = 1000
    @bgm_sound = nil
    @bgm_channel = nil
    @bgs_sound = nil
    @bgs_channel = nil
    @me_sound = nil
    @me_channel = nil
    @se_sounds = {}
    @fading_sounds = {} # Sound => Channel
    @cries_stack = []
    @was_playing_callback = nil
    # Mutex that ensure the BGM doesn't load two sounds at the same time
    @bgm_mutex = Mutex.new
    @bgs_mutex = Mutex.new
    @me_mutex = Mutex.new
    # List of extension that FmodEx can read (used to find files from names without ext name)
    EXT = ['.ogg', '.mp3', '.wav', '.mid', '.aac', '.wma', '.it', '.xm', '.mod', '.s3m', '.midi', '.flac']

    module_function

    # plays a BGM and stop the current one
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the BGM between 0 and 100
    # @param pitch [Integer] speed of the BGM in percent
    # @param fade_in [Boolean, Integer] if the BGM fades in when different (or time in ms)
    def bgm_play(file_name, volume = 100, pitch = 100, fade_in = true)
      Thread.new do
        synchronize(@bgm_mutex) { bgm_play_internal(file_name, volume, pitch, fade_in) }
      end
    end

    # plays a BGM and stop the current one
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the BGM between 0 and 100
    # @param pitch [Integer] speed of the BGM in percent
    # @param fade_in [Boolean, Integer] if the BGM fades in when different (or time in ms)
    def bgm_play_internal(file_name, volume, pitch, fade_in)
      volume = volume * @music_volume / 100
      filename = search_filename(file_name)
      was_playing = was_sound_previously_playing?(file_name.downcase, @bgm_name, @bgm_sound, @bgm_channel, fade_in)
      @bgm_name = file_name.downcase
      fade_in = (fade_in and @bgm_sound and !was_playing)
      release_fading_sounds((was_playing || fade_in) ? nil : @bgm_sound)
      # Unless the sound was playing, we create it
      unless was_playing
        @bgm_sound = @bgm_channel = nil
        # @bgm_sound = FMOD::System.createSound(filename, FMOD::MODE::LOOP_NORMAL | FMOD::MODE::FMOD_2D, nil)
        return unless (@bgm_sound = Cache.create_sound_sound(filename))
        autoloop(@bgm_sound)
      end
      # we create a channel if there was no channel or the sound was not playing
      @bgm_channel = FMOD::System.playSound(@bgm_sound, true) unless was_playing and @bgm_channel
      adjust_channel(@bgm_channel, volume, pitch)
      @bgm_channel.setDelay(@me_bgm_restart, 0, fade_in = false) if @me_bgm_restart and @me_bgm_restart > @bgm_channel.getDSPClock.last
      fade(fade_in == true ? FadeInTime : fade_in, @bgm_channel, 0, 1.0) if fade_in
      @fading_sounds.delete(@bgm_sound) # Reused channel error prevention
    rescue FMOD::Error
      if File.exist?(filename)
        log_error("Le fichier #{file_name} n'a pas pu être lu...\nErreur : #{$!.message}")
      else
        log_error("Le fichier #{filename} n'a pas été trouvé !")
      end
      bgm_stop
    ensure
      call_was_playing_callback
    end

    # Returns the BGM position
    # @return [Integer]
    def bgm_position
      synchronize(@bgm_mutex) do
        return @bgm_channel.getPosition(FMOD::TIMEUNIT::PCM) if @bgm_channel
      end
      return 0
    end

    # Set the BGM position
    # @param position [Integer]
    def bgm_position=(position)
      synchronize(@bgm_mutex) do
        @bgm_channel&.setPosition(position, FMOD::TIMEUNIT::PCM)
      end
    rescue StandardError
      log_error("bgm_position= : #{$!.message}")
    end

    # Fades the BGM
    # @param time [Integer] fade time in ms
    def bgm_fade(time)
      synchronize(@bgm_mutex) do
        return unless @bgm_channel
        return unless (sound = @bgm_sound)
        return if @fading_sounds[sound]
        fade(time, @fading_sounds[sound] = @bgm_channel)
        @bgm_channel = nil
      end
    end

    # Stop the BGM
    def bgm_stop
      synchronize(@bgm_mutex) do
        return unless @bgm_channel
        @bgm_channel.stop
        @bgm_channel = nil
      end
    rescue FMOD::Error => e
      puts e.message if debug?
    end

    # plays a BGS and stop the current one
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the BGS between 0 and 100
    # @param pitch [Integer] speed of the BGS in percent
    # @param fade_in [Boolean, Integer] if the BGS fades in when different (Integer = time to fade)
    def bgs_play(file_name, volume = 100, pitch = 100, fade_in = true)
      Thread.new do
        synchronize(@bgs_mutex) { bgs_play_internal(file_name, volume, pitch, fade_in) }
      end
    end

    # plays a BGS and stop the current one
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the BGS between 0 and 100
    # @param pitch [Integer] speed of the BGS in percent
    # @param fade_in [Boolean, Integer] if the BGS fades in when different (Integer = time to fade)
    def bgs_play_internal(file_name, volume, pitch, fade_in)
      volume = volume * @sfx_volume / 100
      filename = search_filename(file_name)
      was_playing = was_sound_previously_playing?(file_name.downcase, @bgs_name, @bgs_sound, @bgs_channel, fade_in)
      @bgs_name = file_name.downcase
      fade_in = (fade_in and @bgs_sound and !was_playing)
      release_fading_sounds((was_playing || fade_in) ? nil : @bgs_sound)
      # Unless the sound was playing, we create it
      unless was_playing
        @bgs_sound = @bgs_channel = nil
        # @bgs_sound = FMOD::System.createSound(filename, FMOD::MODE::LOOP_NORMAL | FMOD::MODE::FMOD_2D, nil)
        return unless (@bgs_sound = Cache.create_sound_sound(filename))
        autoloop(@bgs_sound)
      end
      # we create a channel if there was no channel or the sound was not playing
      @bgs_channel = FMOD::System.playSound(@bgs_sound, true) unless was_playing and @bgs_channel
      adjust_channel(@bgs_channel, volume, pitch)
      fade(fade_in == true ? FadeInTime : fade_in, @bgs_channel, 0, 1.0) if fade_in
      @fading_sounds.delete(@bgs_sound) # Reused channel error prevention
    rescue FMOD::Error
      if File.exist?(filename)
        cc 0x01
        log_error("Le fichier #{file_name} n'a pas pu être lu...\nErreur : #{$!.message}")
      else
        log_error("Le fichier #{filename} n'a pas été trouvé !")
      end
      bgs_stop
    ensure
      call_was_playing_callback
    end

    # Fades the BGS
    # @param time [Integer] fade time in ms
    def bgs_fade(time)
      synchronize(@bgs_mutex) do
        return unless @bgs_channel
        return unless (sound = @bgs_sound)
        return if @fading_sounds[sound]
        fade(time, @fading_sounds[sound] = @bgs_channel)
        @bgs_channel = nil
      end
    end

    # Stop the BGS
    def bgs_stop
      synchronize(@bgs_mutex) do
        return unless @bgs_channel
        @bgs_channel.stop
        @bgs_channel = nil
      end
    rescue FMOD::Error => e
      puts e.message if debug?
    end

    # plays a ME and stop the current one, the BGM will be paused during the ME play
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the ME between 0 and 100
    # @param pitch [Integer] speed of the ME in percent
    # @param preserve_bgm [Boolean] tell the function not to pause the bgm
    def me_play(file_name, volume = 100, pitch = 100, preserve_bgm = false)
      Thread.new do
        synchronize(@bgm_mutex) do
          synchronize(@me_mutex) do
            me_play_internal(file_name, volume, pitch, preserve_bgm)
          end
        end
      end
    end

    # plays a ME and stop the current one, the BGM will be paused during the ME play
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the ME between 0 and 100
    # @param pitch [Integer] speed of the ME in percent
    # @param preserve_bgm [Boolean] tell the function not to pause the bgm
    def me_play_internal(file_name, volume, pitch, preserve_bgm)
      volume = volume * @music_volume / 100
      filename = search_filename(file_name)
      was_playing = was_sound_previously_playing?(file_name.downcase, @me_name, @me_sound, @me_channel)
      @me_name = file_name.downcase
      release_fading_sounds(was_playing ? nil : @me_sound)
      # Unless the sound was playing, we create it
      unless was_playing
        @me_sound = @me_channel = nil
        return unless (@me_sound = Cache.create_sound_sound(filename, FMOD::MODE::LOOP_OFF | FMOD::MODE::FMOD_2D)) # FMOD::System.createStream(filename, FMOD::MODE::LOOP_OFF | FMOD::MODE::FMOD_2D, nil)
      end
      # we create a channel if there was no channel or the sound was not playing
      @me_channel = FMOD::System.playSound(@me_sound, true)
      adjust_channel(@me_channel, volume, pitch)
      @fading_sounds.delete(@me_sound) # Reused channel error prevention
      return if preserve_bgm
      if @bgm_channel
        length = @me_sound.getLength(FMOD::TIMEUNIT::PCM) * 100
        length /= pitch
        @bgm_channel.setDelay(@me_bgm_restart = @bgm_channel.getDSPClock.last + length, 0, false)
      else
        @me_bgm_restart = nil
      end
    rescue FMOD::Error
      if File.exist?(filename)
        cc 0x01
        log_error("Le fichier #{file_name} n'a pas pu être lu...\nErreur : #{$!.message}")
      else
        log_error("Le fichier #{filename} n'a pas été trouvé !")
      end
      me_stop
    ensure
      call_was_playing_callback
    end

    # Fades the ME
    # @param time [Integer] fade time in ms
    def me_fade(time)
      synchronize(@me_mutex) do
        return unless @me_channel
        return unless (sound = @me_sound)
        return if @fading_sounds[sound]
        fade(time, @me_channel)
        if @bgm_channel
          sr = FMOD::System.getSoftwareFormat.first
          delay = @bgm_channel.getDSPClock.last + Integer(time * sr / 1000)
          @bgm_channel.setDelay(delay, 0, false) if !@me_bgm_restart || @me_bgm_restart > delay
        end
        @me_channel = nil
      end
    end

    # Stop the ME
    def me_stop
      synchronize(@me_mutex) do
        return unless @me_channel
        @bgm_channel&.setDelay(0, 0, false)
        @me_channel.stop
        @me_channel = nil
      end
    rescue FMOD::Error => e
      puts e.message if debug?
    end

    # plays a SE if possible
    # @param file_name [String] name of the audio file
    # @param volume [Integer] volume of the SE between 0 and 100
    # @param pitch [Integer] speed of the SE in percent
    def se_play(file_name, volume = 100, pitch = 100)
      volume = volume * @sfx_volume / 100
      filename = search_filename(file_name)
      unless (sound = @se_sounds[file_name])
        sound = FMOD::System.createStream(filename, FMOD::MODE::LOOP_OFF | FMOD::MODE::FMOD_2D, nil)
        if filename.include?('/cries/')
          @cries_stack << sound
          @cries_stack.shift.release if @cries_stack.size > 5
        else
          @se_sounds[file_name] = sound
        end
      end
      channel = FMOD::System.playSound(sound, true)
      channel.setVolume(volume / 100.0)
      channel.setPitch(pitch / 100.0)
      channel.setPaused(false)
    rescue FMOD::Error
      if !File.exist?(filename)
        log_error("Le fichier #{filename} n'a pas été trouvé !")
      elsif $!.hr == 46
        p @se_sounds
        se_stop
        retry
      else
        cc 0x01
        log_error("Le fichier #{file_name} n'a pas pu être lu...\nErreur : #{$!.message}")
      end
    end

    # Stops every SE
    def se_stop
      @se_sounds.each_value(&:release)
      @cries_stack.each(&:release)
      @cries_stack.clear
      @se_sounds.clear
    end

    # Search the real filename of the audio file
    # @param file_name [String] filename of the audio file
    # @return [String] real filename if found or file_name
    def search_filename(file_name)
      file_name = file_name.downcase
      return file_name if File.exist?(file_name)
      EXT.each do |ext|
        filename = file_name + ext
        return filename if File.exist?(filename)
      end
      return file_name
    end

    # Auto loop a music
    # @param sound [FMOD::Sound] the sound that contain the data
    # @note Only works with createSound and should be called before the channel creation
    def autoloop(sound)
      start = sound.getTag('LOOPSTART', 0)[2].to_i rescue nil
      length = sound.getTag('LOOPLENGTH', 0)[2].to_i rescue nil
      unless start && length # Probably an MP3
        index = 0
        while (tag = sound.getTag('TXXX', index) rescue nil)
          index += 1
          next unless tag[2].is_a?(String)
          name, data = tag[2].split("\x00")
          if name == 'LOOPSTART' && !start
            start = data.to_i
          elsif name == 'LOOPLENGTH' && !length
            length = data.to_i
          end
        end
      end
      return unless start && length
      log_info "LOOP: #{start} -> #{start + length}" unless PSDK_CONFIG.release?
      sound.setLoopPoints(start, FMOD::TIMEUNIT::PCM, start + length, FMOD::TIMEUNIT::PCM)
    end

    # Fade a channel
    # @param time [Integer] number of miliseconds to perform the fade
    # @param channel [FMOD::Channel] the channel to fade
    # @param start_value [Numeric]
    # @param end_value [Numeric]
    def fade(time, channel, start_value = 1.0, end_value = 0)
      sr = FMOD::System.getSoftwareFormat.first
      pdsp = channel.getDSPClock.last
      stop_time = pdsp + Integer(time * sr / 1000)
      channel.addFadePoint(pdsp, start_value)
      channel.addFadePoint(stop_time, end_value)
      channel.setDelay(0, stop_time + 20, false) if end_value == 0
      channel.setVolumeRamp(true)
      channel.instance_variable_set(:@stop_time, stop_time)
    end

    # Fade in out a channel
    # @param channel [FMOD::Channel] the channel to fade
    # @param fadeout_time [Integer] number of miliseconds to perform the fade out
    # @param sleep_time [Integer] number of miliseconds to wait before fading in
    # @param fadein_time [Integer] number of miliseconds to perform the fade in
    # @param sleep_type [Symbol] tell the sleep_time type (:ms, :pcm)
    # @param lowest_volume [Integer] lowest volume in %
    def fade_in_out(channel, fadeout_time, sleep_time, fadein_time, sleep_type = :ms, lowest_volume = 0.0)
      sr = FMOD::System.getSoftwareFormat.first
      pdsp = channel.getDSPClock.last
      sleep_time = sleep_time * sr / 1000 if sleep_type == :ms
      p1_time = pdsp + Integer(fadeout_time * sr / 1000)
      p2_time = pdsp + Integer(fadeout_time * sr / 1000) + sleep_time
      p3_time = pdsp + Integer((fadeout_time + fadein_time) * sr / 1000) + sleep_time
      channel.addFadePoint(pdsp, 1.0)
      channel.addFadePoint(p1_time, lowest_volume)
      channel.addFadePoint(p2_time, lowest_volume)
      channel.addFadePoint(p3_time, 1.0)
      channel.setVolumeRamp(true)
    end

    # Try to release all fading sounds that are done fading
    # @param additionnal_sound [FMOD::Sound, nil] a sound that should be released with the others
    # @note : Warning ! Doing sound.release before channel.anything make the channel invalid and raise an FMOD::Error
    def release_fading_sounds(additionnal_sound)
      unless @fading_sounds.empty?
        sound_guardian = [@bgm_sound, @bgs_sound, @me_sound]
        sounds_to_delete = []
        @fading_sounds.each do |sound, channel|
          additionnal_sound = nil if additionnal_sound == sound
          next unless channel_stop_time_exceeded(channel)
          sounds_to_delete << sound
          channel.stop
          next if sound_guardian.include?(sound)
          sound.release
        rescue FMOD::Error
          next # Next iteration if channel.stop failed
        end
        sounds_to_delete.each { |sound| @fading_sounds.delete(sound) }
      end
      additionnal_sound&.release
    end

    # Return if the channel time is higher than the stop time
    # @note will return true if the channel handle is invalid
    # @param channel [FMOD::Channel]
    # @return [Boolean]
    def channel_stop_time_exceeded(channel)
      return channel.getDSPClock.last >= channel.instance_variable_get(:@stop_time).to_i
    rescue FMOD::Error
      return true
    end

    # Function that detects if the previous playing sound is the same as the next one
    # @param filename [String] the filename of the sound
    # @param old_filename [String] the filename of the old sound
    # @param sound [FMOD::Sound] the previous playing sound
    # @param channel [FMOD::Channel, nil] the previous playing channel
    # @param fade_out [Boolean, Integer] if the channel should fades out (Integer = time to fade)
    # @note If the sound wasn't the same, the channel will be stopped if not nil
    # @return [Boolean]
    def was_sound_previously_playing?(filename, old_filename, sound, channel, fade_out = false)
      return false unless sound
      return true unless filename != old_filename
      return false unless channel && (channel.isPlaying rescue false)
      if fade_out && !@fading_sounds[sound]
        fade_time = fade_out == true ? FadeInTime : fade_out
        @was_playing_callback = proc { fade(fade_time, @fading_sounds[sound] = channel) }
      else
        @was_playing_callback = proc { channel.stop }
      end
      return false
    end

    # Adjust channel volume and pitch
    # @param channel [Fmod::Channel]
    # @param volume [Numeric] target volume
    # @param pitch [Numeric] target pitch
    def adjust_channel(channel, volume, pitch)
      channel.setVolume(volume / 100.0)
      channel.setPitch(pitch / 100.0)
      channel.setPaused(false)
    end

    # Automatically call the "was playing callback"
    def call_was_playing_callback
      @was_playing_callback&.call
      @was_playing_callback = nil
    rescue StandardError
      @was_playing_callback = nil
    end

    # Reset the sound engine
    def __reset__
      bgm_stop
      bgs_stop
      me_stop
      se_stop
      @bgm_sound = nil
      @bgs_sound = nil
      @me_sound = nil
      @se_sounds = {}
      @fading_sounds = {}
      @was_playing_callback = nil
    end

    # Synchronize a mutex
    # @param mutex [Mutex] the mutex to safely synchronize
    # @param block [Proc] the block to call
    def synchronize(mutex, &block)
      return yield if mutex.locked? && mutex.owned?
      mutex.synchronize(&block)
    end

    # Update the Audio
    def update
      FMOD::System.update
    end
  end
else
  module Audio
    log_error('FMOD not found!')

    module_function

    def bgm_play(*) end

    def bgm_position
      return 0
    end

    def bgm_position=(*) end

    def bgs_play(*) end

    def me_play(*) end

    def se_play(*) end

    def bgm_fate(time) end

    def bgs_fade(time) end

    def me_fade(time) end

    def bgm_stop() end

    def bgs_stop() end

    def me_stop() end

    def se_stop() end

    def __reset__() end

    def update() end
  end
end
