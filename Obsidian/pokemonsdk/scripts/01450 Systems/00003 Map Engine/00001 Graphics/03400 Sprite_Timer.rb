#encoding: utf-8

# Display the main Timer on the screen
class Sprite_Timer < Text
  # Create the timer with its surface
  def initialize(viewport = nil)
    w = 48
    super(0, viewport, Graphics.width - w, 0 - Text::Util::FOY, 48, 32, nil.to_s, 1)
    load_color(9)
    self.z = 500
    update
  end
  # Update the timer according to the frame_rate and the number of frame elapsed.
  def update
    # タイマー作動中なら可視に設定
    self.visible = $game_system.timer_working
    # タイマーを再描画する必要がある場合
    if $game_system.timer / 60 != @total_sec # Graphics.frame_rate
      # トータル秒数を計算
      @total_sec = $game_system.timer / 60#Graphics.frame_rate
      # タイマー表示用の文字列を作成
      min = @total_sec / 60
      sec = @total_sec % 60
      # タイマーを描画
      self.text = sprintf("%02d:%02d", min, sec)
    end
  end
end
