# Management of the player displacement on the Map
class Game_Player < Game_Character
  # 4 time the x position of the Game_Player sprite
  CENTER_X = PSDK_CONFIG.tilemap.center_x
  # 4 time the y position of the Game_Player sprite
  CENTER_Y = PSDK_CONFIG.tilemap.center_y
  # Name of the bump sound when the player hit a wall
  BUMP_FILE = 'audio/se/bump'
  # true if the player is on the back wheel of its Acro bike
  # @return [Boolean]
  attr_accessor :acro_appearence
  # Default initializer
  def initialize
    super
    @wturn = 0
    @bump_count = 0 # Used for the Pokemon bump
    @on_acro_bike = false
    @acro_count = 0
    ## @cant_bump = false
  end

  # Adjust the map display according to the given position
  # @param x [Integer] the x position on the MAP
  # @param y [Integer] the y position on the MAP
  def center(x, y)
    if $game_map.maplinker_disabled
      max_x = ($game_map.width - Game_Map::NUM_TILE_VIEW_X) * 128
      max_y = ($game_map.height - Game_Map::NUM_TILE_VIEW_Y) * 128
      $game_map.display_x = (x * 128 - CENTER_X).clamp(0, max_x) # [0, [x * 128 - CENTER_X, max_x].min].max
      $game_map.display_y = (y * 128 - CENTER_Y).clamp(0, max_y) # [0, [y * 128 - CENTER_Y, max_y].min].max
    else
      $game_map.display_x = x * 128 - CENTER_X
      $game_map.display_y = y * 128 - CENTER_Y
    end
  end

  # Warp the player to a specific position. The map display will be centered
  # @param x [Integer] the x position on the MAP
  # @param y [Integer] the y position on the MAP
  def moveto(x, y)
    super
    center(x, y)
    make_encounter_count
  end

  # Manage the system_tag part of the moveto method
  def moveto_system_tag_manage
    # We remove the bridge z processing because it's breaking
    return super(true)
  end

  SURF_OFFSET_Y = [2, 2, 0, 0, 0, -2, -2, 0, 0, 0]
  # Overwrite the screen_y to add the surfing animation
  # @return [Integer]
  def screen_y
    value = super
    return value unless surfing?
    return value + SURF_OFFSET_Y[Graphics.frame_count / 6 % SURF_OFFSET_Y.size]
  end

  # Increases a step and displays related things
  def increase_steps
    super
    unless @move_route_forcing || $game_system.map_interpreter.running? ||
           $game_temp.message_window_showing || @sliding
      $pokemon_party.increase_steps
    end
  end

  # Returns the number of steps remaining to the next encounter
  def encounter_count
    return @encounter_count
  end

  # Generate the number of steps remaining to the next encounter
  def make_encounter_count
    return if $game_map.map_id == 0
    n = $game_map.encounter_step
    @encounter_count = rand(n) + rand(n) + 1
  end

  # Refresh the player graphics
  def refresh
    return set_appearance(nil.to_s) if $game_party.actors.empty?
    actor = $game_party.actors[0]
    set_appearance(actor.character_name, actor.character_hue)
    @opacity = 255
    @blend_type = 0
  end

  # Update the player movements according to inputs
  def update
    return send(@update_callback) if @update_callback
    last_moving = moving?
    if moving? || $game_system.map_interpreter.running? ||
       @move_route_forcing || $game_temp.message_window_showing || @sliding # or follower_sliding?
      if $game_system.map_interpreter.running?
        @step_anime = false
        enter_in_walking_state if @state == :running
      end
    else
      player_update_move
      player_move_on_cracked_floor_update if moving? && !last_moving
    end
    @wturn -= 1 if @wturn > 0
    last_real_x = @real_x
    last_real_y = @real_y

    super

    # _BUMP
=begin
    if(@cant_bump and moving?)
      @cant_bump=false
    end
=end
    update_scroll_map(last_real_x, last_real_y)

    update_check_trigger(last_moving) unless moving? || @sliding
  end

  def process_slope_y_modifier(y_modifier)
    super(y_modifier)
    $game_map.start_scroll(y_modifier < 0 ? 8 : 2, 1, 4, false, true)
  end

  private

  # Redefine of the update_move with the auto warp from the Yuki::MapLinker
  def update_move
    super
    Yuki::MapLinker.test_warp unless moving?
  end

  # Redefine the update_stop to support some specific cycling state
  def update_stop
    update_cycling_state if @state == :cycling
    super
    update_cycling_state if @state == :cycle_stop && moving?
    # Ensure the player to be in the swamp state
    return unless @in_swamp && (@state == :walking || @state == :running)
    @state == :walking ? enter_in_walking_state : enter_in_running_state
  end

  # Name of the JUMP SE
  JUMP_SE = 'audio/se/jump'
  # Redefine the update_jump to support the cracked floor
  def update_jump
    Audio.se_play(JUMP_SE) if @jump_count == @jump_peak * 2
    super
    player_move_on_cracked_floor_update unless @jump_count > 0
  end

  # Scroll the map during the update phase
  # @param last_real_x [Integer] the last real_x value of the player
  # @param last_real_y [Integer] the last real_y value of the player
  def update_scroll_map(last_real_x, last_real_y)
    if @real_y > last_real_y && @real_y - $game_map.display_y > CENTER_Y
      $game_map.scroll_down(@real_y - last_real_y)
    end
    if @real_x < last_real_x && @real_x - $game_map.display_x < CENTER_X
      $game_map.scroll_left(last_real_x - @real_x)
    end
    if @real_x > last_real_x && @real_x - $game_map.display_x > CENTER_X
      $game_map.scroll_right(@real_x - last_real_x)
    end
    if @real_y < last_real_y && @real_y - $game_map.display_y < CENTER_Y
      $game_map.scroll_up(last_real_y - @real_y)
    end
  end

  # Check the triggers during the update
  # @param last_moving [Boolean] if the player was moving before
  def update_check_trigger(last_moving)
    if last_moving && !check_event_trigger_here([1, 2])
      unless debug? && Input.press?(:CTRL)
        @encounter_count -= 1 if @encounter_count > 1
        make_encounter_count if @encounter_count <= 1
      end
    end
    return unless Input.trigger?(:A)

    result = check_event_trigger_here([0])
    result |= check_event_trigger_there([0, 1, 2])
    return if result

    check_diving_trigger_here
  end

  # Start common event diving if the player stand on diving system tag and is surfing
  def check_diving_trigger_here
    if !@__bridge &&
       !$game_temp.message_window_showing &&
       $game_player.surfing? &&
       $game_map.system_tag_here?($game_player.x, $game_player.y, ::GameData::SystemTags::TUnderWater)
      $game_temp.common_event_id = Game_CommonEvent::DIVE
    end
  end
end
