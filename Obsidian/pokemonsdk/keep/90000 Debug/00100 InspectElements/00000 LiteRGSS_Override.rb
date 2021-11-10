return unless PSDK_CONFIG.debug?

module LiteRGSS
  class Viewport
    include Hooks

    alias old_initialize initialize
    def initialize(*args, &block)
      old_initialize(*args, &block)
      exec_hooks(Viewport, :initialize, binding)
    end

    alias old_dispose dispose
    def dispose
      exec_hooks(Viewport, :dispose, binding)
      old_dispose
    end

  end

  class Window
    include Hooks

    alias old_initialize initialize
    def initialize(*args, &block)
      old_initialize(*args, &block)
      exec_hooks(Window, :initialize, binding)
    end

    alias old_dispose dispose
    def dispose
      exec_hooks(Window, :dispose, binding)
      old_dispose
    end
  end

  class Sprite
    include Hooks

    alias old_initialize initialize
    def initialize(*args, &block)
      old_initialize(*args, &block)
      exec_hooks(Sprite, :initialize, binding)
    end

    alias old_dispose dispose
    def dispose
      exec_hooks(Sprite, :dispose, binding)
      old_dispose
    end
  end

  class Text
    include Hooks

    alias old_initialize initialize
    def initialize(*args, &block)
      old_initialize(*args, &block)
      exec_hooks(Text, :initialize, binding)
    end

    alias old_dispose dispose
    def dispose
      exec_hooks(Text, :dispose, binding)
      old_dispose
    end
  end

  class Bitmap
    attr_reader :filename
    alias old_initialize initialize
    def initialize(filename, from_mem = nil)
      old_initialize(filename, from_mem)
      @filename = from_mem.nil? ? filename : nil
    end
  end
end
