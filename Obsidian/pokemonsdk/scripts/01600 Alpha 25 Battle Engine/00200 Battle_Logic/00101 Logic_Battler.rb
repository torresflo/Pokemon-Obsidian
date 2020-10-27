module Battle
  class Logic
    # Return the battler of a bank
    # @param bank [Integer] bank where the Pokemon is
    # @param position [Integer] position of the Pokemon in the bank
    # @return [PFM::PokemonBattler, nil]
    def battler(bank, position)
      return nil if position < 0
      return @battlers.dig(bank, position)
    end

    # Return the number of battler (alive) in one bank
    # @param bank [Integer]
    # @return [Integer]
    def battler_count(bank)
      count = 0
      $game_temp.vs_type.times { |i| count += 1 if battler(bank, i)&.dead? == false }
      return count
    end

    # Return the adjacent foes
    # @param pokemon [PFM::PokemonBattler]
    # @return [Array<PFM::PokemonBattler>]
    def adjacent_foes_of(pokemon)
      foes_of(pokemon, true)
    end

    # Return the foes
    # @param pokemon [PFM::PokemonBattler]
    # @param check_adjacent [Boolean]
    # @return [Array<PFM::PokemonBattler>]
    def foes_of(pokemon, check_adjacent = false)
      return [] if pokemon.position.nil? || pokemon.position >= @battle_info.vs_type
      bank = pokemon.bank
      position = pokemon.position
      foes = []
      @battlers.each_with_index do |battlers, index|
        next if index == bank
        battlers.each_with_index do |foe, foe_position|
          break if foe_position >= @battle_info.vs_type
          next unless foe.position
          foes << foe if !check_adjacent || (foe.position - position).abs <= 1
        end
      end
      return foes
    end

    # Return the adjacent allies
    # @param pokemon [PFM::PokemonBattler]
    # @return [Array<PFM::PokemonBattler>]
    def adjacent_allies_of(pokemon)
      allies_of(pokemon, true)
    end

    # Return the allies
    # @param pokemon [PFM::PokemonBattler]
    # @param check_adjacent [Boolean]
    # @return [Array<PFM::PokemonBattler>]
    def allies_of(pokemon, check_adjacent = false)
      return [] if pokemon.position.nil? || pokemon.position >= @battle_info.vs_type
      bank = pokemon.bank
      position = pokemon.position
      allies = []
      @battlers.each_with_index do |battlers, index|
        next if index != bank
        battlers.each_with_index do |ally, ally_position|
          break if ally_position >= @battle_info.vs_type
          next unless ally.position
          next if position == ally_position # We don't want the pokemon
          allies << ally if !check_adjacent || (ally.position - position).abs <= 1
        end
      end
      return allies
    end

    # Load the battlers from the battle infos
    def load_battlers
      @battle_info.parties.each_with_index do |parties, bank|
        next unless parties
        parties.each_with_index do |party, index|
          load_battlers_from_party(party, bank, index)
        end
        adjust_party(@battlers[bank]) if @battle_info.vs_type > 1
        @battle_info.vs_type.times do |i|
          @battlers.dig(bank, i)&.position = i
        end
      end
    end

    private

    # Load the battlers from a party
    # @param party [Array<PFM::Pokemon>]
    # @param bank [Integer]
    # @param index [Integer] index of the party in the parties array (party_id)
    def load_battlers_from_party(party, bank, index)
      party = sort_party(party)
      battlers = (@battlers[bank] ||= [])
      max_level = @battle_info.max_level
      party.each do |pokemon|
        battler = max_level ? PFM::PokemonBattler.new(pokemon, @battle_scene, max_level) : PFM::PokemonBattler.new(pokemon, @battle_scene)
        battler.bank = bank
        battler.party_id = index
        battlers << battler
      end
    end

    # Sort a party (push the dead mon at the end)
    # @param party [Array<PFM::Pokemon>]
    # @return [Array<PFM::Pokemon>]
    def sort_party(party)
      party = party.compact
      dead_mons = party.select(&:dead?)
      party.delete_if { |pokemon| dead_mons.include?(pokemon) }
      party.concat(dead_mons)
    end

    # Make sure the Pokemon of each party are in first position
    # @param party [Array<PFM::PokemonBattler>]
    def adjust_party(party)
      parties = {}
      party.each do |pokemon|
        sub_party = (parties[pokemon.party_id] ||= [])
        sub_party << pokemon
      end
      party.clear
      i = 0
      did_something = true
      while did_something
        did_something = false
        parties.each_value do |sub_party|
          next unless (pokemon = sub_party[i])
          party << pokemon
          did_something = true
        end
        i += 1
      end
    end

    # Switch two pokemon (logically)
    # @param who [PFM::PokemonBattler] Pokemon being switched
    # @param with [PFM::PokemonBattler] Pokemon comming on the ground
    def switch_battlers(who, with)
      with_position = @battlers[who.bank].index(with)
      who_position = @battlers[who.bank].index(who)
      @battlers[who.bank][who_position] = with
      @battlers[with.bank][with_position] = who
      with.position, who.position = who.position, with.position
    end
  end
end
