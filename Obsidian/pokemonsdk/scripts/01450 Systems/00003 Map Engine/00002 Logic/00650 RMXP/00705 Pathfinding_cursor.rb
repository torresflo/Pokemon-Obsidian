module Pathfinding
  #-------------------------------------------
  # Class that describe and manipulate the simili character used in pathfinding
  class Cursor
    include GameData::SystemTags
    # SystemTags that trigger Surfing
    SurfTag = Game_Character::SurfTag
    # SystemTags that does not trigger leaving water
    SurfLTag = Game_Character::SurfLTag
    # SystemTags that triggers "sliding" state
    SlideTags = [TIce, RapidsL, RapidsR, RapidsU, RapidsD, RocketL, RocketU, RocketD, RocketR, RocketRL, RocketRU, RocketRD, RocketRR]
    # Array used to detect if a character is on a bridge tile
    BRIDGE_TILES = [BridgeRL, BridgeUD]

    attr_reader :x
    attr_reader :y
    attr_reader :z
    attr_reader :__bridge

    def initialize(character)
      @character = character
      @__bridge = character.__bridge
      @through = character.through
      @x = character.x
      @y = character.y
      @z = character.z
      @direction = character.direction
      @character_name = character.character_name
    end

    def state
      return [@__bridge, @sliding, @surfing]
    end

    # Simulate the mouvement of the character and store the data into cursor's attributes
    # @param x [Integer] start coords X
    # @param y [Integer] start coords Y
    # @param z [Integer] start coords z
    # @param code [Integer] mouvement's code
    # @return [Boolean]
    def sim_move?(sx, sy, sz, code, b = @__bridge, slide = @sliding, surf = @surfing)
      moveto(sx, sy)
      @z = sz
      @__bridge = b
      @sliding = slide
      @surfing = surf

      case code
      when 1 then move_down
      when 2 then move_left
      when 3 then move_right
      when 4 then move_up
      end
      return (@x != sx || @y != sy)
    end

    private

    # Warps the character on the Map to specific coordinates.
    # Adjust the z position of the character.
    # @param x [Integer] new x position of the character
    # @param y [Integer] new y position of the character
    def moveto(x, y)
      @x = x
      @y = y
    end

    # Move Game_Character down
    # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
    def move_down
      @direction = 2
      if passable?(@x, @y, 2)
        if $game_map.system_tag(@x, @y + 1) == JumpD
          jump(0, 2)
          return
        end
        bridge_down_check(@z)
        @y += 1
        movement_process_end
      else
        @sliding = false
      end
    end

    # Move Game_Character left
    # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
    def move_left
      @direction = 4
      return if stair_move_left
      y_modifier = slope_check_left
      if passable?(@x, @y, 4)
        if $game_map.system_tag(@x - 1, @y) == JumpL
          jump(-2, 0)
          return
        end
        bridge_left_check(@z)
        @x -= 1
        @y += y_modifier
        movement_process_end
      else
        @sliding = false
      end
    end

    # Try to move the Game_Character on a stair to the left
    # @return [Boolean] if the player cannot perform a regular movement (success or blocked)
    def stair_move_left
      if front_system_tag == StairsL
        return true unless $game_map.system_tag(@x - 1, @y - 1) == StairsL

        move_upper_left
        return true
      elsif system_tag == StairsR
        move_lower_left
        return true
      end
      return false
    end
    
    # Update the slope values when moving to left
    def slope_check_left
      front_sys_tag = front_system_tag
      return 0 unless (sys_tag = system_tag) == SlopesL || sys_tag == SlopesR ||
                      front_sys_tag == SlopesL || front_sys_tag == SlopesR

      if sys_tag == SlopesL && front_sys_tag != SlopesL
        return -1
      elsif sys_tag != SlopesR && front_sys_tag == SlopesR
        return 1
      end
      return 0
    end

    # Move Game_Character right
    # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
    def move_right
      @direction = 6
      return if stair_move_right
      y_modifier = slope_check_right
      if passable?(@x, @y + y_modifier, 6)
        if $game_map.system_tag(@x + 1, @y) == JumpL
          jump(2, 0)
          return
        end
        bridge_left_check(@z)
        @x += 1
        @y += y_modifier
        movement_process_end
      else
        @sliding = false
      end
    end

    # Try to move the Game_Character on a stair to the right
    # @return [Boolean] if the player cannot perform a regular movement (success or blocked)
    def stair_move_right
      if system_tag == StairsL
        move_lower_right
        return true
      elsif front_system_tag == StairsR
        return true unless $game_map.system_tag(@x + 1, @y - 1) == StairsR

        move_upper_right
        return true
      end
      return false
    end

    
    # Update the slope values when moving to right, and return y slope modifier
    # @return [Integer]
    def slope_check_right
      front_sys_tag = front_system_tag
      return 0 unless (sys_tag = system_tag) == SlopesL || sys_tag == SlopesR ||
                      front_sys_tag == SlopesL || front_sys_tag == SlopesR

      if sys_tag == SlopesR && front_sys_tag != SlopesR
        return -1
      elsif sys_tag != SlopesL && front_sys_tag == SlopesL
        return 1
      end
      return 0
    end

    # Move Game_Character up
    # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
    def move_up
      @direction = 8
      if passable?(@x, @y, 8)
        if $game_map.system_tag(@x, @y - 1) == JumpD
          jump(0, -2)
          return
        end
        bridge_down_check(@z)
        @y -= 1
        movement_process_end
      else
        @sliding = false
      end
    end

    # Move the Game_Character lower left
    def move_lower_left
      @direction = @direction == 6 ? 4 : (@direction == 8 ? 2 : @direction)
      if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 4)) ||
         (passable?(@x, @y, 4) && passable?(@x - 1, @y, 2)) # 8 a la place de 2 sur les deux lignes
        @x -= 1
        @y += 1
        movement_process_end
      end
    end

    # Move the Game_Character lower right
    def move_lower_right
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
      if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 6)) ||
         (passable?(@x, @y, 6) && passable?(@x + 1, @y, 2))
        @x += 1
        @y += 1
        movement_process_end
      end
    end

    # Move the Game_Character upper left
    def move_upper_left
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
      if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 4)) ||
         (passable?(@x, @y, 4) && passable?(@x - 1, @y, 8))
        @x -= 1
        @y -= 1
        movement_process_end
      end
    end

    # Move the Game_Character upper right
    def move_upper_right
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
      if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 6)) ||
         (passable?(@x, @y, 6) && passable?(@x + 1, @y, 8))
        @x += 1
        @y -= 1
        movement_process_end
      end
    end

    # Is the tile in front of the character passable ?
    # @param x [Integer] x position on the Map
    # @param y [Integer] y position on the Map
    # @param d [Integer] direction : 2, 4, 6, 8, 0. 0 = current position
    # @return [Boolean] if the front/current tile is passable
    def passable?(x, y, d)
      new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
      z = @z
      game_map = $game_map
      return false unless game_map.valid?(new_x, new_y)

      # Case where the event can pass through anything
      if @through
        return true unless @sliding
        return true if $game_switches[::Yuki::Sw::ThroughEvent] # Event is sliding here
      end
      sys_tag = game_map.system_tag(new_x, new_y)
      return false unless passable_bridge_check?(x, y, d, new_x, new_y, z, game_map, sys_tag) &&
                          passage_surf_check?(sys_tag)

      return false unless event_passable_check?(new_x, new_y, z, game_map)

      # Game Player check
      if $game_player.contact?(new_x, new_y, z)
        unless $game_player.through
          return false unless @character_name.empty?
        end
      end

      return false unless follower_check?(new_x, new_y, z)

      return true
    end

    # Check the bridge related passabilities
    # @param x [Integer] current x position
    # @param y [Integer] current y position
    # @param z [Integer] current direction
    # @param new_x [Integer] new x position
    # @param new_y [Integer] new y position
    # @param z [Integer] current z position
    # @param game_map [Game_Map] map object
    # @param sys_tag [Integer] current system_tag
    # @return [Boolean] if the tile is passable according to the bridge rules
    def passable_bridge_check?(x, y, d, new_x, new_y, z, game_map, sys_tag)
      bridge = @__bridge
      no_game_map = false
      if z > 1
        if bridge
          return false unless game_map.system_tag_here?(new_x, new_y, bridge[0]) ||
                              game_map.system_tag_here?(new_x, new_y, bridge[1]) ||
                              game_map.system_tag_here?(x, y, bridge[1])
        end
        case d
        when 2, 8
          no_game_map = true if sys_tag == BridgeUD
        when 4, 6
          no_game_map = true if sys_tag == BridgeRL
        end
      end
      return true if bridge || no_game_map
      return false unless game_map.passable?(x, y, d, self)
      return false unless game_map.passable?(new_x, new_y, 10 - d)

      return true
    end

    # Check the surf related passabilities
    # @param sys_tag [Integer] current system_tag
    # @return [Boolean] if the tile is passable according to the surf rules
    def passage_surf_check?(sys_tag)
      return false if !@surfing && SurfTag.include?(sys_tag)

      if @surfing
        return false unless SurfLTag.include?(sys_tag)
        return false if sys_tag == WaterFall
      end
      return true
    end

    # Check the passage related to events
    # @param new_x [Integer] new x position
    # @param new_y [Integer] new y position
    # @param z [Integer] current z position
    # @return [Boolean] if the tile has no event that block the way
    def follower_check?(new_x, new_y, z)
      unless Yuki::FollowMe.is_player_follower?(@character) || @character == $game_player
        Yuki::FollowMe.each_follower do |event|
          return false if event.contact?(new_x, new_y, z)
        end
      end
      return true
    end

    # Check the passage related to events
    # @param new_x [Integer] new x position
    # @param new_y [Integer] new y position
    # @param z [Integer] current z position
    # @param game_map [Game_Map] map object
    # @return [Boolean] if the tile has no event that block the way
    def event_passable_check?(new_x, new_y, z, game_map)
      game_map.events.each_value do |event|
        next unless event.contact?(new_x, new_y, z)
        return false unless event.through
      end
      return true
    end

    # Make the Game_Character jump
    # @param x_plus [Integer] the number of tile the Game_Character will jump on x
    # @param y_plus [Integer] the number of tile the Game_Character will jump on y
    # @return [Boolean] if the character is jumping
    def jump(x_plus, y_plus)
      jump_bridge_check(x_plus, y_plus)
      new_x = @x + x_plus
      new_y = @y + y_plus
      if (x_plus == 0 && y_plus == 0) || passable?(new_x, new_y, 0) ||
         ($game_switches[::Yuki::Sw::EV_AccroBike] && front_system_tag == AcroBike)
        @x = new_x
        @y = new_y
      end
    end

    # Perform the bridge check for the jump operation
    # @param x_plus [Integer] the number of tile the Game_Character will jump on x
    # @param y_plus [Integer] the number of tile the Game_Character will jump on y
    def jump_bridge_check(x_plus, y_plus)
      return if x_plus == 0 && y_plus == 0

      if x_plus.abs > y_plus.abs
        bridge_left_check(@z)
      else
        bridge_down_check(@z)
      end
    end

    # Adjust the Character informations related to the brige when it moves left (or right)
    # @param z [Integer] the z position
    # @author Nuri Yuri
    def bridge_down_check(z)
      if (z > 1) && !@__bridge
        if (sys_tag = front_system_tag) == BridgeUD
          @__bridge = [sys_tag, system_tag]
        end
      elsif (z > 1) && @__bridge
        @__bridge = nil if @__bridge.last == system_tag
      end
    end
    alias bridge_up_check bridge_down_check

    # Check bridge information and adjust the z position of the Game_Character
    # @param sys_tag [Integer] the SystemTag
    # @author Nuri Yuri
    def bridge_left_check(z)
      if (z > 1) && !@__bridge
        if (sys_tag = front_system_tag) == BridgeRL
          @__bridge = [sys_tag, system_tag]
        end
      elsif (z > 1) && @__bridge
        @__bridge = nil if @__bridge.last == system_tag
      end
    end
    alias bridge_right_check bridge_left_check

    # End of the movement process
    # @author Nuri Yuri
    def movement_process_end
      if SlideTags.include?(sys_tag = system_tag) ||
         (sys_tag == MachBike && !($game_switches[::Yuki::Sw::EV_Bicycle] && @lastdir4 == 8))
        @sliding = true
        @sliding_param = sys_tag
      end
      @z = ZTag.index(sys_tag) if ZTag.include?(sys_tag)
      @z = 1 if @z < 1
      @z = 0 if (@z == 1) && BRIDGE_TILES.include?(sys_tag)
      @__bridge = nil if @__bridge && (@__bridge.last == sys_tag)
    end

    # Return the SystemTag in the front of the Game_Character
    # @return [Integer] ID of the SystemTag
    # @author Nuri Yuri
    def front_system_tag
      xf = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
      yf = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
      return $game_map.system_tag(xf, yf)
    end

    # Return the SystemTag where the Game_Character stands
    # @return [Integer] ID of the SystemTag
    # @author Nuri Yuri
    def system_tag
      return $game_map.system_tag(@x, @y)
    end
  end
end
