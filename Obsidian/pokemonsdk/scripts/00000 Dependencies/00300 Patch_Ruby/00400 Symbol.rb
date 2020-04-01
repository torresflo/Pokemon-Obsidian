# Class that holds every methods of a symbol
class Symbol
  # In case of using + operator on symbol, return self
  # @return [self]
  def +(_other)
    return self
  end
end
