module Yuki
  # The Player Follower Manager
  # @author Nuri Yuri
  module FollowMe
    # Dans mon dossier characters, ils sont fait de la sorte :
    # 001_0.png Bulbizarre forme 0
    # 001s_0.png Bulbizarre forme 0 shiny
    # 201_4.png Zarbi E (les formes commencent a 0 :p)
    @followers = []

    module_function

    # Init the FollowMe on a new viewport. Previous Follower are disposed.
    # @param viewport [Viewport] the new viewport
    def init(viewport)
      dispose if @followers
      @viewport = viewport
      @followers = []
    end

    # Update of the Follower Management. Their graphics are updated here.
    def update
      update_check_last_state
      # Don't update if the system is not active
      return unless $game_switches[Sw::FM_Enabled]
      chara_update = ($game_variables[Var::FM_Sel_Foll] == 0)
      last_follower = $game_player
      last_follower.set_follower(nil, true)
      i = 0
      # Manage human
      0.upto($game_variables[Var::FM_N_Human] - 1) do |j|
        next unless $game_actors[i + 2]
        last_follower = update_follower(last_follower, i, $game_actors[j + 2], chara_update)
        i += 1
      end
      # Manage Player's Pokemon
      0.upto($game_variables[Var::FM_N_Pokem] - 1) do |j|
        next unless $actors[j] && !$actors[j].dead?
        last_follower = update_follower(last_follower, i, $actors[j], chara_update)
        i += 1
      end
      # Manage friend's Pokemon
      other_party = $storage.other_party
      0.upto($game_variables[Var::FM_N_Friend] - 1) do |j|
        return unless other_party[j] && !other_party[j].dead?
        last_follower = update_follower(last_follower, i, other_party[j], chara_update)
        i += 1
      end
      # Remove the remaining followers
      @followers.pop&.dispose while @followers.size > i
    end

    # Part of the update function that checks the last state in order to dispose the sprites
    def update_check_last_state
      return unless @laststate != $game_switches[Sw::FM_Enabled]
      @laststate = $game_switches[Sw::FM_Enabled]
      return if @laststate
      @followers.each { |i| i&.dispose }
      @followers.clear
    end

    # Update of a single follower
    # @param last_follower [Game_Character] the last follower (in case of Follower creation)
    # @param i [Integer] index in the @followers Array
    # @param entity [PFM::Pokemon, Game_Actor] the entity that is shown as a follower
    # @param chara_update [Boolean] if the character graphics and informations needs to be updated
    # @return [Game_Character] the character that will become the last_follower
    def update_follower(last_follower, i, entity, chara_update)
      follower = @followers[i]
      unless follower
        @followers[i] = follower = Sprite_Character.new(@viewport, Game_Character.new)
        position_character(follower.character, i)
        follower.character.z = $game_player.z
      end
      character = follower.character
      last_follower.set_follower(character)
      character.set_follower(nil)
      if chara_update
        character.character_name = entity.character_name
        character.is_pokemon = character.step_anime = entity.class == PFM::Pokemon
      end
      character.move_speed = $game_player.move_speed
      character.through = true
      character.update
      follower.update
      follower.z -= 1 if character.x == $game_player.x and character.y == $game_player.y
      return (@followers[i] = follower).character
    end

    # Sets the default position of a follower
    # @param c [Game_Character] the character
    # @param i [Integer] the index of the caracter in the @followers Array
    def position_character(c,i)
      return if $game_variables[Yuki::Var::FM_Sel_Foll] > 0
      c1 = (i == 0 ? $game_player : @followers[i - 1].character)
      x = c1.x
      y = c1.y
      if $game_switches[Sw::Env_CanFly] || $game_switches[Sw::FM_NoReset]
        case c1.direction
        when 2
          y -= 1
        when 4
          x += 1
        when 6
          x -= 1
        else
          y += 1
        end
      end
      c.through = false
      if c.passable?(x, y, 0) # c1.direction)) #$game_map
        c.moveto(x, y)
      else
        c.moveto(c1.x, c1.y)
      end
      c.through = true
      c.direction = $game_player.direction
      c.update
    end

    # Clears the follower (and dispose them)
    def clear
      return unless @followers
      @followers.each { |i| i&.dispose }
      @followers.clear
    end

    # Retrieve a follower
    # @param i [Integer] index of the follower in the @followers Array
    # @return [Game_Character] $game_player if i is invalid
    def get_follower(i)
      if @followers && @followers[i]
        return @followers[i].character
      end
      return $game_player
    end

    # yield a block on each Followers
    # @param block [Proc] the block to call
    # @example Turn each follower down
    #   Yuki::FollowMe.each_follower { |c| c.turn_down }
    def each_follower(&block)
      @followers&.collect(&:character)&.each(&block)
    end

    # Sets the position of each follower (Warp)
    # @param args [Array<Integer, Integer, Integer>] array of x, y, direction
    def set_positions(*args)
      width = $game_map.width - 1
      height = $game_map.height - 1
      x = y = 0
      (args.size / 3).times do |i|
        next unless v = @followers[i]
        c = v.character
        x = args[i * 3]
        y = args[i * 3 + 1]
        x = width if x > width
        y = height if y > height
        x = 0 if x < 0
        y = 0 if y < 0
        c.moveto(x, y)
        c.direction = args[i * 3 + 2]
        c.update
        c.particle_push
        v.update
      end
    end

    # Reset position of each follower to the player (entering in a building)
    def reset_position
      return unless @followers
      $game_player.reset_follower_move
      @followers.size.times do |i|
        v = @followers[i]
        c = v.character
        x,y = $game_player.x, $game_player.y
        case $game_player.direction
        when 2
          y -= 1
        when 8
          y += 1
        when 4
          x += 1
        when 6
          x -= 1
        end
        x,y = $game_player.x, $game_player.y if !$game_map.passable?(x,y,$game_player.direction)
        c.moveto(x,y)
        c.direction = $game_player.direction
        c.instance_variable_set(:@memorized_move, nil)
        c.update
        v.update
        v.z -= 1
      end
    end

    # Test if a character is a Follower of the player
    def is_player_follower?(c)
      return unless @followers
      return @followers.include?(c)
    end

    # Set the Follower Manager in Battle mode. When getting out of battle every character will get its particle pushed.
    def set_battle_entry(v = true)
      @was_fighting = v
    end

    # Push particle of each character if the Follower Manager was in Battle mode.
    def particle_push
      each_follower(&:particle_push) if @was_fighting
      @was_fighting = false
    end

    # Dispose the follower and release resources.
    def dispose
      @followers&.each { |i| i.dispose if i && !i.disposed? }
      @followers = nil
      @viewport = nil
    end

    # Smart disable the following system (keep it active when smart_enable is called)
    def smart_disable
      return unless $game_switches[Sw::FM_Enabled]
      $game_player.set_follower(nil, true)
      set_player_follower_particles(false)
      $game_switches[Sw::FM_WasEnabled] = $game_switches[Sw::FM_Enabled]
      $game_switches[Sw::FM_Enabled] = false
    end

    # Smart disable the following system (keep it active when smart_enable is called)
    def smart_enable
      set_player_follower_particles(true)
      $game_switches[Sw::FM_Enabled] = $game_switches[Sw::FM_WasEnabled]
    end

    # Enable / Disable the particles for the player followers
    def set_player_follower_particles(value)
      each_follower do |follower|
        follower.particles_disabled = !value
      end
    end
  end
end
