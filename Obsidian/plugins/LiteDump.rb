module LiteDump
  module_function
  
  def load(obj)
    references = []
    load_object(obj, references)
  end
  
  def load_object(obj, references)
    return obj.clone if obj.is_static? || obj.is_a?(Numeric)
    return load_string(obj, references) if obj.is_a?(String)
    if obj.is_a?(Hash)
      if obj[:"@class@"]
        return create_object(obj, references)
      elsif obj[:"@module@"]
        return load_module(obj, references)
      end
      return load_hash(obj, references)
    end
    load_array(obj, references)
  end
  
  def load_array(obj, references)
    references << (arr = Array.new(obj.size))
    obj.each_with_index do |value, index|
      arr[index] = load_object(value, references)
    end
    arr
  end
  
  def load_hash(obj, references)
    references << (hash = {})
    obj.each do |key, value|
      hash[load_object(key, references)] = load_object(value, references)
    end
    hash
  end
  
  def load_string(obj, references)
    match = obj.match(/^\?ref:([0-9]+)\?$/)
    match ? references[match[1].to_i] : obj.clone
  end
  
  def load_module(obj, references)
    mod = obj[:"@module@"]
    references << mod
    if (constants = obj[:constants])
      constants.each do |constant, value|
        value = load_object(value, references)
        mod.const_set(constant, value) unless value.is_a?(Module) and mod.const_defined?(constant)
      end
    end
    if (ivar = obj[:ivar])
      set_object_ivar(mod, ivar, references)
    end
    mod
  end
  
  def create_object(obj, references)
    obj = obj.clone
    klass = obj.delete(:"@class@")
    new_obj = klass.allocate
    set_object_ivar(new_obj, obj, references)
    new_obj
  end
  
  def set_object_ivar(obj, ivar, references)
    ivar.each do |ivname, value|
      obj.instance_variable_set(:"@#{ivname}", load_object(value, references))
    end
  end
  
  def dump(obj, io = nil)
    references = []
    io ||= ''
    io << 'lload('
    dump_with_references(obj, io, references)
    io << ")\r\n"
    io
  end

  def dump_with_references(obj, io, references)
    if obj.is_a?(Hash)
      dump_hash(obj, io, references)
    elsif obj.is_a?(Array)
      dump_array(obj, io, references)
    else
      dump_obj(obj, io, references)
    end
    io
  end

  def write_object(obj, io, references)
    if obj.is_static?
      io << obj.inspect
    elsif (ref = references.index(obj.object_id))
      io << "\"?ref:#{ref}?\""
    else
      dump_with_references(obj, io, references)
    end
  end

  def dump_hash(obj, io, references)
    raise 'Cannot dump child class of Hash' if obj.class != Hash
    references << obj.object_id
    io << '{ '
    first = true
    obj.each do |key, value|
      if first
        first = false
      else
        io << ', '
      end
      if key.is_a?(Symbol)
        io << key.inspect[1..-1] << ': '
      else
        write_object(key, io, references)
        io << ' => '
      end
      write_object(value, io, references)
    end
    io << ' }'
  end

  def dump_array(obj, io, references)
    raise 'Cannot dump child class of Array' if obj.class != Array
    references << obj.object_id
    io << '['
    first = true
    obj.each do |value|
      if first
        first = false
      else
        io << ', '
      end
      write_object(value, io, references)
    end
    io << ']'
  end

  def dump_obj(obj, io, references)
    if obj.is_static?
      io << obj.inspect
    elsif obj.is_a?(Numeric) || obj.is_a?(String)
      io << obj.inspect
    elsif obj.is_a?(Module)
      save_module(obj, io, references)
    else
      references << obj.object_id
      io << '{ "@class@": ' << obj.class.inspect << ', '
      dump_obj_ivar(obj, io, references)
      io << ' }'
    end
  end
  
  def save_module(obj, io, references)
    references << obj.object_id
    io << '{ "@module@": ' << obj.inspect << ', constants: { '
    first = true
    obj.constants.each do |constant|
      if first
        first = false
      else
        io << ', '
      end
      io << constant.to_s << ': '
      write_object(obj.const_get(constant), io, references)
    end
    io << ' }, ivar: { '
    dump_obj_ivar(obj, io, references)
    io << ' } }'
  end

  def dump_obj_ivar(obj, io, references)
    first = true
    obj.instance_variables.each do |ivname|
      if first
        first = false
      else
        io << ', '
      end
      io << ivname[1..-1] << ': '
      write_object(obj.instance_variable_get(ivname), io, references)
    end
  end
end

class Object
  STATIC_OBJECT = [Symbol, NilClass, TrueClass, FalseClass].freeze
  def is_static?
    return true if STATIC_OBJECT.include?(self.class)
    return true if is_a?(Integer) && (object_id & 0x01 == 0x01)
    false
  end
  
  def to_lite_dump(io = nil)
    LiteDump.dump(self, io)
  end
  
  def lload(obj)
    LiteDump.load(obj)
  end
end