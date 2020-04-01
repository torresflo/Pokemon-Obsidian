# Class that handle the methods of the nil value
class NilClass
  # Constant that contain a frozen "" to prevent multiple String generation while calling the #to_s method of nil.
  FrozenNilString = ''.freeze
  # Constant that contain a frozen [] to prevent multiple Array generation while calling the #to_a method of nil.
  FrozenNilArray = [].freeze
  # Ensure compatibility when an Array or String is not defined.
  # @return [0]
  def size
    0
  end

  # Ensure compatibility when an Array or String is not defined.
  #
  # This was meant to prevent code like thing == ""
  # @return true
  def empty?
    true
  end

  # Returns FrozenNilString
  # @see FrozenNilString
  # @return [String]
  def to_s
    return FrozenNilString
  end

  # Returns FrozenNilArray
  # @see FrozenNilArray
  # @return [Array]
  def to_a
    return FrozenNilArray
  end
end
