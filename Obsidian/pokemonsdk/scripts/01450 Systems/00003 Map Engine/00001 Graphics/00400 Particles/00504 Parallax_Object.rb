module Yuki
  # Object that describe a parallax as a particle
  # @author Nuri Yuri
  class Parallax_Object
    # If the parallax is disposed
    # @return [Boolean]
    attr_reader :disposed
    # The parallax sprite
    # @return [Sprite]
    attr_accessor :sprite
    # the factor that creates an automatic offset in x
    # @return [Numeric]
    attr_accessor :factor_x
    # the factor that creates an automatic offset in y
    # @return [Numeric]
    attr_accessor :factor_y
    # Creates a new Parallax_Object
    # @param image [String] name of the image in Graphics/Pictures/
    # @param x [Integer] x coordinate of the parallax from the first pixel of the Map (16x16 tiles /!\)
    # @param y [Integer] y coordinate of the parallax from the first pixel of the Map (16x16 tiles /!\)
    # @param z [Integer] z superiority in the tile viewport
    # @param zoom_x [Numeric] zoom_x of the parallax
    # @param zoom_y [Numeric] zoom_y of the parallax
    # @param opacity [Integer] opacity of the parallax (0~255)
    # @param blend_type [Integer] blend_type of the parallax (0, 1, 2)
    def initialize(image, x, y, z, zoom_x = 1, zoom_y = 1, opacity = 255, blend_type = 0)
      @sprite = ::Sprite.new(Particles.viewport, true)
      @sprite.z = z
      @sprite.zoom_x = zoom_x
      @sprite.zoom_y = zoom_y
      @sprite.opacity = opacity
      @sprite.blend_type = blend_type
      @sprite.bitmap = ::RPG::Cache.picture(image)
      @x = x + MapLinker.get_OffsetX * 16
      @y = y + MapLinker.get_OffsetY * 16
      @factor_x = 0
      @factor_y = 0
      @map_id = $game_map.map_id
      update
    end

    # Update the parallax position
    def update
      return if disposed?
      return dispose if @map_id != $game_map.map_id

      dx = $game_map.display_x / 8
      dy = $game_map.display_y / 8
      @sprite.x = (@x - dx) + (@factor_x * dx)
      @sprite.y = (@y - dy) + (@factor_y * dy)
    end

    # Dispose the parallax
    def dispose
      return if disposed?

      @sprite.dispose unless @sprite.disposed?
      @sprite = nil
      @disposed = true
      Yuki::Particles.clean_stack
    end

    alias disposed? disposed
  end
end
