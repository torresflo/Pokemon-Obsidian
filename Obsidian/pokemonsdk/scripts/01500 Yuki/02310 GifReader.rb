module Yuki
  class GifReader
    class << self
      # Create a new GifReader from archives
      # @param filename [String] name of the gif file, including the .gif extension
      # @param cache_name [Symbol] name of the cache where to load the gif file
      # @param hue [Integer] 0 = normal, 1 = shiny for Pokemon battlers
      # @return [GifReader, nil]
      def create(filename, cache_name, hue = 0)
        gif_data = RPG::Cache.send(cache_name, filename, hue)
        return log_error("Failed to load GIF: #{cache_name} => #{filename}") && nil unless gif_data

        return GifReader.new(gif_data, true)
      end

      # Check if a Gif Exists
      # @param filename [String] name of the gif file, including the .gif extension
      # @param cache_name [Symbol] name of the cache where to load the gif file
      # @param hue [Integer] 0 = normal, 1 = shiny for Pokemon battlers
      # @return [Boolean]
      def exist?(filename, cache_name, hue = 0)
        cache_exist = :"#{cache_name}_exist?"
        return RPG::Cache.send(cache_exist, filename) if hue == 0

        return RPG::Cache.send(cache_exist, filename, hue)
      end
    end

    alias old_update update
    # Update function that takes in account framerate of the game
    # @param bitmap [LiteRGSS::Bitmap] texture that receive the update
    # @return [self]
    def update(bitmap)
      old_update(bitmap) unless Graphics::FPSBalancer.global.skipping? && @was_updated
      @was_updated = true
      return self
    end
  end
end
