module PFM
  # The game informations and Party management
  #
  # The global object is stored in $pokemon_party
  # @author Nuri Yuri
  class Pokemon_Party
    include GameData::PokemonParty
    # The Pokemon of the Player
    # @return [Array<PFM::Pokemon>]
    attr_accessor :actors
    # The Pokedex of the player
    # @return [PFM::Pokedex]
    attr_accessor :pokedex
    # The bag of the player
    # @return [PFM::Bag]
    attr_accessor :bag
    # The informations about the player and the game
    # @return [PFM::Trainer]
    attr_accessor :trainer
    # The PC storage of the player
    # @return [PFM::Storage]
    attr_accessor :storage
    # The environment informations
    # @return [PFM::Environnement]
    attr_accessor :env
    # The informations about the Wild Pokemon Battle
    # @return [PFM::Wild_Battle]
    attr_accessor :wild_battle
    # The number of steps the repel will work
    # @return [Integer]
    attr_reader :repel_count
    # The number of steps the player did
    # @return [Integer]
    attr_accessor :steps
    # The daycare management object
    # @return [PFM::Daycare]
    attr_accessor :daycare
    # The in game berry data
    # @return [Hash]
    attr_accessor :berries
    # The player quests informations
    # @return [PFM::Quests]
    attr_accessor :quests
    # The game options
    # @return [PFM::Options]
    attr_accessor :options
    # The list of Pokemon imported from Pokemon Gemme 3.9
    # @return [Array<PFM::Pokemon>]
    attr_accessor :pokemon_39
    # The $game_variables
    # @return [Game_Variables]
    attr_accessor :game_variables
    # The $game_switches
    # @return [Game_Switches]
    attr_accessor :game_switches
    # The $game_self_switches
    # @return [Game_SelfSwitches]
    attr_accessor :game_self_switches
    # The $game_self_variables
    # @return [Game_SelfVariables]
    attr_accessor :game_self_variables
    # The $game_system
    # @return [Game_System]
    attr_accessor :game_system
    # The $game_screen
    # @return [Game_Screen]
    attr_accessor :game_screen
    # The $game_actors
    # @return [Game_Actors]
    attr_accessor :game_actors
    # The $game_party
    # @return [Game_Party]
    attr_accessor :game_party
    # The $game_map
    # @return [Game_Map]
    attr_accessor :game_map
    # The $game_player
    # @return [Game_Player]
    attr_accessor :game_player
    # The $game_temp
    # @return [Game_Temp]
    attr_accessor :game_temp
    # The pathfinding requests
    # @return [Array<Object>]
    attr_accessor :pathfinding_requests
    # Maximum level an allied Pokemon can reach
    # @return [Integer]
    attr_accessor :level_max_limit
    # Name of the time set to use (nil = default)
    # @return [Symbol, nil]
    attr_accessor :tint_time_set
    # User data
    # @return [Hash]
    attr_reader :user_data
    # Create a new Pokemon Party
    # @param battle [Boolean] if its a party of a NPC battler
    # @param starting_language [String] the lang id of the game described by this object
    def initialize(battle = false, starting_language = 'fr')
      @actors = []
      @bag = PFM::Bag.new
      @repel_count = 0
      @steps = 0
      @level_max_limit = GameData::MAX_LEVEL
      return if battle
      game_state_initialize(starting_language)
      rmxp_boot unless $tester
    end

    private

    # Initialize the game state variable
    # @param starting_language [String] the lang id of the game described by this object
    def game_state_initialize(starting_language)
      @game_variables = Game_Variables.new
      $game_variables ||= @game_variables
      @game_switches = Game_Switches.new
      $game_switches ||= @game_switches
      @game_self_switches = Game_SelfSwitches.new
      @game_self_variables = Game_SelfVariables.new
      @game_temp = Game_Temp.new
      @game_system = Game_System.new
      @game_screen = Game_Screen.new
      @game_actors = Game_Actors.new
      @game_party = Game_Party.new
      @game_troop = Game_Troop.new
      @game_map = Game_Map.new
      @game_player = Game_Player.new
      @pathfinding_requests = Pathfinding::DEFAULT_SAVE
      @max_level = GameData::MAX_LEVEL
      @pokedex = PFM::Pokedex.new
      @trainer = PFM::Trainer.new
      @options = PFM::Options.new(starting_language)
      @storage = PFM::Storage.new
      @env = PFM::Environnement.new
      @wild_battle = PFM::Wild_Battle.new
      @daycare = PFM::Daycare.new
      @berries = {}
      @quests = PFM::Quests.new
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
      $game_variables = @game_variables
      $game_switches = @game_switches
      $game_self_switches = @game_self_switches
      $game_temp = @game_temp
      $game_system = @game_system
      $game_screen = @game_screen
      $game_actors = @game_actors
      $game_party = @game_party
      $game_troop = @game_troop
      $game_map = @game_map
      $game_player = @game_player
      #Accès rapide des variables de $pokemon_party
      $actors = @actors
      $pokedex = @pokedex
      $trainer = @trainer
      $options = @options
      $bag = @bag
      $storage = @storage
      $env = @env
      $wild_battle = @wild_battle
      # Patch 2016-02-12
      @daycare ||= PFM::Daycare.new
      $daycare = @daycare
      # Patch 2017-05-08
      @quests ||= PFM::Quests.new
      $quests = @quests
      # Patch 2017-06-10
      @game_self_variables ||= Game_SelfVariables.new
      $game_self_variables = @game_self_variables
      # Force the pokemon selection to be unset.
      $game_variables[Yuki::Var::Party_Menu_Sel] = -1
      # Patch 2019-05-27
      @pathfinding_requests ||= Pathfinding::DEFAULT_SAVE
      @env.instance_variable_set(:@worldmap, 0) unless @env.instance_variable_defined?(:@worldmap) || @env.frozen?
      unless @env.instance_variable_defined?(:@visited_worldmap) || @env.frozen?
        @env.instance_variable_set(:@visited_worldmap, [0])
      end
      # Patch 2019-08-31
      $pokemon_party.level_max_limit = GameData::MAX_LEVEL unless $pokemon_party.level_max_limit
      # Patch 2019-10-12
      @user_data ||= {}
      $user_data = @user_data
    end

    # Update the processing of the repel
    def repel_update
      return if cant_process_event_tasks?
      if @repel_count > 0
        @repel_count -= 1
        $scene.delay_display_call(:display_repel_check) if @repel_count == 0
      end
    end

    # Update the processing of the battle starting
    def battle_starting_update
      return if cant_process_event_tasks?
      encounter_step = $game_map.encounter_step
      ability = @actors[0]&.ability_db_symbol || :__undef__
      if ENC_FREQ_INC.include?(ability)
        encounter_step *= 1.5
      elsif ENC_FREQ_DEC.include?(ability) ||
            (ENC_FREQ_DEC_HAIL.include?(ability) && $env.hail?) ||
            (ENC_FREQ_DEC_SANDSTORM.include?(ability) && $env.sandstorm?)
        encounter_step *= 0.5
      end
      if !$game_system.encounter_disabled && (@repel_count <= 0) && ((@steps % encounter_step) == 0) &&
         @wild_battle.available?
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
