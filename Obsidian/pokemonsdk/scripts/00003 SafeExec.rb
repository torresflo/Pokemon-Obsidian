# Module responsive of savely execute piece of code at the end of the whole script loading
module SafeExec
  # Safe constants to evaluate when everything is loaded
  SAFE_CONSTANTS = {}
  # List of safe piece of code to execute
  SAFE_CODE = {}
  module_function
  # Load the safe constants/codes and clear the hash
  def load
    SAFE_CONSTANTS.each_value do |consts|
      consts.each_value(&:call)
    end
    SAFE_CONSTANTS.clear
    SAFE_CODE.each_value do |codes|
      codes.each_value(&:call)
    end
    SAFE_CODE.clear
  end
end

# Safely define a constant (make its value valid once every scripts got loaded)
# @param name [Symbol] name of the constant in the class where it should be defined
# @param value [Proc] code to execute to give the proper constant value
# @note This is not suited for cyclic redundancy (C::A = D::B; D::B = C::E). The value should never be passed as &block.
#   The final value of the constant can be changed by calling safe_const again.
# @example Defining a constant dependant of a class that is not already loaded :
#   class MyClass
#     MY_CONST = safe_const(:MY_CONST) { DependingOnClass::OTHER_CONST * 3 }
#   end
#   # This prevents uninitialized constant DependingOnClass
def safe_const(name, &value)
  receiver = value.binding.receiver
  receiver = Object if receiver.class == Object
  return (SafeExec::SAFE_CONSTANTS[receiver] ||= {})[name] = proc do
    receiver.instance_eval do
      remove_const name
      const_set name, yield
    end
  end
end

# Safely execute a piece of code
# @param name [String] Name of the code if it needs to be removed
# @param value [Proc] code to execute
def safe_code(name, &value)
  receiver = value.binding.receiver
  receiver = Object if receiver.class == Object
  return (SafeExec::SAFE_CODE[receiver] ||= {})[name] = value
end
