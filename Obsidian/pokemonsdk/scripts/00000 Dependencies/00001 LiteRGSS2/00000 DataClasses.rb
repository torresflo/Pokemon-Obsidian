raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Class that describes RGBA colors in integer scale (0~255)
class Color < LiteRGSS::Color
end

# Class that describe tones (added/modified colors to the surface)
class Tone < LiteRGSS::Tone
end

# Class that defines a rectangular surface of a Graphical element
class Rect < LiteRGSS::Rect
end

# Class that stores an image loaded from file or memory into the VRAM
class Texture < LiteRGSS::Bitmap
  # List of supported extensions
  SUPPORTED_EXTS = %w[.png .PNG .jpg]
  # Initialize the texture, add automatically the extension to the filename
  # @param filename [String] Filename or FileData
  # @param from_mem [Boolean] load the file from memory (then filename is FileData)
  def initialize(filename, from_mem = nil)
    if from_mem || File.exist?(filename)
      super
    elsif (new_filename = SUPPORTED_EXTS.map { |e| filename + e }.find { |f| File.exist?(f) })
      super(new_filename)
    else
      super(16, 16)
    end
  end
end

# Class that stores an image loaded from file or memory into the VRAM
# @deprecated Please stop using bitmap to talk about texture!
class Bitmap < LiteRGSS::Bitmap
  # Create a new Bitmap
  def initialize(*args)
    log_error('Please stop using Bitmap!')
    super
  end
end

# Class that is dedicated to perform Image operation in Memory before displaying those operations inside a texture
class Image < LiteRGSS::Image
  # Do nothing
end
