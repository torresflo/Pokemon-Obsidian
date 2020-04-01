#encoding: utf-8

# Module that defines User Interfaces during GamePlay
module GamePlay
  # The Sprite functions for GamePlay interface.
  #
  # When sprite are generated with this module methods, they are automatically disposed
  # This module add methods to generate sprite without writting the boring stuff
  #
  # @deprecated Do not use the functions of this module anymore please.
  # @author Nuri Yuri
  module Sprites
    # Initialize the dispose stack. This method should be called otherwise the methods wont work
    def _init_sprites
      return if @viewport_to_dispose
      @viewport_to_dispose = Array.new
    end
    # Create a viewport
    # @param args [Array] parameter of the viewport see Viewport.create
    # @return [Viewport]
    def view(*args)
      _view = ::Viewport.create(*args)
      @viewport_to_dispose << _view
      return _view
    end
    # Set the default viewport for the sprite generation
    # @param _view [Viewport] the viewport to set as default viewport
    # @return [Viewport] _view
    def select_view(_view)
      @__selected_viewport = _view if _view == nil or _view.class == ::Viewport
      return _view
    end
    # Create a background sprite (x, y, z) = 0
    # @param image_name [String, nil] the name of the image in the dedicated cache (default in Graphics/Interface/)
    # @param cache_name [Symbol] the RPG::Cache method to call to get the Bitmap
    # @note if image_name = nil, this method create a background with no bitmap
    # @return [Sprite]
    def background(image_name, cache_name = :interface)
      cc 0x1
      puts "Warning : background() is deprecated."
      cc 0x7
      puts caller[0]
      sprite = Sprite.new(@__selected_viewport)
      sprite.x = sprite.y = sprite.z = 0
      sprite.bitmap = ::RPG::Cache.send(cache_name, image_name) if image_name
      #@sprite_to_dispose << sprite
      return sprite
    end
    # Create a new sprite
    # @param image_name [String] the name of the image in the dedicated cache (default in Graphics/Interface/)
    # @param x [Integer] the x coordinate of the sprite in the view
    # @param y [Integer] the y coordinate of the sprite in the view
    # @param z [Integer] the z superiority of the sprite
    # @param hash [Hash, nil] the sprite parameter, see Yuki::Utils.parse_sprite_params
    # @note hash has two key in addition of the normal keys :
    #     cache_name: opt Symbol # The RPG::Cache function symbol to call to get the Bitmap
    #     bitmap: opt Bitmap # the bitmap use instead of an image from the cache
    #   
    #   If image_name = nil, the bitmap is not loaded from cache
    # @return [Sprite]
    def sprite(image_name, x, y, z, hash = nil)
      cc 0x1
      puts "Warning : sprite() is deprecated."
      cc 0x7
      puts caller[0]
      cache_name = hash ? hash.fetch(:cache_name, :interface) : :interface
      sprite = Sprite.new(@__selected_viewport)
      sprite.x = x
      sprite.y = y
      sprite.z = z
      sprite.bitmap = ::RPG::Cache.send(cache_name, image_name) if image_name
      sprite.bitmap = hash[:bitmap] if hash and hash[:bitmap]
      #@sprite_to_dispose << sprite
      ::Yuki::Utils.parse_sprite_params(sprite, hash) if hash
      return sprite
    end
    # Create a new sprite sheet
    # @param image_name [String] the name of the image in the dedicated cache (default in Graphics/Interface/)
    # @param x [Integer] the x coordinate of the sprite in the view
    # @param y [Integer] the y coordinate of the sprite in the view
    # @param z [Integer] the z superiority of the sprite
    # @param hash [Hash, nil] the sprite parameter, see Yuki::Utils.parse_sprite_params
    # @note hash has two key in addition of the normal keys :
    #     cache_name: opt Symbol # The RPG::Cache function symbol to call to get the Bitmap
    #     bitmap: opt Bitmap # the bitmap use instead of an image from the cache
    #   
    #   If image_name = nil, the bitmap is not loaded from cache
    # @return [Sprite]
    def sprite_sheet(image_name, x, y, z, nb_x, nb_y, hash = nil)
      cc 0x1
      puts "Warning : sprite_sheet() is deprecated."
      cc 0x7
      puts caller[0]
      cache_name = hash ? hash.fetch(:cache_name, :interface) : :interface
      sprite = SpriteSheet.new(@__selected_viewport, nb_x, nb_y)
      sprite.x = x
      sprite.y = y
      sprite.z = z
      sprite.bitmap = ::RPG::Cache.send(cache_name, image_name) if image_name
      sprite.bitmap = hash[:bitmap] if hash and hash[:bitmap]
      #@sprite_to_dispose << sprite
      ::Yuki::Utils.parse_sprite_params(sprite, hash) if hash
      return sprite
    end
    # Automatically dispose every sprite, bitmap and viewport generated with this module
    def dispose_sprites
      element = nil
      return unless @viewport_to_dispose
      #@bitmap_to_dispose.each { |element| element.dispose }
      #@sprite_to_dispose.each { |element| element.dispose }
      @viewport_to_dispose.each { |element| element.dispose }
    end
=begin
    # Return the start index of a list to draw in a surface
    # @param index [Integer] the real index in the list
    # @param list [#size] the list of thing to draw
    # @param middle_index [Integer] the visual middle index, ex 9 option shown => 4, 7 option shown => 3
    # @return [Integer] the start index in the list
    def get_list_start_index(index, list, middle_index)
      middle_end = list.size - middle_index - 1
      if(middle_end >= middle_index)
        if index >= middle_end
          return middle_end - middle_index
        elsif index >= middle_index
          return index - middle_index
        end
      end
      return 0
    end
=end
  end
end
