module PFM
  # The game informations and Party management
  #
  # The global object is stored in $pokemon_party
  # @author Nuri Yuri
  class Pokemon_Party
    include GameData::PokemonParty
    # Constant containing all the proc to call when creating a new Pokemon_Party object (for battle)
    ON_INITIALIZE = {}
    # Constant containing all the proc to call when creating a new Pokemon_Party object (for the player)
    ON_PLAYER_INITIALIZE = {}
    # Constant containing all the proc to call when expanding the global variables
    ON_EXPAND_GLOBAL_VARIABLES = {}

    class << self
      # Add a new proc on initialize (for battle)
      # @param name [Symbol] name of the block to add
      # @param block [Proc] proc to execute with the Pokemon_Party context
      def on_initialize(name, &block)
        ON_INITIALIZE[name] = block
      end

      # Add a new proc on player initialize (for the player)
      # @param name [Symbol] name of the block to add
      # @param block [Proc] proc to execute with the Pokemon_Party context
      def on_player_initialize(name, &block)
        ON_PLAYER_INITIALIZE[name] = block
      end

      # Add a new proc on global variable expand
      # @param name [Symbol] name of the block to add
      # @param block [Proc] proc to execute with the Pokemon_Party context
      def on_expand_global_variables(name, &block)
        ON_EXPAND_GLOBAL_VARIABLES[name] = block
      end
    end

    # The Pokemon of the Player
    # @return [Array<PFM::Pokemon>]
    attr_accessor :actors
    on_initialize(:actors) do
      # @type [Array<PFM::Pokemon>]
      @actors = []
    end
    on_expand_global_variables(:actors) do
      # Variable containing the player's Pokemon
      $actors = @actors
    end

    # The number of steps the repel will work
    # @return [Integer]
    attr_reader :repel_count
    on_initialize(:repel_count) { @repel_count = 0 }

    # The number of steps the player did
    # @return [Integer]
    attr_accessor :steps
    on_initialize(:steps) { @steps = 0 }

    # The $game_variables
    # @return [Game_Variables]
    attr_accessor :game_variables
    on_player_initialize(:game_variables) do
      @game_variables = Game_Variables.new
      $game_variables ||= @game_variables
    end
    on_expand_global_variables(:game_variables) do
      # Variable containing all the "Game Variables" (numeric interface between events and scripts)
      $game_variables = @game_variables
    end

    # The $game_switches
    # @return [Game_Switches]
    attr_accessor :game_switches
    on_player_initialize(:game_switches) do
      @game_switches = Game_Switches.new
      $game_switches ||= @game_switches
    end
    on_expand_global_variables(:game_switches) do
      # Variable containing all the "Game Switches" (boolean interface between events and scripts)
      $game_switches = @game_switches
    end

    # The $game_self_switches
    # @return [Game_SelfSwitches]
    attr_accessor :game_self_switches
    on_player_initialize(:game_self_switches) { @game_self_switches = Game_SelfSwitches.new }
    on_expand_global_variables(:game_self_switches) do
      # Variable containing all the "Self Switches" (internal boolean logic of events)
      $game_self_switches = @game_self_switches
    end

    # The $game_self_variables
    # @return [Game_SelfVariables]
    attr_accessor :game_self_variables
    on_player_initialize(:game_self_variables) { @game_self_variables = Game_SelfVariables.new }
    on_expand_global_variables(:game_self_variables) do
      # Variable containing all the "Self Variables" (internal numeric logic of events)
      $game_self_variables = @game_self_variables
    end

    # The $game_system
    # @return [Game_System]
    attr_accessor :game_system
    on_player_initialize(:game_system) { @game_system = Game_System.new }
    on_expand_global_variables(:game_system) do
      # Variable containing the Music logic, Menu & Save access and Interpreters
      $game_system = @game_system
    end

    # The $game_screen
    # @return [Game_Screen]
    attr_accessor :game_screen
    on_player_initialize(:game_screen) { @game_screen = Game_Screen.new }
    on_expand_global_variables(:game_screen) do
      # Variable containing the screen logic (tone, pictures, weather)
      $game_screen = @game_screen
    end

    # The $game_actors
    # @return [Game_Actors]
    attr_accessor :game_actors
    on_player_initialize(:game_actors) { @game_actors = Game_Actors.new }
    on_expand_global_variables(:game_actors) do
      # Variable containing the RMXP Hero living informations
      $game_actors = @game_actors
    end

    # The $game_party
    # @return [Game_Party]
    attr_accessor :game_party
    on_player_initialize(:game_party) { @game_party = Game_Party.new }
    on_expand_global_variables(:game_party) do
      # Variable containing the RMXP Party informations
      $game_party = @game_party
    end
    on_player_initialize(:game_troop) { @game_troop = Game_Troop.new }
    on_expand_global_variables(:game_troop) { $game_troop = @game_troop }

    # The $game_map
    # @return [Game_Map]
    attr_accessor :game_map
    on_player_initialize(:game_map) { @game_map = Game_Map.new }
    on_expand_global_variables(:game_map) do
      # Variable contaning the current Map info
      $game_map = @game_map
    end

    # The $game_player
    # @return [Game_Player]
    attr_accessor :game_player
    on_player_initialize(:game_player) { @game_player = Game_Player.new }
    on_expand_global_variables(:game_player) do
      # Variable containing the Player Character info on Map
      $game_player = @game_player
    end

    # The $game_temp
    # @return [Game_Temp]
    attr_accessor :game_temp
    on_player_initialize(:game_temp) { @game_temp = Game_Temp.new }
    on_expand_global_variables(:game_temp) do
      # Variable containing all the temporary information (to communicate between scenes)
      $game_temp = @game_temp
    end

    # The nuzlocke logic
    # @return [Nuzlocke]
    attr_accessor :nuzlocke
    on_player_initialize(:nuzlocke) { @nuzlocke = Nuzlocke.new }
    on_expand_global_variables(:nuzlocke) do
      # Variable containing the Nuzlocke Logic
      @nuzlocke ||= Nuzlocke.new
      # Adding a new value for old save
      @nuzlocke.graveyard ||= []
    end

    # The pathfinding requests
    # @return [Array<Object>]
    attr_accessor :pathfinding_requests
    on_player_initialize(:pathfinding_requests) { @pathfinding_requests = Pathfinding::DEFAULT_SAVE }
    on_expand_global_variables(:pathfinding_requests) { @pathfinding_requests ||= Pathfinding::DEFAULT_SAVE }

    # Name of the time set to use (nil = default)
    # @return [Symbol, nil]
    attr_accessor :tint_time_set

    # User data
    # @return [Hash]
    attr_reader :user_data
    on_player_initialize(:user_data) { @user_data = {} }
    on_expand_global_variables(:user_data) do
      @user_data ||= {}
      # Variable containing the user data (for plug & play systems)
      $user_data = @user_data
    end

    # Maximum level an allied Pokemon can reach
    # @return [Integer]
    attr_accessor :level_max_limit
    on_player_initialize(:level_max_limit) { @level_max_limit = GameData::MAX_LEVEL }
    on_expand_global_variables(:level_max_limit) { @level_max_limit ||= GameData::MAX_LEVEL }

    # The in game berry data
    # @return [Hash]
    attr_accessor :berries
    on_player_initialize(:berries) { @berries = {} }

    # Create a new Pokemon Party
    # @param battle [Boolean] if its a party of a NPC battler
    # @param starting_language [String] the lang id of the game described by this object
    def initialize(battle = false, starting_language = 'en')
      @starting_language = starting_language
      ON_INITIALIZE.each_value do |block|
        instance_exec(&block) if block
      end
      return if battle

      game_state_initialize
      rmxp_boot unless $tester
    end

    private

    # Initialize the game state variable
    def game_state_initialize
      ON_PLAYER_INITIALIZE.each_value do |block|
        instance_exec(&block) if block
      end
      expand_global_var
      load_parameters
    end

    # Perform the RMXP bootup
    def rmxp_boot
      expand_global_var # Safety to be sure the variable are really ok
      @game_party.setup_starting_members
      log_info("$data_system.start_map_id = #{$data_system.start_map_id}")
      log_info("$data_system.start_x = #{$data_system.start_x}")
      log_info("$data_system.start_x = #{$data_system.start_y}")
      @game_map.setup($data_system.start_map_id)
      @game_player.moveto($data_system.start_x + Yuki::MapLinker.get_OffsetX, $data_system.start_y + Yuki::MapLinker.get_OffsetY)
      @game_player.refresh
      @game_map.autoplay
      ## @game_map.update
    end

    public

    # Expand the global variable with the instance variables of the object
    def expand_global_var
      $pokemon_party = self
      ON_EXPAND_GLOBAL_VARIABLES.each_value do |block|
        instance_exec(&block) if block
      end
    end

    # Update the processing of the repel
    def repel_update
      return if cant_process_event_tasks?

      if @repel_count > 0
        @repel_count -= 1
        $scene.delay_display_call(:display_repel_check) if @repel_count == 0
      end
    end

    def battle_starting_update
      return if cant_process_event_tasks?
      encounter_count = $game_player.encounter_count
      if !$game_system.encounter_disabled && ((@steps % encounter_count) == 0) && @wild_battle.available?
        $game_system.map_interpreter.launch_common_event(1) unless $game_system.map_interpreter.running?
      end
    end

    # Update the processing of the poison event
    def poison_update
      return unless (@steps - (@steps / 8) * 8) == 0
      return if cant_process_event_tasks?

      psn_event = false
      @actors.each do |pokemon|
        next unless pokemon.poisoned? || pokemon.toxic?

        $scene.delay_display_call(:display_poison_animation) unless psn_event
        psn_event = true
        pokemon.hp -= (pokemon.toxic? ? 2 : 1)
        next unless pokemon.hp <= 1

        pokemon.hp = 1
        pokemon.cure
        $scene.delay_display_call(:display_poison_end, pokemon)
      end
      nuzlocke.clear_dead_pokemon if nuzlocke.enabled?
    end

    # Update the remaining steps of all the Egg to hatch
    def hatch_check_update
      return if cant_process_event_tasks?

      amca = FASTER_HATCH_ABILITIES.include?(@actors[0]&.ability_db_symbol || :__undef__)
      @actors.each do |pokemon|
        next unless pokemon.step_remaining > 0

        pokemon.step_remaining -= 1
        pokemon.step_remaining -= 1 if amca && (pokemon.step_remaining > 0)
        if pokemon.step_remaining == 0
          pokemon.egg_finish
          $scene.delay_display_call(:display_egg_hatch, pokemon)
        end
      end
    end

    # Update the loyalty process of the pokemon
    def loyalty_update
      return unless (@steps - (@steps / 512) * 512) == 0
      return if cant_process_event_tasks?

      @actors.each { |pokemon| pokemon.loyalty += 1 }
    end

    # Tell if EventTasks can't process
    # @return [Boolean]
    def cant_process_event_tasks?
      return ($game_player.move_route_forcing || $game_system.map_interpreter.running? ||
        $game_temp.message_window_showing || $game_player.sliding)
    end

    # Increase the @step and manage events that trigger each steps
    # @return [Array] informations about events that has been triggered.
    def increase_steps
      @steps += 1
      $game_party.steps = @steps
    end

    # Change the repel_count
    # @param v [Integer]
    def repel_count=(v)
      @repel_count = v.to_i.abs
    end
    alias set_repel_count repel_count=
    alias get_repel_count repel_count

    # Return the money the player has
    # @return [Integer]
    def money
      return $game_party.gold
    end

    # Change the money the player has
    # @param v [Integer]
    def money=(v)
      $game_party.gold = v.to_i
    end

    # Add money
    # @param n [Integer] amount of money to add
    def add_money(n)
      return lose_money(-n) if n < 0

      $game_party.gold += n
    end

    # Lose money
    # @param n [Integer] amount of money to lose
    def lose_money(n)
      return add_money(-n) if n < 0

      $game_party.gold -= n
      $game_party.gold = 0 if $game_party.gold < 0
    end

    # Load some parameters (audio volume & text)
    def load_parameters
      Audio.music_volume = @options.music_volume
      Audio.sfx_volume = @options.sfx_volume
      GameData::Text.load
    end
  end
end
