module PFM
  # Daycare management system
  #
  # The global Daycare manager is stored in $daycare and $pokemon_party.daycare
  # @author Nuri Yuri
  #
  # Daycare data Hash format
  #   pokemon: Array # The list of Pokemon in the daycare (PFM::Pokemon or nil)
  #   level: Array # The list of level the Pokemon had when sent to the daycare
  #   layable: Integer # ID of the Pokemon that can be in the egg
  #   rate: Integer # Chance the egg can be layed
  #   egg: Boolean # If an egg has been layed
  class Daycare
    include GameData::Daycare

    # Create the daycare manager
    def initialize
      @daycares = []
    end

    # Update every daycare
    def update
      check_egg = should_check_eggs?
      @daycares.each do |daycare|
        next unless daycare
        daycare[:pokemon].each { |pokemon| exp_pokemon(pokemon) }
        try_to_lay(daycare) if check_egg && (daycare[:layable] || 0) != 0
      end
    end

    # Store a Pokemon to a daycare
    # @param id [Integer] the ID of the daycare
    # @param pokemon [PFM::Pokemon] the pokemon to store in the daycare
    # @return [Boolean] if the pokemon could be stored in the daycare
    def store(id, pokemon)
      @daycares[id] ||= { pokemon: [], level: [], layable: 0, rate: 0, egg: nil }
      return false if full?(id)
      daycare = @daycares[id]
      daycare[:level][daycare[:pokemon].size] = pokemon.level
      daycare[:pokemon] << pokemon
      layable_check(daycare, daycare[:pokemon]) if daycare[:pokemon].size == 2
      log_debug "==== Pension Infos ====\nRate : #{daycare[:rate]}%\nPokémon : #{text_get(0, daycare[:layable])}\n"
      return true
    end

    # Price to pay in order to withdraw a Pokemon
    # @param id [Integer] the ID of the daycare
    # @param index [Integer] the index of the Pokemon in the daycare
    # @return [Integer] the price to pay
    def price(id, index)
      return 0 unless (pokemon = @daycares.dig(id, :pokemon, index))
      return PRICE_RATE[id] * (pokemon.level - @daycares.dig(id, :level, index) + 1)
    end

    # Get a Pokemon information in the daycare
    # @param id [Integer] the ID of the daycare
    # @param index [Integer] the index of the Pokemon in the daycare
    # @param prop [Symbol] the method to call of PFM::Pokemon to get the information
    # @param args [Array] the list of arguments of the property
    # @return [Object] the result
    def get_pokemon(id, index, prop, *args)
      return nil unless (pokemon = @daycares.dig(id, :pokemon, index))
      return pokemon.send(prop, *args)
    end

    # Withdraw a Pokemon from a daycare
    # @param id [Integer] the ID of the daycare
    # @param index [Integer] the index of the Pokemon in the daycare
    # @return [PFM::Pokemon, nil]
    def retrieve_pokemon(id, index)
      return nil unless (daycare = @daycares[id]) && (pokemon = daycare.dig(:pokemon, index))
      daycare[:pokemon][index] = nil
      daycare[:level][index] = nil
      daycare[:pokemon].compact!
      daycare[:level].compact!
      daycare[:rate] = 0
      daycare[:layable] = 0
      return pokemon
    end
    alias withdraw_pokemon retrieve_pokemon
    alias retreive_pokemon retrieve_pokemon

    # Get the egg rate of a daycare
    # @param id [Integer] the ID of the daycare
    # @return [Integer]
    def retrieve_egg_rate(id)
      return @daycares[id][:rate].to_i
    end
    alias retreive_egg_rate retrieve_egg_rate

    # Retrieve the egg layed
    # @param id [Integer] the ID of the daycare
    # @return [PFM::Pokemon]
    def retrieve_egg(id)
      daycare = @daycares[id]
      daycare[:egg] = nil
      layable_check(daycare, daycare[:pokemon])
      log_debug "==== Pension Infos ====\nRate : #{daycare[:rate]}%\nPokémon : #{text_get(0, daycare[:layable])}\n"
      pokemon = PFM::Pokemon.new(daycare[:layable], 1)
      inherit(pokemon, daycare[:pokemon])
      pokemon.egg_init
      pokemon.memo_text = [28, 31]
      return pokemon
    end
    alias retreive_egg retrieve_egg

    # If an egg was layed in this daycare
    # @param id [Integer] the ID of the daycare
    # @return [Boolean]
    def layed_egg?(id)
      return @daycares.dig(id, :egg) == true
    end
    alias has_egg? layed_egg?

    # If a daycare is full
    # @param id [Integer] the ID of the daycare
    # @return [Boolean]
    def full?(id)
      return false unless (pokemon_list = @daycares.dig(id, :pokemon))
      return pokemon_list.size > 1
    end

    # If a daycare is empty
    # @param id [Integer] the ID of the daycare
    # @return [Boolean]
    def empty?(id)
      return @daycares.dig(id, :pokemon).empty?
    end

    # Parse the daycare Pokemon text info
    # @param var_id [Integer] ID of the game variable where the ID of the daycare is stored
    # @param index [Integer] index of the Pokemon in the daycare
    def parse_poke(var_id, index)
      # @type [PFM::Pokemon]
      pokemon = @daycares.dig($game_variables[var_id], :pokemon, index)
      (text = PFM::Text).set_num3(pokemon.level_text)
      text.set_pkname(pokemon.name)
      parse_text(36, 33 + (pokemon.gender == 0 ? 3 : pokemon.gender))
    end

    private

    # Check the layability of a daycare
    # @param daycare [Hash] the daycare informations Hash
    # @param parents [Array] the list of Pokemon in the daycar
    def layable_check(daycare, parents)
      # @type [PFM::Pokemon]
      male, female = assign_gender(parents)
      rate = perform_simple_rate_calculation(male, female)
      daycare[:rate] = rate
      # If there's a change to breed, we try to find the right baby using the special lay check
      if rate != 0
        return if special_lay_check(daycare, female, male)
        male_data, female_data = get_pokemon_data(male, female)
        daycare[:layable] = female_data.baby
        daycare[:rate] = 0 if daycare[:layable] == 0
      else
        daycare[:layable] = 0
      end
    end

    # Special check to lay an egg
    # @param daycare [Hash] the daycare information
    # @param female [PFM::Pokemon] the female
    # @param male [PFM::Pokemon] the male
    # @return [Integer, false] the id of the Pokemon that will be in the egg or no special baby with these Pokemon
    def special_lay_check(daycare, female, male)
      female_sym = female.db_symbol
      male_sym = male.db_symbol
      # Ditto + (Phione / Manaphy)
      if male.db_symbol == :ditto && BREEDING_WITH_DITTO.include?(female_sym)
        return daycare[:layable] = GameData::Pokemon.get_id(:phione)
      elsif NOT_BREEDING.include?(female_sym) || NOT_BREEDING.include?(male_sym)
        daycare[:layable] = 0
        return daycare[:rate] = 0
      end
      # @type [Array<Symbol>] list of baby the Pokemon can breed
      if (variable_baby = BABY_VARIATION[female_sym])
        return daycare[:layable] = GameData::Pokemon.get_id(variable_baby.sample)
      end
      # @type [IncenseInfo]
      if (insence_info = INCENSE_BABY[female_sym]) && male.item_db_symbol == insence_info.incense
        return daycare[:layable] = GameData::Pokemon.get_id(insence_info.baby)
      end
      return false
    end

    # Give 1 exp point to a pokemon 
    # @param pokemon [PFM::Pokemon] the pokemon to give one exp point
    def exp_pokemon(pokemon)
      return if pokemon.level >= $pokemon_party.level_max_limit
      pokemon.exp += 1
      if pokemon.exp >= pokemon.exp_lvl
        pokemon.level_up_stat_refresh
        pokemon.check_skill_and_learn(true)
        pc "==== Pension Infos ====\nLevelUp : #{pokemon.given_name}\n"
      end
    end

    # Attempt to lay an egg
    # @param daycare [Hash] the daycare informations Hash
    def try_to_lay(daycare)
      return if daycare[:egg]
      daycare[:egg] = true if rand(100) < daycare[:rate]
      log_debug "==== Pension Infos ====\nLay attempt : #{!daycare[:egg] ? 'Failure' : 'Success'}\n"
    end

    # Make the pokemon inherit the gene of its parents
    # @param pokemon [PFM::Pokemon] the pokemon
    # @param parents [Array(PFM::Pokemon, PFM::Pokemon)] the parents
    def inherit(pokemon, parents)
      # @type [PFM::Pokemon]
      male, female = assign_gender(parents)

      # Inherit sequence
      unless NON_INHERITED_BALL.include?(GameData::Item.db_symbol(female.captured_with))
        pokemon.captured_with = female.captured_with
      end

      pokemon.nature = male.nature_id if male.item_db_symbol == :everstone
      pokemon.nature = female.nature_id if female.item_db_symbol == :everstone

      inherit_ability(pokemon, female)
      inherit_moves(pokemon, male, female)
      inherit_iv(pokemon, male, female)
    end

    # Tell if the system should check for eggs in this update
    # @return [Boolean]
    def should_check_eggs?
      ($pokemon_party.steps & 0xFF) == 0
    end

    # Return the parents in male, female order (to make the lay process easier)
    # @param potential_male [PFM::Pokemon]
    # @param potential_female [PFM::Pokemon]
    # @return [Array<PFM::Pokemon>]
    def assign_gender((potential_male, potential_female))
      # If the potential male is a female, potential_female is a male
      # If the potential_female is a ditto, potential_male will be the mother
      if potential_male.gender == 2 || potential_female.db_symbol == :ditto
        potential_male, potential_female = potential_female, potential_male
      end
      # Otherwise potential_male is a "male" and potential_female is a "female"
      return potential_male, potential_female
    end

    # Return the data of each breedable Pokemon
    # @param male [PFM::Pokemon]
    # @param female [PFM::Pokemon]
    # @return [Array<GameData::Pokemon>]
    def get_pokemon_data(male, female)
      return male.data, female.data unless USE_FIRST_FORM_BREED_GROUPS

      return male.primary_data, female.primary_data
    end

    # Return the egg rate (% chance of having an egg)
    # @param male [PFM::Pokemon]
    # @param female [PFM::Pokemon]
    # @return [Integer]
    def perform_simple_rate_calculation(male, female)
      return 0 if male.gender != 0 && male.gender == female.gender
      # @type [GameData::Pokemon]
      male_data, female_data = get_pokemon_data(male, female)
      if male_data.breed_groupes.include?(NOT_BREEDING_GROUP) || female_data.breed_groupes.include?(NOT_BREEDING_GROUP)
        return 0
      end
      common_in_group = (female_data.breed_groupes - (female_data.breed_groupes - male_data.breed_groupes)).uniq
      common_ot = male.trainer_id == female.trainer_id
      oval_charm = $bag.contain_item?(:oval_charm)
      return EGG_RATE.dig(common_in_group.any?.to_i, common_ot.to_i, oval_charm.to_i) || 0
    end

    # Make the Pokemon inherit the female ability
    # If the ability is the hidden one, it'll have 60% chance, otherwise 80% chance
    # @param pokemon [PFM::Pokemon]
    # @param female [PFM::Pokemon]
    def inherit_ability(pokemon, female)
      ability = female.ability
      chances = female.get_data.abilities.index(ability) == 2 ? 60 : 80
      if rand(100) < chances
        pokemon.ability = ability
        pokemon.ability_index = nil
        pokemon.update_ability
      end
    end

    # Make the Pokemon inherit the parents moves
    # @param pokemon [PFM::Pokemon]
    # @param male [PFM::Pokemon]
    # @param female [PFM::Pokemon]
    def inherit_moves(pokemon, male, female)
      female_moveset = female.get_data.move_set.select.with_index { |_, index| index.odd? }
      male_moveset = male.get_data.move_set.select.with_index { |_, index| index.odd? }
      pokemon_moveset = pokemon.get_data.move_set.select.with_index { |_, index| index.odd? }
      # Take moves known by male, female & pokemon
      common_skill = female_moveset - (female_moveset - male_moveset)
      common_skill = pokemon_moveset - (pokemon_moveset - common_skill)
      # Try to teach all the skill both parents know and have in common with baby
      common_skill.each do |skill_id|
        next unless female.skill_learnt?(skill_id) && male.skill_learnt?(skill_id)
        learn_skill(pokemon, skill_id)
      end
      # Try to teach all the breed move known by the male
      breed_moves = GameData::Pokemon[pokemon.id, pokemon.form].breed_moves.each do |skill_id|
        next unless male.skill_learnt?(skill_id)
        learn_skill(pokemon, skill_id)
      end
      # Try to teach all the breed move known by the female
      breed_moves.each do |skill_id|
        next unless female.skill_learnt?(skill_id)
        learn_skill(pokemon, skill_id)
      end
    end

    # Teach a skill to the Pokemon
    # @param pokemon [PFM::Pokemon]
    # @param skill_id [Integer] ID of the skill in the database
    def learn_skill(pokemon, skill_id)
      return if pokemon.learn_skill(skill_id).nil? # Skill learn with succes or already learnt
      pokemon.skills_set.shift
      pokemon.learn_skill(skill_id)
    end

    # Inherit the IV
    # @param pokemon [PFM::Pokemon]
    # @param male [PFM::Pokemon]
    # @param female [PFM::Pokemon]
    def inherit_iv(pokemon, male, female)
      if female.item_db_symbol == :destiny_knot || male.item_db_symbol == :destiny_knot
        inherit_iv_destiny_knot(pokemon, male, female)
      else
        inherit_iv_regular(pokemon, male, female)
      end
      inherit_iv_power(pokemon, male, female)
    end

    # Inherit the IV when one of the parent holds the destiny knot.
    # It'll transmit 5 of the IV (of both parents randomly) to the child
    # @param pokemon [PFM::Pokemon]
    # @param parents [Array<PFM::Pokemon>]
    def inherit_iv_destiny_knot(pokemon, *parents)
      IV_GET.sample(5).each do |iv|
        setter = IV_SET[IV_GET.index(iv)]
        pokemon.send(setter, parents.sample.send(iv))
      end
    end

    # Regular IV inherit from parents.
    # 3 attempt to inherit the IV.
    #   The first attempt will give one of the IV of any parent
    #   The second will give one of the IV (excluding HP) of any parent
    #   The third will give one of the IV (excluding HP & DFE) of any parent
    # All attempt can overwrite the previous one (if the stat is the same)
    # @note This works thanks to the IV_GET & IV_SET constant configuration!
    # @param pokemon [PFM::Pokemon]
    # @param parents [Array<PFM::Pokemon>]
    def inherit_iv_regular(pokemon, *parents)
      iv_get = IV_GET.clone
      3.times do
        iv = iv_get.sample
        setter = IV_SET[IV_GET.index(iv)]
        pokemon.send(setter, parents.sample.send(iv))
        iv_get.shift # Remove :iv_hp and then :iv_dfe
      end
    end

    # IV inherit from parents holding power item
    # @param pokemon [PFM::Pokemon]
    # @param parents [Array<PFM::Pokemon>]
    def inherit_iv_power(pokemon, *parents)
      parents.each do |parent|
        next unless (iv_index = IV_POWER_ITEM.index(parent.item_db_symbol))
        pokemon.send(IV_SET[iv_index], parent.send(IV_GET[iv_index]))
      end
    end
  end

  class Pokemon_Party
    # The daycare management object
    # @return [PFM::Daycare]
    attr_accessor :daycare
    on_player_initialize(:daycare) { @daycare = PFM::Daycare.new }
    on_expand_global_variables(:daycare) do
      # Variable containing the daycare information
      $daycare = @daycare
    end
  end
end
