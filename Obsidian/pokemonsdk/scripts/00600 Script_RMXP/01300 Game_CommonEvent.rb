# Describe a common event during the game processing
class Game_CommonEvent
  # @return [Integer] ID of the wild battle start common event
  WILD_BATTLE = 1
  # @return [Integer] ID of the appearence common event
  APPEARANCE = 2
  # @return [Integer] ID of the follower speech common event
  FOLLOWER_SPEECH = 5
  # @return [Integer] ID of the falling from hole common event
  HOLE_FALLING = 8
  # @return [Integer] ID of the enter surf common event
  SURF_ENTER = 9
  # @return [Integer] ID of the leaving surf common event
  SURF_LEAVE = 10
  # @return [Integer] ID of the headbutt common event
  HEADBUTT = 20
  # @return [Integer] ID of the waterfall common event
  WATERFALL = 26
  # @return [Integer] ID of the dive common event
  DIVE = 29
  # Initialize the Game_CommonEvent
  # @param common_event_id [Integer] id of the common event in the database
  def initialize(common_event_id)
    @common_event_id = common_event_id
    @interpreter = nil
    refresh
  end
  # Name of the common event
  def name
    return $data_common_events[@common_event_id].name
  end
  # trigger condition of the common event
  def trigger
    return $data_common_events[@common_event_id].trigger
  end
  # id of the switch that triggers the common event
  def switch_id
    return $data_common_events[@common_event_id].switch_id
  end
  # List of commands of the common event
  def list
    return $data_common_events[@common_event_id].list
  end
  # Refresh the common event. If it triggers automatically, an internal Interpreter is generated
  def refresh
    # 必要なら並列処理用インタプリタを作成
    if self.trigger == 2 and $game_switches[self.switch_id] == true
      if @interpreter == nil
        @interpreter = Interpreter.new
      end
    else
      @interpreter = nil
    end
  end
  # Update the common event, if there's an internal Interpreter, it's being updated
  def update
    # 並列処理が有効の場合
    if @interpreter != nil
      # 実行中でなければセットアップ
      unless @interpreter.running?
        @interpreter.setup(self.list, 0)
      end
      # インタプリタを更新
      @interpreter.update
    end
  end
end
