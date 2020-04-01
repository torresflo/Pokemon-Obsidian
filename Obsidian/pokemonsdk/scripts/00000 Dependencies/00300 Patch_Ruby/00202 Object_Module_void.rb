class Object
  # Function that does nothing and return nil
  # @example
  #   alias function_to_disable void
  def void(*args)
    return nil
  end

  # Function that does nothing and return true
  # @example
  #   alias function_to_disable void_true
  def void_true(*args)
    return true
  end

  # Function that does nothing and return false
  # @example
  #   alias function_to_disable void_false
  def void_false(*args)
    return false
  end

  # Function that does nothing and return 0
  # @example
  #   alias function_to_disable void0
  def void0(*args)
    return 0
  end

  # Function that does nothing and return []
  # @example
  #   alias function_to_disable void_array
  def void_array(*args)
    return nil.to_a
  end

  # Function that does nothing and return ""
  # @example
  #   alias function_to_disable void_array
  def void_string(*args)
    return nil.to_s
  end
end

class Module
  # Constant that contains the default void method name
  VOID_METHODS = {
    nil => :void,
    true => :void_true,
    false => :void_false,
    0 => :void0,
    [] => :void_array,
    '' => :void_string,
  }
  # Function that void a method
  # @param name [Symbol] name of the method to void
  # @param return_value [Object] return value of the function when voided
  def void_method(name, return_value = nil)
    voided_name = VOID_METHODS[return_value]
    if voided_name
      alias_method name, voided_name
    else
      define_method(name) { |*| return_value }
    end
    return name
  end
end
