module Yuki
  # Sprite with move_to command a self "animation"
  # @author Nuri Yuri
  class Sprite < Sprite
    # If the sprite has a self animation
    # @return [Boolean]
    attr_accessor :animated
    # If the sprite is moving
    # @return [Boolean]
    attr_accessor :moving
    # Update sprite (+move & animation)
    def update
      update_animation(false) if @animated
      update_position if @moving
      super
    end
    # Move the sprite to a specific coordinate in a certain amount of frame
    # @param x [Integer] new x Coordinate
    # @param y [Integer] new y Coordinate
    # @param nb_frame [Integer] number of frame to go to the new coordinate
    def move_to(x, y, nb_frame)
      @moving = true
      @move_frame = nb_frame
      @move_total = nb_frame
      @new_x = x
      @new_y = y
      @del_x = self.x - x
      @del_y = self.y - y
    end
    # Update the movement
    def update_position
      @move_frame-=1
      @moving = false if @move_frame == 0
      self.x = @new_x + (@del_x * @move_frame) / @move_total
      self.y = @new_y + (@del_y * @move_frame) / @move_total
    end
    # Start an animation
    # @param arr [Array<Array(Symbol, *args)>] Array of message
    # @param delta [Integer] Number of frame to wait between each animation message
    def anime(arr,delta = 1)
      @animated = true
      @animation = arr
      @anime_pos = 0
      @anime_delta = delta
      @anime_count = 0
    end
    # Update the animation
    # @param no_delta [Boolean] if the number of frame to wait between each animation message is skiped
    def update_animation(no_delta)
      unless no_delta
        @anime_count += 1
        return if(@anime_delta > @anime_count)
        @anime_count = 0
      end
      anim = @animation[@anime_pos]
      self.send(*anim) if anim[0] != :send and anim[0].class == Symbol
      @anime_pos += 1
      @anime_pos = 0 if @anime_pos >= @animation.size
    end
    # Force the execution of the n next animation message
    # @note this method is used in animation message Array
    # @param n [Integer] Number of animation message to execute
    def execute_anime(n)
      @anime_pos += 1
      @anime_pos = 0 if @anime_pos >= @animation.size
      n.times do
        update_animation(true)
      end
      @anime_pos -= 1
    end
    # Stop the animation
    # @note this method is used in the animation message Array (because animation loops)
    def stop_animation
      @animated = false
    end
    # Change the time to wait between each animation message
    # @param v [Integer]
    def anime_delta_set(v)
      @anime_delta = v
    end
    # Security patch
    def eval

    end
    alias class_eval eval
    alias instance_eval eval
    alias module_eval eval
#    alias __send__ eval
  end
end
