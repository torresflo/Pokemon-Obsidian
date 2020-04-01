# Class that describe a collection of characters
class String
  # Regexp used inside #generate_line_feeds
  LINE_FEED_REG = /\. ([A-Z])/
  # Replacement used inside #generate_line_feeds
  LINE_FEED_REP = ".\n\\1"

  # Convert numeric related chars of the string to corresponding chars in the Pokemon DS font family
  # @return [self]
  # @author Nuri Yuri
  def to_pokemon_number
    return self if Fonts::NO_POKEMON_FONT

    tr!('0123456789n/', '│┤╡╢╖╕╣║╗╝‰▓')
    return self
  end

  # Generate line feed after each dot followed by an capital letter
  # @param destructive [Boolean] indicate if the method generate line feed in the calling String or a new String
  # @return [self, String]
  # @author Nuri Yuri
  def generate_line_feeds(destructive = true)
    if destructive
      gsub!(LINE_FEED_REG, LINE_FEED_REP)
      return self
    end
    return gsub(LINE_FEED_REG, LINE_FEED_REP)
  end
end
