#encoding: utf-8

# Update every component that affect the screen
class Game_Screen
  NEUTRAL_TONE = Tone.new(0, 0, 0, 0)
  attr_reader   :tone                     # 色調
  attr_reader   :flash_color              # フラッシュ色
  attr_reader   :shake                    # シェイク位置
  attr_reader   :pictures                 # ピクチャ
  attr_reader   :weather_type             # 天候 タイプ
  attr_reader   :weather_max              # 天候 画像の最大数
  # default initializer
  def initialize
    @tone = Tone.new(0, 0, 0, 0)
    @tone_target = Tone.new(0, 0, 0, 0)
    @tone_duration = 0
    @flash_color = Color.new(0, 0, 0, 0)
    @flash_duration = 0
    @shake_power = 0
    @shake_speed = 0
    @shake_duration = 0
    @shake_direction = 1
    @shake = 0
    @pictures = [nil]
    for i in 1..100
      @pictures.push(Game_Picture.new(i))
    end
    @weather_type = 0
    @weather_max = 0.0
    @weather_type_target = 0
    @weather_max_target = 0.0
    @weather_duration = 0
  end
  # start a tone change process
  # @param tone [Tone] the new tone
  # @param duration [Integer] the time it takes in frame
  def start_tone_change(tone, duration)
    @tone_target = tone.clone
    @tone_duration = duration
    if @tone_duration == 0
      @tone = @tone_target.clone
    end
  end
  # start a flash process
  # @param color [Color] a color
  # @param duration [Integer] the time it takes in frame
  def start_flash(color, duration)
    @flash_color = color.clone
    @flash_duration = duration
  end
  # start a screen shake process
  # @param power [Integer] the power of the shake (distance between normal position and shake limit position)
  # @param speed [Integer] the speed of the shake (10 = 4 frame to get one shake period)
  # @param duration [Integer] the time the shake lasts
  def start_shake(power, speed, duration)
    @shake_power = power
    @shake_speed = speed
    @shake_duration = duration
  end
  # starts a weather change process
  # @param type [Integer] the type of the weather
  # @param power [Numeric] The power of the weather
  # @param duration [Integer] the time it takes to change the weather
  # @param psdk_weather [Integer, nil] the PSDK weather type
  def weather(type, power, duration, psdk_weather: nil)
    #> Set weather to PSDK
    unless psdk_weather
      case type
      when 1, 2 #Rain / Storm
        $env.apply_weather(1)
        type = 1
      when 3 # Snow
        $env.apply_weather(4)
        type = 4
      else
        $env.apply_weather(0, 0)
        type = 0
      end
    else
      type = psdk_weather
      $env.apply_weather(psdk_weather)
    end
    #> Define Weather
    @weather_type_target = type
    if @weather_type_target != 0
      @weather_type = @weather_type_target
    end
    if @weather_type_target == 0
      @weather_max_target = 0.0
    else
      @weather_max_target = (power + 1) * 4.0
    end
    @weather_duration = duration
    if @weather_duration == 0
      @weather_type = @weather_type_target
      @weather_max = @weather_max_target
    end
  end
  # Update every process and picture
  def update
    if @tone_duration >= 1
      d = @tone_duration
      @tone.red = (@tone.red * (d - 1) + @tone_target.red) / d
      @tone.green = (@tone.green * (d - 1) + @tone_target.green) / d
      @tone.blue = (@tone.blue * (d - 1) + @tone_target.blue) / d
      @tone.gray = (@tone.gray * (d - 1) + @tone_target.gray) / d
      @tone_duration -= 1
    end
    if @flash_duration >= 1
      d = @flash_duration
      @flash_color.alpha = @flash_color.alpha * (d - 1) / d
      @flash_duration -= 1
    end
    if @shake_duration >= 1 or @shake != 0
      delta = (@shake_power * @shake_speed * @shake_direction) / 10.0
      if @shake_duration <= 1 and @shake * (@shake + delta) < 0
        @shake = 0
      else
        @shake += delta
      end
      if @shake > @shake_power * 2
        @shake_direction = -1
      end
      if @shake < - @shake_power * 2
        @shake_direction = 1
      end
      if @shake_duration >= 1
        @shake_duration -= 1
      end
    end
    if @weather_duration >= 1
      d = @weather_duration
      @weather_max = (@weather_max * (d - 1) + @weather_max_target) / d
      @weather_duration -= 1
      if @weather_duration == 0
        @weather_type = @weather_type_target
      end
    end
    if $game_temp.in_battle
      for i in 51..100
        @pictures[i].update
      end
    else
      for i in 1..50
        @pictures[i].update
      end
    end
  end
end

