#encoding: utf-8

# Describe switches that are related to a specific event
# @author Enterbrain
class Game_SelfSwitches
  # Default initialization
  def initialize
    @data = {}
  end
  # Get the state of a self switch
  # @param key [Array] the key that identify the self switch
  # @return [Boolean]
  def [](key)
    return @data[key]
  end
  # Set the state of a self switch
  # @param key [Array] the key that identify the self switch
  # @param value [Boolean] the new value of the self switch
  def []=(key, value)
    @data[key] = value
  end
end

