module PFM
  # The wild battle management
  #
  # The main object is stored in $wild_battle and PFM.game_state.wild_battle
  class Wild_Battle
    # The number of zone type that can be stored
    MAX_ZONE_COUNT = 10
    # List of ability that force strong Pokemon to battle (Intimidation / Regard vif)
    WEAK_POKEMON_ABILITY = %i[intimidate keen_eye]
    # List of special wild battle that are actually fishing
    FISHING_BATTLES = %i[normal super mega]
    # List of Roaming Pokemon
    # @return [Array<PFM::Wild_RoamingInfo>]
    attr_reader :roaming_pokemons
    # List of Remaining Pokemon groups
    #
    # [ (grass)[(tag 0)Wild_info, (tag1)Wild_info,...], (tall_grass)[...], ...]
    # @return [Array<Array<PFM::Wild_Info>>]
    attr_reader :remaining_pokemons
    # The fish group information
    # @return [Hash]
    attr_reader :fishing
    # The actual code to determine if the group should be realoaded (Time change)
    # @return [Integer]
    attr_reader :code
    # Create a new Wild_Battle manager
    def initialize
      @roaming_pokemons = []
      @remaining_pokemons = Array.new(MAX_ZONE_COUNT) { [] }
      @forced_wild_battle = false
      @fishing = {}
      @code = 0
    end

    # Reset the wild battle
    def reset
      @remaining_pokemons.each(&:clear)
      @roaming_pokemons.each(&:update)
      @roaming_pokemons.delete_if(&:pokemon_dead?)
      PFM::Wild_RoamingInfo.lock
      # @forced_wild_battle=false
      @fishing.clear
      @fishing[:normal] = []
      @fishing[:super] = []
      @fishing[:mega] = []
      @fishing[:rock] = []
      @fishing[:headbutt] = []
      @fished = false
      @fish_battle = nil
    end

    # Load the groups of Wild Pokemon (map change/ time change)
    def load_groups
      groups = $env.get_current_zone_data.groups
      @code = groups.size
      sw = nil
      groups&.each do |group|
        map_id = group.instance_variable_get(:@map_id) || 0
        if map_id == 0 || $game_map.map_id == map_id
          sw = group.instance_variable_get(:@enable_switch)
          set(*group) if !sw or $game_switches[sw]
          @code = (@code * 2 + sw) if sw && $game_switches[sw]
        end
      end
    end

    # Is a wild battle available ?
    # @return [Boolean]
    def available?
      return false if $scene.is_a?(Battle::Scene)
      return false unless $actors[0]
      return true if @fish_battle
      return true if roaming_battle_available?

      @forced_wild_battle = false
      return remaining_battle_available?
    end

    # Test if there's any fish battle available and start it if asked.
    # @param rod [Symbol] the kind of rod used to fish : :norma, :super, :mega
    # @param start [Boolean] if the battle should be started
    # @return [Boolean, nil] if there's a battle available
    def any_fish?(rod = :normal, start = false)
      st = $game_player.front_system_tag
      zone_type = (st == 399 ? 6 : (st == 405 ? 7 : 0))
      if $env.can_fish? && @fishing[rod] && @fishing[rod][zone_type]
        if start
          @fish_battle = @fishing[rod][zone_type]
          if FISHING_BATTLES.include?(rod)
            @fished = true
          else
            @fished = false
          end
        else
          return true
        end
      else
        return false
      end
      return nil
    end

    # Test if there's any hidden battle available and start it if asked.
    # @param rod [Symbol] the kind of rod used to fish : :rock, :headbutt
    # @param start [Boolean] if the battle should be started
    # @return [Boolean, nil] if there's a battle available
    def any_hidden_pokemon?(rod = :rock, start = false)
      zone_type = $env.convert_zone_type($game_player.front_system_tag)
      if @fishing[rod] && @fishing[rod][zone_type]
        if start
          @fish_battle = @fishing[rod][zone_type]
          @fished = false
        else
          return true
        end
      else
        return false
      end
      return nil
    end

    # Start a wild battle
    # @overload start_battle(id, level, *args)
    #   @param id [PFM::Pokemon] First Pokemon in the wild battle.
    #   @param level [Object] ignored
    #   @param args [Array<PFM::Pokemon>] other pokemon in the wild battle.
    #   @param battle_id [Integer] ID of the events to load for battle scenario
    # @overload start_battle(id, level, *args)
    #   @param id [Integer] id of the Pokemon in the database
    #   @param level [Integer] level of the first Pokemon
    #   @param args [Array<Integer, Integer>] array of id, level of the other Pokemon in the wild battle.
    #   @param battle_id [Integer] ID of the events to load for battle scenario
    def start_battle(id, level = 70, *others, battle_id: 1)
      init_battle(id, level, *others)
      Graphics.freeze
      $scene = Battle::Scene.new(setup(battle_id))
      Yuki::FollowMe.set_battle_entry
    end

    # Init a wild battle
    # @note Does not start the battle
    # @overload init_battle(id, level, *args)
    #   @param id [PFM::Pokemon] First Pokemon in the wild battle.
    #   @param level [Object] ignored
    #   @param args [Array<PFM::Pokemon>] other pokemon in the wild battle.
    # @overload init_battle(id, level, *args)
    #   @param id [Integer] id of the Pokemon in the database
    #   @param level [Integer] level of the first Pokemon
    #   @param args [Array<Integer, Integer>] array of id, level of the other Pokemon in the wild battle.
    def init_battle(id, level = 70, *others)
      if id.class == PFM::Pokemon
        @forced_wild_battle = [id, *others]
      else
        id = GameData::Pokemon.get_id(id) if id.is_a?(Symbol)
        @forced_wild_battle = [PFM::Pokemon.new(id, level)]
        0.step(others.size - 1, 2) do |i|
          others[i] = GameData::Pokemon.get_id(others[i]) if others[i].is_a?(Symbol)
          @forced_wild_battle << PFM::Pokemon.new(others[i], others[i + 1])
        end
      end
    end

    # Set the Battle::Info with the right information
    # @param battle_id [Integer] ID of the events to load for battle scenario
    # @return [Battle::Logic::BattleInfo, nil]
    def setup(battle_id = 1)
      # If it was a forced battle
      return configure_battle(@forced_wild_battle, battle_id) if @forced_wild_battle
      # @type [Wild_Info]
      return nil unless (wi = @fish_battle || @remaining_pokemons[$env.get_zone_type][$game_player.terrain_tag])

      pokemon_to_select = configure_pokemon(wi.pokemon)
      selected_pokemon = select_pokemon(wi, pokemon_to_select)
      return configure_battle(selected_pokemon, battle_id)
    ensure
      @forced_wild_battle = false
      @fish_battle = nil
    end

    # Define a group of remaining wild battle
    # @param zone_type [Integer] type of the zone, see $env.get_zone_type to know the id
    # @param tag [Integer] terrain_tag on which the player should be to start a battle with wild Pokemon of this group
    # @param delta_level [Integer] the disparity of the Pokemon levels
    # @param vs_type [Integer] the vs_type the Wild Battle are
    # @param data [Array<Integer, Integer, Integer>, Array<Integer, Hash, Integer>] Array of id, level/informations, chance to see (Pokemon informations)
    def set(zone_type, tag, delta_level, vs_type, *data)
      return if MAX_ZONE_COUNT <= zone_type
      wi = Wild_Info.new
      ids = wi.ids
      levels = wi.levels
      chances = wi.chances
      wi.vs_type = vs_type
      if (data.size / 3 * 3) != data.size
        raise ArgumentError, "Wild Pokémon aren't correctly configured"
      end
      0.step(data.size - 1, 3) do |i|
        j = i / 3
        ids[j] = data[i]
        levels[j] = data[i + 1]
        chances[j + 1] = data[i + 2]
      end
      if tag < 8
        @remaining_pokemons[zone_type][tag] = wi
      elsif tag < 11
        @fishing[tag == 8 ? :normal : tag == 9 ? :super : :mega][zone_type] = wi
      else
        @fishing[tag == 11 ? :rock : :headbutt][zone_type] = wi
      end
      wi.delta_level = delta_level
    end

    # Test if a Pokemon is a roaming Pokemon (Usefull in battle)
    # @return [Boolean]
    def roaming?(pokemon)
      return roaming_pokemons.any? { |info| info.pokemon == pokemon }
    end
    alias is_roaming? roaming?

    # Add a roaming Pokemon
    # @param chance [Integer] the chance divider to see the Pokemon
    # @param proc_id [Integer] ID of the Wild_RoamingInfo::RoamingProcs
    # @param pokemon_hash [Hash] the Hash that help the generation of the Pokemon, see PFM::Pokemon#generate_from_hash
    # @return [PFM::Pokemon] the generated roaming Pokemon
    def add_roaming_pokemon(chance, proc_id, pokemon_hash)
      pokemon = ::PFM::Pokemon.generate_from_hash(pokemon_hash)
      PFM::Wild_RoamingInfo.unlock
      @roaming_pokemons << Wild_RoamingInfo.new(pokemon, chance, proc_id)
      PFM::Wild_RoamingInfo.lock
      @code += 1
      return pokemon
    end

    # Remove a roaming Pokemon from the roaming Pokemon array
    # @param pokemon [PFM::Pokemon] the Pokemon that should be removed
    def remove_roaming_pokemon(pokemon)
      roaming_pokemons.delete_if { |i| i.pokemon == pokemon }
    end

    # Ability that increase the rate of any fishing rod # Glue / Ventouse
    FishIncRate = %i[sticky_hold suction_cups]

    # Check if a Pokemon can be fished there with a specific fishing rod type
    # @param type [Symbol] :mega, :super, :normal
    # @return [Boolean]
    def check_fishing_chances(type)
      case type
      when :mega
        rate = 60
      when :super
        rate = 45
      else
        rate = 30
      end
      rate *= 1.5 if FishIncRate.include?(pokemon_ability)
      return rate < rand(100)
    end

    # yield a block on every available roaming Pokemon
    def each_roaming_pokemon
      @roaming_pokemons.each do |roaming_info|
        yield(roaming_info.pokemon)
      end
    end

    # Tell the roaming pokemon that the playe has look at their position
    def on_map_viewed
      @roaming_pokemons.each do |info|
        info.spotted = true
      end
    end

    private

    # Test if a roaming battle is available
    # @return [Boolean]
    def roaming_battle_available?
      # @type [PFM::Wild_RoamingInfo]
      return false unless (info = roaming_pokemons.find(&:appearing?))

      PFM::Wild_RoamingInfo.unlock
      info.spotted = true
      init_battle(info.pokemon)
      return true
    end

    # Test if a remaining battle is available
    # @return [Boolean]
    def remaining_battle_available?
      # @type [PFM::Wild_Info]
      return false unless (group = remaining_pokemons.dig($env.get_zone_type, $game_player.terrain_tag))
      return false unless group.is_a?(Wild_Info)

      actor_level = $actors[0].level
      levels = group.levels.map { |level| level.is_a?(Integer) ? level : level[:level] }
      return false if PFM.game_state.repel_count > 0 && levels.none? { |level| level >= actor_level }
      return levels.any? { |level| level + 5 >= actor_level } || rand(100) < 50 if WEAK_POKEMON_ABILITY.include?(pokemon_ability)

      return true
    end

    # Function that returns the Pokemon ability of the Pokemon triggering all the stuff related to ability
    # @return [Symbol] db_symbol of the ability
    def pokemon_ability
      return :__undef__ unless $actors[0]

      return $actors[0].ability_db_symbol
    end
  end

  class GameState
    # The informations about the Wild Pokemon Battle
    # @return [PFM::Wild_Battle]
    attr_accessor :wild_battle
    on_player_initialize(:wild_battle) { @wild_battle = PFM::Wild_Battle.new }
    on_expand_global_variables(:wild_battle) do
      # Variable containing the Wild Pokemon (Remaining & Romaing) information.
      # It's also able to start battle against Wild Pokemon
      $wild_battle = @wild_battle
    end
  end
end
