module PFM
  # Wild Roaming Pokemon informations
  # @author Nuri Yuri
  class Wild_RoamingInfo
    # The tag in which the Roaming Pokemon will appear
    # @return [Integer]
    attr_accessor :tag
    # The system_tag zone ID in which the Roaming Pokemon will appear
    # @return [Integer]
    attr_accessor :zone_type
    # The ID of the map in which the Roaming Pokemon will appear
    # @return [Integer]
    attr_accessor :map_id
    # The roaming Pokemon
    # @return [PFM::Pokemon]
    attr_reader :pokemon
    # The spotted state of the pokemon. True if the player look at the map position or after fighting the roaming pokemon
    # @return [Boolean]
    attr_accessor :spotted

    # True if the roaming informations can't be updated
    @@locked = true
    # Allow roaming informations to be updated
    def self.unlock
      @@locked = false
    end
    # Disallow roaming informations to be updated
    def self.lock
      @@locked = true
    end

    # Create a new Wild_RoamingInfo
    # @param pokemon [PFM::Pokemon] the roaming Pokemon
    # @param chance [Integer] the chance divider to see the Pokemon
    # @param zone_proc_id [Integer] ID of the Wild_RoamingInfo::RoamingProcs
    def initialize(pokemon, chance, zone_proc_id)
      @pokemon = pokemon
      @proc_id = zone_proc_id
      @map_id = -1
      @chance = chance
      @tag = 0
      @zone_type = -1
      @spotted = true
      update
    end

    # Call the Roaming Proc to update the Roaming Pokemon zone information
    def update
      RoamingProcs[@proc_id]&.call(self) unless @@locked
    end

    # Test if the Pokemon is dead (delete from the stack)
    # @return [Boolean]
    def pokemon_dead?
      @pokemon.dead?
    end

    # Test if the Roaming Pokemon is appearing (to start the battle)
    # @return [Boolean]
    def appearing?
      return false if @pokemon.hp <= 0
      if @map_id == $game_map.map_id &&
         @zone_type == $env.get_zone_type(true) &&
         @tag == $game_player.terrain_tag
        return rand(@chance) == 0
      end
      return false
    end

    # Test if the Roaming Pokemon could appear here
    # @return [Boolean]
    def could_appear?
      return (@map_id == $game_map.map_id &&
        @zone_type == $env.get_zone_type(true) &&
        @tag == $game_player.terrain_tag)
    end
  end
end
# The procs of Roaming Pokemon.
# 
# The proc takes the Wild_RoamingInfo in parameter and change the informations.
::PFM::Wild_RoamingInfo::RoamingProcs = [
  proc do |infos|
    infos.map_id = 1
    infos.zone_type = 1
    infos.tag = 1
  end,
  proc do |infos|
    maps = [25, 46, 35, 27] # Maps where the pokemon can spawn
    if (infos.map_id == $game_map.map_id && infos.spotted) || infos.map_id == -1
      infos.map_id = (maps - [infos.map_id]).sample
      infos.spotted = false
    end
    infos.zone_type = 1
    infos.tag = 0
  end
]
