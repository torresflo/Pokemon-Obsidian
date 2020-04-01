module PFM
  # The options data
  #
  # The options are stored in $options and $pokemon_party.options
  # @author Nuri Yuri
  class Options
    # The volume of the BGM and ME
    # @return [Integer]
    attr_reader :music_volume
    # The volume of the BGS and SE
    # @return [Integer]
    attr_reader :sfx_volume
    # The speed of the message display
    # @return [Integer]
    attr_reader :message_speed
    # If the battle ask to switch pokemon or not
    # @return [Boolean]
    attr_accessor :battle_mode
    # If the battle show move animations
    # @return [Boolean]
    attr_accessor :show_animation
    # The lang id of the GameData::Text loads
    # @return [String]
    attr_reader :language
    # The message frame
    # @return [String]
    attr_reader :message_frame
    # Create a new Option object with a language
    # @param starting_language [String] the lang id the game will start
    def initialize(starting_language)
      @music_volume = 100
      @sfx_volume = 100
      @message_speed = 3
      @battle_mode = true
      @show_animation = true
      @language = starting_language
      self.message_frame = GameData::Windows::MESSAGE_FRAME.first
    end

    # Change the master volume
    # @param value [Integer] the new master volume
    def music_volume=(value)
      return unless value.between?(0, 100)
      @music_volume = Audio.music_volume = value
    end

    # Change the SFX volume
    # @param value [Integer] the new sfx volume
    def sfx_volume=(value)
      return unless value.between?(0, 100)
      @sfx_volume = Audio.sfx_volume = value
    end

    # Change both music & sfx volume at the same time
    # @param value [Integer] the new volume
    def master_volume=(value)
      self.music_volume = value
      self.sfx_volume = value
    end

    alias master_volume music_volume

    # Change the in game lang (reload the texts)
    # @param value [String] the new lang id
    def language=(value)
      return unless GameData::Text::Available_Langs.include?(value)
      @language = value
      GameData::Text.load
    end
    alias set_language language=

    # Change the message speed
    # @param value [Integer] the new message speed
    def message_speed=(value)
      @message_speed = value.clamp(1, 999)
    end

    # Change the message frame
    # @param value [String] the new message frame
    def message_frame=(value)
      return unless GameData::Windows::MESSAGE_FRAME.include?(value)
      @message_frame = value
      $game_system&.windowskin_name = @message_frame
    end
  end

  class Pokemon_Party
    # The game options
    # @return [PFM::Options]
    attr_accessor :options
    on_player_initialize(:options) { @options = PFM::Options.new(@starting_language) }
    on_expand_global_variables(:options) do
      # Variable containing all the game options
      $options = @options
    end
  end
end
