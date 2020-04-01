class Game_Player
  # Indicate if the player is on acro bike
  # @return [Boolean]
  attr_reader :on_acro_bike

  # Define Acro Bike state of the Game_Player
  # @author Nuri Yuri
  def on_acro_bike=(state)
    @on_acro_bike = state
    @acro_count = 0
  end

  # Search an invisible item
  def search_item
    $game_map.events.each do |event_id, event|
      if event.invisible_event
        dx = (event.x - @x).abs
        dy = (event.y - @y).abs
        if dx <= 10 and dy <= 7
          Audio.se_play("audio/se/nintendo")
          $game_player = event
          turn_toward_player
          $game_player = self
          return true
        end
      end
    end
    return false
  end

  # Detect the swamp state
  def detect_swamp
    last_in_swamp = @in_swamp
    super
    if @in_swamp
      detect_swamp_entering(last_in_swamp)
      detect_deep_swamp_sinking(last_in_swamp)
    else
      detect_swamp_leaving(last_in_swamp)
    end
  end

  # Detect if we are leaving the swamp, then update the state
  # @param last_in_swamp [Integer, false] the last swamp info
  def detect_swamp_leaving(last_in_swamp)
    return unless last_in_swamp
    @state == :swamp ? enter_in_walking_state : enter_in_running_state
  end

  # Detect if we are entering in the swamp, then update the state
  # @param last_in_swamp [Integer, false] the last swamp info
  def detect_swamp_entering(last_in_swamp)
    return unless last_in_swamp
    return unless @state == :walking || @state == :running
    @state == :walking ? enter_in_walking_state : enter_in_running_state
  end

  # Detect if we should trigger the deep_swamp sinking when we detect swamp info
  # @param last_in_swamp [Integer, false] the last swamp info
  def detect_deep_swamp_sinking(last_in_swamp)
    if (last_in_swamp == false || last_in_swamp <= 1) && (@in_swamp && @in_swamp > 1)
      enter_in_sinking_state
    elsif (last_in_swamp && last_in_swamp > 1) && !(@in_swamp && @in_swamp > 1)
      leave_sinking_state
    end
  end

=begin
  if false #> Déplacement 8 directions
    alias base_update update
    def update
      unless moving? or $game_system.map_interpreter.running? or
             @move_route_forcing or $game_temp.message_window_showing or @sliding
        dir8  = Input.dir8
        case dir8
        when 9
          move_upper_right
        when 7
          move_upper_left
        when 1
          move_lower_left
        when 3
          move_lower_right
        end
      end
      base_update
    end
  end
=end

=begin
  def mouse_dir4
    sx = Graphics.width / 2
    sy = Graphics.height / 2 #> /!\ PSDK DS => / 4
    mx = Input.mx
    my = Input.my
    px = mx - sx
    py = my - sy
    px2 = px.abs
    py2 = py.abs
    return 0 if(px2 <= 32 and py2 <= 32)
    if px < 0 #LEFT
      return ((py < 0) ? 8 : 2) if py2 > px2
      return 4
    else # Droite
      return ((py < 0) ? 8 : 2) if py2 > px2
      return 6
    end

  end
=end
end
