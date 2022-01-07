class Game_Player
  # @return [Hash{map_id=>Array<map_id, offset_x, offset_y>}] list of falling hole info 
  FALLING_HOLES = {
    13 => [13, 1, 0]
  }

  def falling_hole_warp
    return unless (hole_data = FALLING_HOLES[$game_map.map_id])
    $game_temp.player_transferring = true
    $game_temp.player_new_map_id = hole_data[0]
    $game_temp.player_new_x = @x + hole_data[1]
    $game_temp.player_new_y = @y + hole_data[2]
    $game_temp.player_new_direction = @direction
  end
end
