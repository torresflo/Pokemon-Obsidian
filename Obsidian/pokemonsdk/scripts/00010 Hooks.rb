# Module responsive of adding the Hook functionality to a class and its childs
#
# How to use it:
#   # 1. Include the Hooks module to your class so exec_hooks become visible (and it's possible to register a hook)
#   include Hooks
#
#   # 2. Make a method that supports hooks
#   def my_method(params)
#     exec_hooks(NameOfTheClass, :name_of_prehook, binding) # Not mandatory
#     # do some stuff
#     exec_hooks(NameOfTheClass, :name_of_posthook, binding) # Not mandatory
#     return normal_return
#   rescue Hooks::ForceReturn => e
#     return e.data # What the hooks forced to return
#   end
#
#   # 3. To register a hook call the function from Hooks
#   Hooks.register(NameOfTheClass, :name_of_the_hook) do |hook_binding|
#     # Do something with self (object that called the hook) and hook_binding current binding
#   end
module Hooks
  # Exception that help managing overwritten return from Hooks
  class ForceReturn < StandardError
    # Data that should be returned
    attr_accessor :data
    # Constant value for hooks functionality
    CONST = new('Return forced')
  end
  # Function that execute the hooks
  # @param klass [Class] class containing the hook information
  # @param name [Symbol] name of the hook list
  # @param method_binding [Binding] binding of the method so the hook can modify locals
  # @raise [ForceReturn]
  def exec_hooks(klass, name, method_binding)
    hooks = klass.instance_variable_get(:@__hooks)&.[](name)
    hooks&.each do |hook|
      instance_exec(method_binding, &hook)
    end
  end

  # Function that force the return from the hook
  # @param object [Object] object to return
  def force_return(object)
    ForceReturn::CONST.data = object
    raise ForceReturn::CONST
  end

  class << self
    # Function that register a hook
    # @param klass [Class] class containing the hook information
    # @param name [Symbol] name of the hook list
    # @param block [Proc] actuall hook
    # @yield [hook_binding] hook called when requested
    # @yieldparam hook_binding [Binding] binding from the calling method
    def register(klass, name, &block)
      hooks = (klass.instance_variable_get(:@__hooks)[name] ||= [])
      hooks << block
    rescue NoMethodError
      raise 'Hooks was not included to that class!'
    end

    # Function called when Hooks is included
    # @param klass [Class] klass receiving the hooks
    def included(klass)
      klass.instance_variable_set(:@__hooks, {})
    end
  end
end

=begin
# Hook test:

class MyClass
  include Hooks

  def my_method(a, b, what)
    exec_hooks(MyClass, :pre_my_method, binding)
    ret = a * b
    exec_hooks(MyClass, :post_my_method, binding)
    return ret
  rescue Hooks::ForceReturn => e
    return e.data
  end
end

Hooks.register(MyClass, :pre_my_method) do |hook_binding|
  puts "Calling pre_my_method for #{self}"
  force_return(hook_binding.local_variable_get(:a)) if hook_binding.local_variable_get(:what) == :return_a
end

Hooks.register(MyClass, :pre_my_method) do |hook_binding|
  hook_binding.local_variable_set(:a, hook_binding.local_variable_get(:a).to_i)
  hook_binding.local_variable_set(:b, hook_binding.local_variable_get(:b).to_i)
end

Hooks.register(MyClass, :post_my_method) do |hook_binding|
  puts "Calling post_my_method for #{self}"
  hook_binding.local_variable_set(:ret, hook_binding.local_variable_get(:ret) * 2) if hook_binding.local_variable_get(:what) == :double
end

object = MyClass.new
puts 'Force return did:', object.my_method('wololo', nil, :return_a)
puts '.to_i made it work:', object.my_method('wololo', nil, nil)
puts 'post_hook changed return:', object.my_method(5, 6, :double)
puts 'normal behaviour:', object.my_method(5, 6, nil)
=end
