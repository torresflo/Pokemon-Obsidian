module Graphics
  # Time of a frame
  DT = 1 / 60.0
  # Time of a frame + potential error
  DT2 = DT - 1 / 600.0
  # Opposite of the time of a frame
  DTM = - DT

  @last_frame_count = 0

  module_function

  # Return the actual InGame graphics framerate
  # @return [Integer]
  def frame_rate
    return (1 / DT).to_i
  end

  # Set the framerate
  # @param framerate [Numeric] the new framerate
  def frame_rate=(framerate)
    remove_const :DT
    remove_const :DT2
    remove_const :DTM
    const_set :DT, 1 / framerate.to_f
    const_set :DT2, 1 / DT - (0.1 / DT)
    const_set :DTM, -DT
  end

  # Reset the frame counters
  def frame_reset
    @delta_time = @frame_to_skip = 0
    @ruby_time = @current_time = @last_time = @last_second_time = Time.new
    reset_gc_time
    reset_ruby_time
    @last_frame_count = Graphics.frame_count
  end

  # Update the GPU time counters
  # @param delta_time [Numeric] time to add to the gc_accu
  def update_gc_time(delta_time)
    @gc_accu += delta_time
    @gc_count += 1
  end

  # Reset the gc_time counter
  def reset_gc_time
    @gc_count = 0
    @gc_accu = 0.0
  end

  # Update the Ruby time counters
  # @param delta_time [Numeric] time to add to the ruby_accu
  def update_ruby_time(delta_time)
    @ruby_accu += delta_time
    @ruby_count += 1
  end

  # Reset the ruby_time counter
  def reset_ruby_time
    @ruby_count = 0
    @ruby_accu = 0.0
  end

  # Return the current time
  # @return [Time]
  def current_time
    @current_time
  end

  # Returns the last time the Graphics.update was called
  # @return [Time]
  def last_time
    @last_time
  end

  # Update the internal time of Graphics (current time & last time)
  # @note : Will update the FPS texts
  def update_time
    @last_time = @current_time
    @current_time = Time.new
    fps_update
    self.fps_visible = !@ingame_fps_text.visible if !@last_f2 && Input::Keyboard.press?(Input::Keyboard::F2)
    @last_f2 = Input::Keyboard.press?(Input::Keyboard::F2)
    @fps_balancing = !@fps_balancing if !@last_f3 && Input::Keyboard.press?(Input::Keyboard::F3)
    @last_f3 = Input::Keyboard.press?(Input::Keyboard::F3)
  end

  # Manage the frame display (skip frames, show multiple frames)
  def update_manage
    return update_normal unless @fps_balancing
    # Auto skip
    if @frame_to_skip > 0
      @frame_to_skip -= 1
      Graphics.frame_count += 1
      Graphics.update_only_input
      update_time
      return
    end
    # Adding the time Ruby worked (because the GPU will equilibrate its work time)
    @delta_time += (dt = Time.new - @ruby_time)
    update_ruby_time(dt) # Update the Ruby time counters to show the right FPS
    # Estimating frame duration
    t = Time.new
    @update.call
    dt = Time.new - t # Time of the elapsed frame ~0.016
    update_gc_time(dt) # Update the GPU time counters to show the right FPS
    dt -= DT # Substract the time of a constant frame if the result is > 0 we'll need to skip frames
    @delta_time += dt # Adding the difference
    # Try to balance the drawing
    if @delta_time >= DT
      @frame_to_skip = (@delta_time / DT).to_i
      @delta_time -= @frame_to_skip * DT
    elsif @delta_time <= DTM
      #Saving framecount
      while @delta_time <= DTM
        t = Time.new
        update_no_input
        @delta_time += (dt = Time.new - t)
        update_gc_time(dt)
      end
    end
    update_time
    @ruby_time = Time.new
  end

  # Update the graphics without the FPS balancing
  def update_normal
    dt = Time.new - @ruby_time
    update_ruby_time(dt)
    # Estimating frame duration
    t = Time.new
    @update.call
    dt = Time.new - t # Time of the elapsed frame ~0.016
    update_gc_time(dt) # Update the GPU time counters to show the right FPS
    update_time
    @ruby_time = Time.new
  end

  # Update the FPS counter
  def fps_update
    dt = @current_time - @last_second_time
    if dt >= 1
      @last_second_time = @current_time
      @ingame_fps_text.text = "FPS: #{((Graphics.frame_count - @last_frame_count) / dt).ceil}" if dt * 10 >= 1
      @last_frame_count = Graphics.frame_count
      @gpu_fps_text.text = "GPU FPS: #{(@gc_count / @gc_accu).round}" unless @gc_count == 0 || @gc_accu == 0
      @ruby_fps_text.text = "Ruby FPS: #{(@ruby_count / @ruby_accu).round}" unless @ruby_count == 0 || @ruby_accu == 0
      reset_gc_time
      reset_ruby_time
    end
  end

  # Create the FPS texts
  def init_fps_text
    return if @ingame_fps_text && !@ingame_fps_text.disposed?
    @ingame_fps_text = Text.new(0, nil, 0, 0, w = Graphics.width - 2, 13, '', 2, 1)
    @gpu_fps_text = Text.new(0, nil, 0, 16, w, 13, '', 2, 1)
    @ruby_fps_text = Text.new(0, nil, 0, 32, w, 13, '', 2, 1)
    @ingame_fps_text.z = @gpu_fps_text.z = @ruby_fps_text.z = 200_000
    self.fps_visible = PARGV[:"show-fps"]
  end

  # Define the FPS text visibility
  # @param value [Boolean]
  def fps_visible=(value)
    @ingame_fps_text.visible = @gpu_fps_text.visible = @ruby_fps_text.visible = value
  end

  # Dispose the FPS texts
  def dispose_fps_text
    return unless @ingame_fps_text && !@ingame_fps_text.disposed?
    @ingame_fps_text.dispose
    @gpu_fps_text.dispose
    @ruby_fps_text.dispose
  end

  # Change the color of the FPS texts
  # @param color [Integer] new color of the FPS texts
  def set_fps_color(color)
    @ingame_fps_text.load_color(color)
    @gpu_fps_text.load_color(color)
    @ruby_fps_text.load_color(color)
  end

  # If Graphics will skip this frame (prevent hard working)
  def skipping_frame?
    return @frame_to_skip > 0
  end
end
