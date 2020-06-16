module Yuki
  # A basic animation player
  # @author Nuri Yuri
  class Basic_Animator
    # Member that tell if the SE doesn't play
    # @return [Boolean]
    attr_accessor :se_locked
    # @return [Hash] parameters passed to the animation
    attr_reader :parameters
    # Create a new animator
    # @param animation [Hash{global: Array, origin: Array, target: Array}] 
    #    The array are list of message send to the animator
    #    :global is the animation that doesn't play with any sprite as source
    #    :origin is the animation on the launcher (of the animation/move)
    #    :target is the animation on a target
    # @param origin [Sprite] the origin sprite
    # @param targets [Array<Sprite>] a list of target sprites
    def initialize(animation, origin, *targets)
      @global = animation[:global]
      @origin = animation[:origin]
      @target = animation[:target]
      @parameters = {}
      @indexes = Array.new(targets.size, 0)
      @global_index = 0
      @origin_index = 0
      @origin_sprite = origin
      @target_sprites = targets
      @sprites = { nil.__id__ => [], (origin.__id__ + 1) => [] }
      targets.each { |target| @sprites[target.__id__] = [] }
      @counter = 0
      @END = false
    end

    # Update the animation
    # @return [Boolean] false if the animation has ended
    def update
      return false if @END
      @object = nil
      @sprite_stack = @sprites[nil.__id__]
      @global_index = update_animation(@global, @global_index) if @global
      @object = @origin_sprite
      @sprite_stack = @sprites[@origin_sprite.__id__ + 1]
      @origin_index = update_animation(@origin, @origin_index) if @origin
      @target_sprites.each_index do |i|
        @object = @target_sprites[i]
        @sprite_stack = @sprites[@object.__id__]
        @indexes[i] = update_animation(@target, @indexes[i])
      end
      @counter += 1
      dispose if @END
      return true
    end

    # Update an animation
    # @param array [Array<Symbol, *args>] list of animation message
    # @param index [Integer] current index of the animation (position in array)
    # @return [Integer] new index of the animation
    def update_animation(array, index)
      object = nil
      while array.size > index
        object = array[index]
        break(index += 1) if object == :synchronize
        break if object[0] == :waitcounter && object[1] > @counter
        send(*object)
        index += 1
      end
      return index
    end

    # Wait until @counter reached value
    # @param value [Integer]
    def waitcounter(value)
    end

    # Spawn a sprite with some properties
    # @param id [Integer] index of the sprite in the stack
    # @param properties [Hash, nil] list of properties usable with Object#apply_property
    def spawn_sprite(id, properties = nil)
      viewport = @object ? @object.viewport : nil
      @sprite_stack[id] = Sprite.new(viewport)
      @sprite_stack[id].apply_property(properties) if properties
    end

    # Auto rotate a sprite, +180° when origin.x > target[0].x
    # @param id [Integer] index of the sprite in the stack
    def auto_rotate(id)
      return if @target_sprites.empty?
      sprite = @sprite_stack[id]
      sprite.angle = 180 if @origin_sprite.x > @target_sprites[0].x
    end

    # Auto mirror a sprite when origin.x > target.x
    # @param id [Integer] index of the sprite in the stack
    def auto_mirror(id)
      return if @target_sprites.empty?
      sprite = @sprite_stack[id]
      sprite.mirror = @origin_sprite.x > @target_sprites[0].x
    end

    # Center a sprite to the middle of the screen/origin/target
    # @param id [Integer] index of the sprite in the stack
    def center(id)
      sprite = @sprite_stack[id]
      if @object
        sprite.x = @object.x + @object.width / 2 - @object.ox
        sprite.y = @object.y + @object.height / 2 - @object.oy
        sprite.z = @object.z + 1
      else
        sprite.x = Graphics.width / 2
        sprite.y = Graphics.height / 2
      end
    end

    # Set the position of the sprite between its origin sprite and a target sprite
    # @param id [Integer] index of the sprite in the stack
    # @param target_id [Integer] id of the target sprite (0, 1, 2, ...)
    # @param perthousand [Integer] the advencement of the sprite between the origin and the targent en thousand of steps
    def advance(id, target_id, perthousand)
      sprite = @sprite_stack[id]
      return unless (other = @target_sprites[target_id])
      if @object.is_a?(::Sprite)
        x = @object.x
        y = @object.y
      else
        x = y = 0
      end
      sprite.x = x + (other.x - x) * perthousand / 100_0
      sprite.y = y + (other.y - y) * perthousand / 100_0
    end

    # Change the object variable
    # @param kind [Symbol] :origin, :sprite (from the sprite_stack), :target
    # @param id [Integer] index of the sprite in the stack or id of the target sprite
    def set_object(kind, id = 0)
      case kind
      when :origin
        @object = @origin_sprite
      when :sprite
        @object = @sprite_stack[id]
      when :target
        @object = @target_sprites[id]
      end
    end

    # Load an animation parameter to object
    # @param name [Symbol] name of the parameter in #parameters
    def load_parameter(name)
      @object = @parameters[name]
    end

    # Load a bitmap using a message sent to RPG::Cache
    # @param id [Integer] index of the sprite in the stack
    # @param args [Array(Symbol, String, Integer)] message sent to RPG::Cache
    def load_bitmap(id, *args)
      sprite = (id ? @sprite_stack[id] : @object)
      sprite.bitmap = RPG::Cache.send(*args)
    end

    # Copy the bitmap of a sprite
    # @param id [Integer] index of the sprite in the stack
    # @param id2 [Integer] index of the copied sprite in the stack
    # @param with_property [Boolean] if the properties of the copied sprite are copied
    def copy_bitmap(id, id2, with_property = false)
      sprite = (id ? @sprite_stack[id] : @object)
      sprite2 = (id2 ? @sprite_stack[id2] : @object)
      sprite.bitmap = sprite2.bitmap
      return unless with_property
      sprite.x = sprite2.x
      sprite.ox = sprite2.ox
      sprite.y = sprite2.y
      sprite.oy = sprite2.oy
      sprite.z = sprite2.z
      sprite.zoom_x = sprite2.zoom_x
      sprite.zoom_y = sprite2.zoom_y
      sprite.mirror = sprite2.mirror
      sprite.angle = sprite2.angle
      sprite.src_rect = sprite2.src_rect
    end

    # Set the ox and oy properties of the sprite in division of its dimensions
    # @param id [Integer] index of the sprite in the stack
    # @param ox [Integer] number of times the width is divided
    # @param oy [Integer] number of times the height is divided
    def set_sprite_origin_div(id, ox, oy)
      sprite = (id ? @sprite_stack[id] : @object)
      sprite.ox = sprite.width / ox
      sprite.oy = sprite.height / oy
    end

    # Calls the #apply_property of a sprite
    # @param id [Integer] index of the sprite in the stack
    # @param properties [Hash] list of properties
    def set_property(id, properties)
      sprite = (id ? @sprite_stack[id] : @object)
      sprite.apply_property(properties) if properties
    end

    # Change the src_rect of a sprite
    # @param id [Integer] index of the sprite in the stack
    # @param args [Array] parameters of src_rect.set
    def set_src_rect(id, *args)
      sprite = (id ? @sprite_stack[id] : @object)
      sprite.src_rect.set(*args)
    end

    # Move a sprite
    # @param id [Integer] index of the sprite in the stack
    # @param add_x [Integer] x movement
    # @param add_y [Integer] y movement
    def move(id, add_x, add_y)
      sprite = (id ? @sprite_stack[id] : @object)
      sprite.x += add_x
      sprite.y += add_y
    end

    # Play a SE
    # @param file [String] name of the SE file in Audio/SE/
    # @param volume [Integer] volume of the SE
    # @param pitch [Integer] pitch of the SE
    def se_play(file, volume = 80, pitch = 100)
      return if @se_locked
      Audio.se_play("Audio/SE/#{file}", volume, pitch)
    end

    # Hide Bars
    def hide_bars
    end

    # Show Bars
    def show_bars
    end

    # Terminate the animation
    #   #update will return false next time its called
    def terminate
      @END = true
    end

    # Tell if the animation has been terminated
    # @return [Boolean]
    def terminated?
      return @END
    end

    # Dispose every generated Sprite in this animation
    def dispose
      @sprites.each_value do |stack|
        stack.each(&:dispose)
        stack.clear
      end
      @sprites.clear
    end
  end
end
