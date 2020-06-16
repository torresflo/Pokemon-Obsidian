class Interpreter
  # Try to add Pokemon to the party or store the Pokemon in the storage system
  # @param pokemon [PFM::Pokemon]
  # @return [PFM::Pokemon]
  def internal_add_pokemon_final(pokemon)
    return_value = $pokemon_party.add_pokemon(pokemon)
    if return_value.is_a?(Integer)
      $game_switches[Yuki::Sw::SYS_Stored] = true
    elsif return_value
      $game_switches[Yuki::Sw::SYS_Stored] = false
    else
      raise "Management Error :\nThe last Pokémon couldn't added to the team\nor to the storage system..."
    end
    return pokemon
  end

  # Check the symbol of the Pokemon and send the Pokemon to method_name
  # @param pokemon_or_id [Symbol] Symbol ID of the Pokemon in the database
  # @param level [Integer] level of the Pokemon to add
  # @param shiny [Integer, Boolean] the shiny chance
  # @param method_name [Symbol] Method to use in order to add the Pokemon somewhere
  # @return [PFM::Pokemon]
  def internal_add_pokemon_check_symbol(pokemon_or_id, level, shiny, method_name)
    id = GameData::Pokemon.get_id(pokemon_or_id)
    raise "Database Error : The Pokémon #{pokemon_or_id} doesn't exists." if id == 0
    send(method_name, id, level, shiny)
  end

  # Check the input parameters and send the Pokemon to method_name
  # @param pokemon_id [Integer] ID of the Pokemon in the database
  # @param level [Integer] level of the Pokemon to add
  # @param shiny [Integer, Boolean] the shiny chance
  # @param method_name [Symbol] Method to use in order to add the Pokemon somewhere
  # @return [PFM::Pokemon]
  def internal_add_pokemon_check_level_shiny(pokemon_id, level, shiny, method_name)
    do_not_add = false
    # Check parameters
    unless GameData::Pokemon.id_valid?(pokemon_id)
      do_not_add = "Database Error : The Pokémon ##{pokemon_id} doesn't exists."
    end
    if level < 1 || level > $pokemon_party.level_max_limit
      do_not_add << 10 if do_not_add
      do_not_add = "#{do_not_add}Level Error : level #{level} is out of bound."
    end
    raise do_not_add if do_not_add

    # Shiny attribute management
    shiny = rand(shiny) == 0 if shiny.is_a?(Integer) && shiny > 0
    pokemon = PFM::Pokemon.new(pokemon_id, level.abs, shiny, shiny == 0)
    return send(method_name, pokemon)
  end

  # Try to add Pokemon to the party or store the Pokemon in the storage system
  # @param pokemon [PFM::Pokemon]
  # @return [PFM::Pokemon]
  def internal_store_pokemon_final(pokemon)
    return_value = $storage.store(pokemon)
    raise 'Management Error : The Pokemon couldn\'t be stored...' unless return_value
    $game_switches[Yuki::Sw::SYS_Stored] = true
    return pokemon
  end
end
