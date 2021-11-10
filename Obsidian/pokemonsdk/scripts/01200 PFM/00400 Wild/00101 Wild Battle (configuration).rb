module PFM
  class Wild_Battle
    # Hash describing which method to seek to change the Pokemon chances depending on the player's leading Pokemon's talent
    CHANGE_POKEMON_CHANCE = {
      keen_eye: :rate_intimidate_keen_eye,
      intimidate: :rate_intimidate_keen_eye,
      cute_charm: :rate_cute_charm,
      magnet_pull: :rate_magnet_pull,
      compound_eyes: :rate_compound_eyes,
      super_luck: :rate_compound_eyes,
      static: :rate_static,
      lightning_rod: :rate_static,
      flash_fire: :rate_flash_fire,
      synchronize: :rate_synchronize,
      storm_drain: :rate_storm_drain
    }

    private

    # Configure the Pokemon array for later selection
    # @param pokemon [Array<PFM::Pokemon>]
    # @return [Array<Array(PFM::Pokemon, Float)>] all pokemon with their rate to get selected
    def configure_pokemon(pokemon)
      main_pokemon = $actors[0]
      ability = pokemon_ability
      repel_active = $pokemon_party.repel_count > 0
      return pokemon.map do |pkmn|
        rate = 1
        rate = send(CHANGE_POKEMON_CHANCE[ability], pkmn, main_pokemon) if respond_to?(CHANGE_POKEMON_CHANCE[ability] || :__undef__, true)
        # Cleanse tag & repel
        if pkmn.level < main_pokemon.level
          rate *= 0.33 if main_pokemon.item_db_symbol == :cleanse_tag
          rate = 0 if repel_active
        end
        next [pkmn, rate]
      end
    end

    # Get rate for Intimidate/Keen Eye cases
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_intimidate_keen_eye(pkmn, main_pokemon)
      return (pkmn.level + 5) < main_pokemon.level ? 0.5 : 1
    end

    # Get rate for Cute Charm case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_cute_charm(pkmn, main_pokemon)
      return (pkmn.gender * main_pokemon.gender) == 2 ? 1.5 : 1
    end

    # Get rate for Magnet Pull case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_magnet_pull(pkmn, main_pokemon)
      return pkmn.type_steel? ? 1.5 : 1
    end

    # Get rate for Compound Eyes case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_compound_eyes(pkmn, main_pokemon)
      return pkmn.item_db_symbol != :__undef__ ? 1.5 : 1
    end

    # Get rate for Statik case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_static(pkmn, main_pokemon)
      return pkmn.type_electric? ? 1.5 : 1
    end

    # Get rate for Storm Drain case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_storm_drain(pkmn, main_pokemon)
      return pkmn.type_water? ? 1.5 : 1
    end

    # Get rate for Flash Fire case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_flash_fire(pkmn, main_pokemon)
      return pkmn.type_fire? ? 1.5 : 1
    end

    # Get rate for Synchronize case
    # @param pkmn [PFM::Pokemon] pokemon to select
    # @param main_pokemon [PFM::Pokemon] pokemon that caused the rate verification
    # @return [Float] new rate or 1
    def rate_synchronize(pkmn, main_pokemon)
      return pkmn.nature_id == main_pokemon.nature_id ? 1.5 : 1
    end

    # Select the Pokemon that will be in the battle
    # @param wi [PFM::Wild_Info] the descriptor of the Wild group
    # @param pokemon_to_select [Array<Array(PFM::Pokemon, Float)>] list of Pokemon to select with their rates
    # @return [Array<PFM::Pokemon>]
    def select_pokemon(wi, pokemon_to_select)
      # @note i % wi.ids.size is there to prevent bugs due to double battle that basically double the pokemons to ensure we can get twice the same
      #       pokemon
      # @type [Array<Array(PFM::Pokemon, Float)>]
      real_rareness = pokemon_to_select.map.with_index { |arr, i| [arr.first, arr.last * wi.chances[(i % wi.ids.size) + 1]] }
      # @type [Array<Float>]
      reduced_rareness = real_rareness.reduce([]) { |acc, curr| acc << (curr.last + (acc.last || 0)) }
      max_rand = reduced_rareness.last
      # This reducer prevents to select the exact same Pokemon twice
      return wi.vs_type.times.reduce([]) do |acc, _|
        nb = Random::WILD_BATTLE.rand(max_rand.to_i)
        index = reduced_rareness.find_index { |i| i > nb } || real_rareness.size - 1
        pokemon = real_rareness[index].first
        redo if acc.include?(pokemon)
        acc << pokemon
      end
    end

    # Configure the wild battle
    # @param enemy_arr [Array<PFM::Pokemon>]
    # @param battle_id [Integer] ID of the events to load for battle scenario
    # @return [Battle::Logic::BattleInfo]
    def configure_battle(enemy_arr, battle_id)
      return if (!enemy_arr.is_a? Array) || !enemy_arr || enemy_arr&.empty?

      has_roaming = enemy_arr.any? { |pokemon| roaming?(pokemon) }
      info = Battle::Logic::BattleInfo.new
      info.add_party(0, *info.player_basic_info)
      info.add_party(1, enemy_arr, nil, nil, nil, nil, nil, has_roaming ? -1 : 0)
      info.battle_id = battle_id
      info.fishing = !@fish_battle.nil?
      info.vs_type = 2 if enemy_arr.size >= 2
      return info
    end
  end
end
