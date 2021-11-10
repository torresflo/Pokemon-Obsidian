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

      position = pokemon.position
      return @battlers.flat_map.with_index do |battler_bank, bank|
        next nil.to_a if bank == pokemon.bank

        next battler_bank.select.with_index do |foe, foe_position|
          foe.can_fight? && (!check_adjacent || (foe_position - position).abs <= 1)
        end
      end
    end

    # Return the adjacent allies
    # @param pokemon [PFM::PokemonBattler]
    # @return [Array<PFM::PokemonBattler>]
    def adjacent_allies_of(pokemon)
      allies_of(pokemon, true)
    end

    # Return the allies (excluding the pokemon)
    # @param pokemon [PFM::PokemonBattler]
    # @param check_adjacent [Boolean]
    # @return [Array<PFM::PokemonBattler>]
    def allies_of(pokemon, check_adjacent = false)
      return [] if pokemon.position.nil? || pokemon.position >= @battle_info.vs_type

      position = pokemon.position
      return @battlers[pokemon.bank].select.with_index do |ally, ally_position|
        next ally_position != position && ally.can_fight? && (!check_adjacent || (ally_position - position).abs <= 1)
      end
    end

    # Return all the alive battler of a bank
    # @param bank [Integer]
    # @return [Array<PFM::PokemonBattler>]
    def alive_battlers(bank)
      return @battlers[bank].select(&:can_fight?)
    end

    # Return all the alive battler of a bank but don't check can_fight?
    # @param bank [Integer]
    # @return [Array<PFM::PokemonBattler>]
    def alive_battlers_without_check(bank)
      return @battlers[bank].select(&:alive?)
    end

    # Return all alive battlers
    # @return [Array<PFM::PokemonBattler>]
    def all_alive_battlers
      return @battlers.each_index.flat_map { |bank| alive_battlers(bank) }
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

    # Add a switch request
    # @param who [PFM::PokemonBattler]
    # @param with [PFM::PokemonBattler, nil] if nil, ask the player
    def request_switch(who, with)
      @switch_request << { who: who, with: with }
    end

    # Update the turn count of all alive battler
    def update_battler_turn_count
      $game_temp.battle_turn += 1
      all_alive_battlers.each do |pokemon|
        pokemon.turn_count += 1
        pokemon.last_battle_turn = $game_temp.battle_turn
      end
    end

    # Test if the battler attacks before another
    # @param battler [PFM::PokemonBattler]
    # @param other [PFM::PokemonBattler]
    # @return [Boolean]
    def battler_attacks_before?(battler, other)
      return false unless battler.attack_order.integer? && other.attack_order.integer?
      return false if other.dead?

      return battler.attack_order < other.attack_order
    end

    # Test if the battler attacks after another
    # @param battler [PFM::PokemonBattler]
    # @param other [PFM::PokemonBattler]
    # @return [Boolean]
    def battler_attacks_after?(battler, other)
      return false unless battler.attack_order.integer? && other.attack_order.integer?

      return battler.attack_order > other.attack_order
    end

    # Test if the battler attacks first
    # @param battler [PFM::PokemonBattler]
    # @return [Boolean]
    def battler_attacks_first?(battler)
      return battler.attack_order == 0
    end

    # Test if the battler attacks last
    # @param battler [PFM::PokemonBattler]
    # @return [Boolean]
    def battler_attacks_last?(battler)
      last_order = all_alive_battlers.map(&:attack_order).reject { |i| i == Float::INFINITY }.compact.max
      return battler.attack_order == last_order
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
      # Ensure the newly comming pokemon gets the right battle turn
      with.last_battle_turn = $game_temp.battle_turn
    end

    # Iterate through all battlers
    # @yieldparam battler [PFM::PokemonBattler]
    # @return [Enumerable<PFM::PokemonBattler>]
    def all_battlers
      if block_given?
        @battlers.flatten.each { |battler| yield(battler) }
      else
        return @battlers.flatten.each
      end
    end

    # Test if the battler can be replaced
    # @param who [PFM::PokemonBattler]
    # @return [Boolean]
    def can_battler_be_replaced?(who)
      return false if who.effects.has?(&:force_next_move?) && who.alive?

      bank = who.bank
      party_id = who.party_id
      allies = allies_of(who)
      number = all_battlers.count { |pokemon| pokemon.alive? && pokemon.bank == bank && pokemon.party_id == party_id && !allies.include?(pokemon) }
      return number > 0
    end

    # List all the trainer Pokemon
    # @return [Array<PFM::PokemonBattler>]
    def trainer_battlers
      return @battlers[0].compact.select(&:from_party?)
    end

    # Check active abilities on the field
    # @return [Array<PFM::PokemonBattler>]
    def any_field_ability_active?(db_symbol)
      return @battlers.any? { |battlers| battlers.any? { |battler| battler.has_ability?(db_symbol) } }
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
        battler = max_level ? PFM::PokemonBattler.new(pokemon, @scene, max_level) : PFM::PokemonBattler.new(pokemon, @scene)
        battler.bank = bank
        battler.party_id = index
        battler.bag = @bags[bank][index] || PFM::Bag.new
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

    # List all dead enemy Pokemon during this turn
    # @return [Array<PFM::PokemonBattler>]
    def dead_enemy_battler_during_this_turn
      turn = $game_temp.battle_turn
      return 1.upto(bank_count - 1).flat_map do |bank|
        next @battlers[bank].compact.select { |battler| battler.last_battle_turn == turn && battler.dead? }
      end
    end

    # List all dead friend Pokemon during this turn
    # @return [Array<PFM::PokemonBattler>]
    def dead_friend_battler_during_this_turn
      turn = $game_temp.battle_turn
      return @battlers[0].compact.select { |battler| battler.last_battle_turn == turn && battler.dead? && !battler.from_party? }
    end
  end
end
