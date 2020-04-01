#encoding: utf-8

module Yuki
  # Some util functions that help Sprite generation
  # @author Nuri Yuri
  module Utils
    # The default sprite class
    Default_Sprite_Class = ::Sprite
    # The default cache where image are loaded
    Default_Sprite_Cache_Name = :interface
    # The default sprite parameters
    Default_Sprite_Params = {}
    module_function
    # Create a background sprite
    # @param viewport [Viewport] the viewport where the sprite is shown
    # @param image_name [String] the name of the image in the right Graphics path
    # @param cache_name [Symbol] the cache where to load the image
    # @param sprite_class [Class] the sprite class to use to generate the sprite
    # @return [#bitmap]
    def create_background(viewport, image_name, cache_name = :interface, sprite_class = Default_Sprite_Class)
      sprite = sprite_class.new(viewport)
      sprite.bitmap = RPG::Cache.public_send(cache_name, image_name)
      sprite.z = 0
      return sprite
    end
    # Create a sprite
    # @param viewport [Viewport] the viewport where the sprite is shown
    # @param image_name [String] the name of the image in the right Graphics path
    # @param x [Integer] the x position of the sprite
    # @param y [Integer] the y position of the sprite
    # @param z [Integer] the z superiority of the sprite
    # @param sprite_params [Hash] the sprite parameters
    #   Structure of the parameters
    #     sprite_class: opt Class # The classe used to generate the sprite
    #     cache_name: opt Symbol # The cache where to load the sprite image
    #     ox: opt Integer # The offset x of the bitmap contents
    #     oy: opt Integer # The offset y of the bitmap contents
    #     src_rect: opt Array<Integer> # The src_rect.set parameters
    #     src_rect_div: opt Array<Integer> # the same in division of the bitmap and multiple of division
    #     ox_div: opt Integer # The division of width of the bitmap to get the ox
    #     oy_div: opt Integer # The division of height of the bitmap to get the oy
    #     ox_mul: opt Integer # The number of time the ox is multiplicated
    #     oy_mul: opt Integer # The number of time the oy is multiplicated
    #     tone: opt Array<Integer> # the tone.set parameters
    #     color: opt Array<Integer> # the color.set parameters
    #     opacity: opt Integer # the opacity of the sprite
    #     mirror: opt Boolean # the mirror property of the sprite
    # @return [#bitmap]
    def create_sprite(viewport, image_name, x, y, z, sprite_params = Default_Sprite_Params)
      sprite_class = sprite_params.fetch(:sprite_class, Default_Sprite_Class)
      cache_name = sprite_params.fetch(:cache_name, Default_Sprite_Cache_Name)
      sprite = sprite_class.new(viewport)
      sprite.bitmap = RPG::Cache.public_send(cache_name, image_name)
      sprite.z = z
      sprite.x = x
      sprite.y = y
      parse_sprite_params(sprite, sprite_params)
      return sprite
    end
    # Parse the parameters of the sprite
    # @param sprite [#bitmap]
    # @param sprite_params [Hash] see #create_sprite
    def parse_sprite_params(sprite, sprite_params)
      val = sprite_params.fetch(:ox, nil)
      sprite.ox = val if val
      val = sprite_params.fetch(:oy, nil)
      sprite.oy = val if val
      val = sprite_params.fetch(:src_rect, nil)
      sprite.src_rect.set(*val) if val
      val = sprite_params.fetch(:src_rect_div, nil)
      parse_offset_div(sprite, sprite_params)
      parse_src_rect_div(sprite, val) if val
      val = sprite_params.fetch(:tone, nil)
      sprite.tone.set(*val) if val
      val = sprite_params.fetch(:color, nil)
      sprite.color.set(*val) if val
      val = sprite_params.fetch(:opacity, nil)
      sprite.opacity = val if val
      val = sprite_params.fetch(:mirror, nil)
      sprite.mirror = val if val
    end
    # Parse the offset x/y parameters of the sprite
    # @param sprite [#bitmap]
    # @param sprite_params [Hash] see #create_sprite
    def parse_offset_div(sprite, sprite_params)
      val = sprite_params.fetch(:ox_div, nil)
      sprite.ox = sprite.bitmap.width / val if val && val != 0
      val = sprite_params.fetch(:oy_div, nil)
      sprite.oy = sprite.bitmap.height / val if val && val != 0
      val = sprite_params.fetch(:ox_mul, nil)
      sprite.ox *= val if val
      val = sprite_params.fetch(:oy_mul, nil)
      sprite.oy *= val if val
    end
    # Parse the src_rect_div parameters of the sprite
    # @param sprite [#bitmap]
    # @param src_rect_info [Array]
    def parse_src_rect_div(sprite, src_rect_info)
      width = sprite.bitmap.width
      height = sprite.bitmap.height
      div_width = src_rect_info.fetch(2)
      div_height = src_rect_info.fetch(3)
      sprite.src_rect.set(
        src_rect_info.fetch(0) * width / div_width,
        src_rect_info.fetch(1) * height / div_height,
        width / div_width,
        height / div_height
      )
    end
  end
end
