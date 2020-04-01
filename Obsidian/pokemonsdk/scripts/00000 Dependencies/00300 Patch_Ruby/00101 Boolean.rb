# Define a boolean that is either true of false
#
# true.is_a?(Boolean) or false.is_a?(Boolean) will work
module Boolean
  # Convert the boolean to an integer
  # @return [Integer]
  def to_i
    self ? 1 : 0
  end
end
TrueClass.include(Boolean)
FalseClass.include(Boolean)
