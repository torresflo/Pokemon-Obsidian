require 'zlib'
require 'socket'

# Detecting the PokemonSDK path
PSDK_PATH = 'path to pokemonsdk folder'

class Object
  include LiteRGSS
  # Load data from a file
  # @param filename [String] name of the file where to load the data
  # @return [Object]
  def load_data(filename)
    File.open(filename) { |f| return Marshal.load(f) }
  end

  # Save data to a file
  # @param data [Object] data to save to a file
  # @param filename [String] name of the file
  def save_data(data, filename)
    File.open(filename, 'wb') { |f| Marshal.dump(data, f) }
    return nil
  end
end

class Sprite < LiteRGSS::Sprite
end

class Bitmap < LiteRGSS::Bitmap
end

class Viewport < LiteRGSS::Viewport
end

class Shader < LiteRGSS::Shader
end

class Text < LiteRGSS::Text
end

class ShaderedSprite < LiteRGSS::ShaderedSprite
end

class Color < LiteRGSS::Color
end

class Tone < LiteRGSS::Tone
end

class Table < LiteRGSS::Table
end

class Table32 < LiteRGSS::Table32
end

module Input
  extend LiteRGSS::Input
  include LiteRGSS::Input
end

module Graphics
  extend LiteRGSS::Graphics
  include LiteRGSS::Graphics
end

module Mouse
  extend LiteRGSS::Mouse
  include LiteRGSS::Mouse
end
