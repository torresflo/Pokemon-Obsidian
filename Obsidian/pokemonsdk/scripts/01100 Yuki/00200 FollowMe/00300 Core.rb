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
      entities = follower_entities
      return clear unless enabled

      last_follower = $game_player
      follower_event = @followers.find { |follower| follower.character.follower.is_a?(Game_Event) }&.character&.follower
      follower_event ||= last_follower.follower if last_follower.follower.is_a?(Game_Event)
      chara_update = selected_follower == 0

      # Reset following state
      last_follower.set_follower(nil, true)
      @followers.each { |follower| follower.character.set_follower(nil) }

      # Update each follower
      entities.each_with_index do |entity, index|
        last_follower = update_follower(last_follower, index, entity, chara_update)
      end

      # Remove the remaining followers
      @followers.pop&.dispose while @followers.size > entities.size

      # Update the last follower's follower
      update_follower_event(last_follower, follower_event)
    end

    # Function that attempts to set the event as last follower
    # @param last_follower [Game_Character]
    # @param follower_event [Game_Event]
    def update_follower_event(last_follower, follower_event)
      last_follower_event = follower_event
      while last_follower_event&.follower
        last_follower_event.set_follower(nil) unless last_follower_event.follower.is_a?(Game_Event)
        last_follower_event = last_follower_event.follower
      end
      last_follower.set_follower(follower_event) if last_follower.follower != follower_event
    end

    # Get the follower entities (those giving information about character_name)
    # @return [Array<#character_name>]
    def follower_entities
      player_pokemon = in_lets_go_mode? ? player_pokemon_lets_go_entity : player_pokemon_entities
      return human_entities.concat(player_pokemon).concat(other_pokemon_entities)
    end

    # Get the human follower entities
    # @return [Array<#character_name>]
    def human_entities
      human = (0...human_count).map { |i| $game_actors[i + 2] }
      human.compact!
      return human
    end

    # Get the player's pokemon follower entities
    # @return [Array<#character_name>]
    def player_pokemon_entities
      player_mon = (0...pokemon_count).map { |i| $actors[i] }
      player_mon.compact!
      player_mon.reject!(&:dead?)
      return player_mon
    end

    # Get the player's pokemon follower entity if the FollowMe mode is Let's Go
    # @return [Array<#character_name>]
    def player_pokemon_lets_go_entity
      follower = $storage.lets_go_follower
      return [] unless follower && !follower.dead? && $actors.include?(follower)

      return [follower]
    end

    # Get the friend's pokemon follower entities
    # @return [Array<#character_name>]
    def other_pokemon_entities
      other_mon = (0...other_pokemon_count).map { |i| $storage.other_party[i] }
      other_mon.compact!
      other_mon.reject!(&:dead?)
      return other_mon
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
      if chara_update
        character.character_name = entity.character_name
        character.is_pokemon = character.step_anime = entity.class == PFM::Pokemon
      end
      character.move_speed = $game_player.original_move_speed
      character.through = true
      character.update
      follower.update
      follower.z -= 1 if character.x == $game_player.x && character.y == $game_player.y
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
      x = y = 0
      (args.size / 3).times do |i|
        next unless (v = @followers[i])

        c = v.character
        x = args[i * 3]
        y = args[i * 3 + 1]
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
Hooks.register(Spriteset_Map, :init_psdk_add, 'Yuki::FollowMe') { Yuki::FollowMe.init(@viewport1) }
Hooks.register(Spriteset_Map, :init_player_begin, 'Yuki::FollowMe') do
  Yuki::FollowMe.update
  Yuki::FollowMe.particle_push
end
Hooks.register(Spriteset_Map, :update, 'Yuki::FollowMe') { Yuki::FollowMe.update }
