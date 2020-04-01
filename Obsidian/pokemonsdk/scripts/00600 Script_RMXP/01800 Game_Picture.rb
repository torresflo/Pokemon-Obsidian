#encoding: utf-8

# Describe a picture display on the Screen
class Game_Picture
  attr_reader   :number                   # ピクチャ番号
  attr_reader   :name                     # ファイル名
  attr_reader   :origin                   # 原点
  attr_reader   :x                        # X 座標
  attr_reader   :y                        # Y 座標
  attr_reader   :zoom_x                   # X 方向拡大率
  attr_reader   :zoom_y                   # Y 方向拡大率
  attr_reader   :opacity                  # 不透明度
  attr_reader   :blend_type               # ブレンド方法
  attr_reader   :tone                     # 色調
  attr_reader   :angle                    # 回転角度
  # Initialize the Game_Picture with default value
  # @param number [Integer] the "id" of the picture
  def initialize(number)
    @number = number
    @name = nil.to_s
    @origin = 0
    @x = 0.0
    @y = 0.0
    @zoom_x = 100.0
    @zoom_y = 100.0
    @opacity = 255.0
    @blend_type = 1
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
  # Show a picture
  # @param name [String] The name of the image in Graphics/Pictures
  # @param origin [Integer] the origin type (top left / center)
  # @param x [Numeric] the x position on the screen
  # @param y [Numeric] the y position on the screen
  # @param zoom_x [Numeric] the zoom on the width
  # @param zoom_y [Numeric] the zoom on the height
  # @param opacity [Numeric] the opacity of the picture
  # @param blend_type [Integer] the blend_type of the picture
  def show(name, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @name = name
    @origin = origin
    @x = x.to_f
    @y = y.to_f
    @zoom_x = zoom_x.to_f
    @zoom_y = zoom_y.to_f
    @opacity = opacity.to_f
    @blend_type = blend_type
    @duration = 0
    @target_x = @x
    @target_y = @y
    @target_zoom_x = @zoom_x
    @target_zoom_y = @zoom_y
    @target_opacity = @opacity
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @angle = 0
    @rotate_speed = 0
  end
  # Move a picture
  # @param duration [Integer] the number of frame the picture takes to move
  # @param origin [Integer] the origin type (top left / center)
  # @param x [Numeric] the x position on the screen
  # @param y [Numeric] the y position on the screen
  # @param zoom_x [Numeric] the zoom on the width
  # @param zoom_y [Numeric] the zoom on the height
  # @param opacity [Numeric] the opacity of the picture
  # @param blend_type [Integer] the blend_type of the picture
  def move(duration, origin, x, y, zoom_x, zoom_y, opacity, blend_type)
    @duration = duration
    @origin = origin
    @target_x = x.to_f
    @target_y = y.to_f
    @target_zoom_x = zoom_x.to_f
    @target_zoom_y = zoom_y.to_f
    @target_opacity = opacity.to_f
    @blend_type = blend_type
  end
  # Rotate the picture
  # @param speed [Numeric] the rotation speed (2*angle / frame)
  def rotate(speed)
    @rotate_speed = speed
  end
  # Start a tone change of the picture
  # @param tone [Tone] the new tone of the picture
  # @param duration [Integer] the number of frame the tone change takes
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  # Remove the picture from the screen
  def erase
    @name = nil.to_s
  end
  # Update the picture state change
  def update
    if @duration >= 1
      d = @duration
      @x = (@x * (d - 1) + @target_x) / d
      @y = (@y * (d - 1) + @target_y) / d
      @zoom_x = (@zoom_x * (d - 1) + @target_zoom_x) / d
      @zoom_y = (@zoom_y * (d - 1) + @target_zoom_y) / d
      @opacity = (@opacity * (d - 1) + @target_opacity) / d
      @duration -= 1
    end
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @rotate_speed != 0
      @angle += @rotate_speed / 2.0
      while @angle < 0
        @angle += 360
      end
      @angle %= 360
    end
  end
end

