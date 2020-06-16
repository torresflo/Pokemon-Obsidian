module LiteRGSS
  class Bitmap
    # All the accepted bitmap extensions
    Exts = %w[.png .PNG .jpg .JPG]
    # Original Bitmap.new function
    alias initialize_copy initialize
    # Initialize the bitmap, add automatically the extension to the filename
    # @param filename [String] Filename or FileData
    # @param from_mem [Boolean] load the file from memory (then filename is FileData)
    def initialize(filename, from_mem = false)
      if from_mem
        initialize_copy(filename, from_mem)
      else
        Exts.each do |i|
          filename2 = filename+i
          if File.exist?(filename2)
            return initialize_copy(filename2)
          end
        end
        initialize_copy(filename)
      end
      initialize_copy(16, 16) if width == 0 || height == 0
    end
    class << self
      # Encode all the PNG files of a directory to LodePNG files
      # @param path [String] the path to the directory
      def encode_path(path)
        path += '/' if path[-1] != '/'
        Dir["#{path}*.png"].each do |filename|
          bmp = Bitmap.new(filename)
          bmp.to_png_file(filename)
          bmp.dispose
          puts "#{filename} encoded..."
        end
      end
    end
    # Clear the bitmap surface
    def clear
      clear_rect(0, 0, width, height)
    end
  end
end
