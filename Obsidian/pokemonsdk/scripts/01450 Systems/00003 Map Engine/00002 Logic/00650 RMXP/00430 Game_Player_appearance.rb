class Game_Player
  # @return [String, nil] return the charset_base used to calculate the graphic
  attr_reader :charset_base
  # Launch the player update appearance
  # @param forced_pattern [Integer] pattern after update (default : 0)
  # @author Leikt
  def update_appearance(forced_pattern = 0)
    return unless @charset_base

    set_appearance("#{@charset_base}_#{$game_switches[Yuki::Sw::Gender] ? 'f' : 'm'}#{chara_by_state}")
    @pattern = forced_pattern
    update_pattern_state
    return true
  end

  # Get the character suffix from the hash
  # @return [String] the suffix
  # @author Leikt
  def chara_by_state
    return STATE_APPEARANCE_SUFFIX[@state || enter_in_walking_state]
  end

  # Change the appearance set for the player. The argument is the base of the charset name.
  # For exemple : for the file "HeroRed001_M_walk", the charset base will be "HeroRed001"
  # @param charset_base [String, nil] the base of the charsets filenames (nil = don't use the charset_base)
  # @author Leikt
  def set_appearance_set(charset_base)
    @charset_base = charset_base
    update_appearance
  end
end
