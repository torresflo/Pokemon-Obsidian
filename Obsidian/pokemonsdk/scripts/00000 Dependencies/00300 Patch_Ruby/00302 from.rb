module Kernel
  # Infer the object as the specified class (lint)
  # @return [self]
  def from(other)
    raise "Object of class #{other.class} cannot be casted as #{self}" unless other.is_a?(self)

    return other
  end
end
