module Yuki
  # Object that describe a building on the Map as a Particle
  # @author Nuri Yuri
  class Building_Object
    # If the building is disposed
    # @return [Boolean]
    attr_reader :disposed
    # The building sprite
    # @return [Sprite]
    attr_accessor :sprite
    # Create a new Building_Object
    # @param image [String] name of the image in Graphics/Autotiles/
    # @param x [Integer] x coordinate of the building
    # @param y [Integer] y coordinate of the building
    # @param oy [Integer] offset y coordinate of the building in native resolution pixel
    def initialize(image, x, y, oy)
      @sprite = ::Sprite.new(Particles.viewport, true)
      @sprite.bitmap = ::RPG::Cache.autotile(image)
      @sprite.oy = @sprite.bitmap.height - oy - 16
      @x = (x + MapLinker.get_OffsetX) * 16
      @y = (y + MapLinker.get_OffsetY) * 16
      @real_y = (y + MapLinker.get_OffsetY) * 128
      @map_id = $game_map.map_id
      update
    end

    # Update the building position (x, y, z)
    def update
      return if disposed?
      return dispose if @map_id != $game_map.map_id

      dx = $game_map.display_x / 8
      dy = $game_map.display_y / 8
      @sprite.x = (@x - dx)
      @sprite.y = (@y - dy)
      @sprite.z = (@real_y - $game_map.display_y + 4) / 4 + 94
    end

    # Dispose the building
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
