# Class that describe a collection of characters
class String
  # Convert numeric related chars of the string to corresponding chars in the Pokemon DS font family
  # @return [self]
  # @author Nuri Yuri
  def to_pokemon_number
    return self if Fonts::NO_POKEMON_FONT

    tr!('0123456789n/', '│┤╡╢╖╕╣║╗╝‰▓')
    return self
  end
end
