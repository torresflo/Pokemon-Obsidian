module BattleUI
  # Sprite showing a cursor (being animated)
  class Cursor < ShaderedSprite
    # Get the origin x
    attr_reader :origin_x
    # Get the origin y
    attr_reader :origin_y
    # Get the target x
    attr_reader :target_x
    # Get the target y
    attr_reader :target_y
    # Create a new cursor
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport)
      @origin_x = 0
      @origin_y = 0
      @target_x = 0
      @target_y = 0
    end

    # Register the positions so the cursor can animate itself
    def register_positions
      @origin_x = x
      @origin_y = y
      @target_x = x - 5
      @target_y = y
    end

    # Update the sprite
    def update
      @animation&.update
    end

    # Set the visibility
    # @param visible [Boolean]
    def visible=(visible)
      return if self.visible == visible

      super
      stop_animation unless visible
      start_animation if visible
    end

    # Make call work as expected for animation resolver
    alias call send

    # Stops the animation
    def stop_animation
      @animation = nil
    end

    # Create and start the cursor animation
    # @return [Yuki::Animation::TimedLoopAnimation]
    def start_animation
      root = Yuki::Animation::TimedLoopAnimation.new(1)
      root.play_before(Yuki::Animation.move(0.5, self, :origin_x, :origin_y, :target_x, :target_y))
      root.play_before(Yuki::Animation.move(0.5, self, :target_x, :target_y, :origin_x, :origin_y))
      root.resolver = self
      root.start
      return @animation = root
    end
  end
end
