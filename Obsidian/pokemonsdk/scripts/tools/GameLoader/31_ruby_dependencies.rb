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

# Class that holds every methods of a symbol
class Symbol
  # In case of using + operator on symbol, return self
  # @return [self]
  def +(_other)
    return self
  end
end

# Class that helps doing stuff related to Directories
class Dir
  # Make a new dir by following the path
  # @param path [String] the new path to create
  # @example Dir.mkdir!("a/b/c") will create a, a/b and a/b/c.
  def self.mkdir!(path)
    total_path = ''
    path.split(%r{[/\\]}).each do |dirname|
      next if dirname.empty?

      total_path << dirname
      Dir.mkdir(total_path) unless Dir.exist?(total_path)
      total_path << '/'
    end
  end
end

# Load data from a file and convert its string to UTF-8
# @param filename [String] name of the file where to load the data
# @return [Object]
def load_data_utf8(filename)
  unless PSDK_CONFIG.release? && filename.start_with?('Data/')
    File.open(filename) do |f|
      return Marshal.load(f, proc { |o| o.class == String ? o.force_encoding(Encoding::UTF_8) : o })
    end
  end
  return load_data(filename, true)
end

# Force string to UTF-8
# @param str [String]
# @return [String] str with UTF-8 encoding
def _utf8(str)
  return str.force_encoding(Encoding::UTF_8)
end
