class Interpreter
  # Add a pokemon to the party or store it in the PC
  # @param pokemon_or_id [Integer, Symbol, PFM::Pokemon] the ID of the pokemon in the database or a Pokemon
  # @param level [Integer] the level of the Pokemon (if ID given)
  # @param shiny [Boolean, Integer] true means the Pokemon will be shiny, 0 means it'll have no chance to be shiny, other number are the chance (1 / n) the pokemon can be shiny.
  # @return [PFM::Pokemon, nil] if nil, the Pokemon couldn't be stored in the PC or added to the party. Otherwise it's the Pokemon that was added.
  # @author Nuri Yuri
  def add_pokemon(pokemon_or_id, level = 5, shiny = false)
    return internal_add_pokemon_final(pokemon_or_id) if pokemon_or_id.is_a?(PFM::Pokemon)
    return internal_add_pokemon_check_level_shiny(pokemon_or_id, level, shiny, :add_pokemon) if pokemon_or_id.is_a?(Integer)
    return internal_add_pokemon_check_symbol(pokemon_or_id, level, shiny, :add_pokemon) if pokemon_or_id.is_a?(Symbol)
    raise 'Argument Error : Pokémon ID cannot be string' if pokemon_or_id.is_a?(String)
    nil
  end
  alias ajouter_pokemon add_pokemon
  alias ajouter_stocker_pokemon add_pokemon

  # Store a Pokemon in the PC
  # @param pokemon_or_id [Integer, Symbol, PFM::Pokemon] the ID of the pokemon in the database or a Pokemon
  # @param level [Integer] the level of the Pokemon (if ID given)
  # @param shiny [Boolean, Integer] true means the Pokemon will be shiny, 0 means it'll have no chance to be shiny, other number are the chance (1 / n) the pokemon can be shiny.
  # @return [PFM::Pokemon, nil] if nil, the Pokemon couldn't be stored in the PC. Otherwise it's the Pokemon that was added.
  # @author Nuri Yuri
  def store_pokemon(pokemon_or_id, level = 5, shiny = false)
    return internal_store_pokemon_final(pokemon_or_id) if pokemon_or_id.is_a?(PFM::Pokemon)
    return internal_add_pokemon_check_level_shiny(pokemon_or_id, level, shiny, :store_pokemon) if pokemon_or_id.is_a?(Integer)
    return internal_add_pokemon_check_symbol(pokemon_or_id, level, shiny, :store_pokemon) if pokemon_or_id.is_a?(Symbol)
    raise 'Argument Error : Pokémon ID cannot be string' if pokemon_or_id.is_a?(String)
    nil
  end
  alias stocker_pokemon store_pokemon

  # Add a pokemon (#add_pokemon) with specific informations. 
  # @param hash [Hash] the parameters of the Pokemon, see PFM::Pokemon#generate_from_hash.
  # @return [PFM::Pokemon, nil] see #add_pokemon
  # @author Nuri Yuri
  def add_specific_pokemon(hash)
    pokemon_id = hash[:id].to_i
    raise "Database Error : The Pokémon ##{pokemon_id} doesn't exists." if pokemon_id < 1 || pokemon_id >= GameData::Pokemon.all.size
    return add_pokemon(PFM::Pokemon.generate_from_hash(hash))
  end
  alias ajouter_pokemon_param add_specific_pokemon

  # withdraw a Pokemon from the Party
  # @param id [Integer, Symbol] the id of the Pokemon you want to withdraw
  # @param counter [Integer] the number of Pokemon with this id to withdraw
  # @author Nuri Yuri
  def withdraw_pokemon(id, counter = 1)
    id = GameData::Pokemon.get_id(id) if id.is_a?(Symbol)
    $actors.delete_if do |pokemon|
      next false unless pokemon.id == id && counter > 0
      next(counter -= 1) # Any number are treaten as true
    end
  end
  alias retirer_pokemon withdraw_pokemon

  # withdraw a Pokemon from the party at a specific position in the Party
  # @param index [Integer] the position (0~5) in the party.
  def withdraw_pokemon_at(index)
    $actors.delete_at(index)
  end
  alias retirer_pokemon_index withdraw_pokemon_at

  # Learn a skill to a Pokemon
  # @param pokemon [PFM::Pokemon] the Pokemon that will learn the skill (use $actors[index] for a Pokemon in the party).
  # @param id_skill [Integer, Symbol] the id of the skill in the database
  # @author Nuri Yuri
  def skill_learn(pokemon, id_skill)
    raise "Database Error : Skill ##{id_skill} doesn't exists." unless GameData::Skill.id_valid?(id_skill)

    # Show the skill learn interface
    GamePlay::Skill_Learn.new(pokemon, GameData::Skill[id_skill].id).main
    Graphics.transition
    @wait_count = 2
  end
  alias enseigner_capacite skill_learn

  # Play the cry of a Pokemon
  # @param id [Integer, Symbol] the id of the Pokemon in the database
  def cry_pokemon(id)
    id = GameData::Pokemon.get_id(id) if id.is_a?(Symbol)
    raise "Database Error : The Pokémon ##{id} doesn't exists." unless GameData::Pokemon.id_valid?(id)
    Audio.se_play(format('Audio/SE/Cries/%03dCry', id))
  end

  # Show the rename interface of a Pokemon
  # @param index_or_pokemon [Integer, PFM::Pokemon] the Pokemon or the index of the Pokemon in the party (0~5)
  # @param num_char [Integer] the number of character the Pokemon can have in its name.
  # @author Nuri Yuri
  def rename_pokemon(index_or_pokemon, num_char = 12)
    if index_or_pokemon.is_a?(Integer)
      pokemon = $actors[index_or_pokemon]
      raise "IndexError : Pokemon at index #{index_or_pokemon} couldn't be found." unless pokemon
    else
      pokemon = index_or_pokemon
    end
    Graphics.freeze
    $scene.window_message_close(false) if $scene.class == Scene_Map
    pokemon.given_name = GamePlay::NameInput.new(pokemon.given_name, num_char, pokemon).main.return_name
    Graphics.transition
    @wait_count = 2
  end
  alias renommer_pokemon rename_pokemon

  # Add a pokemon to the party or store it in the PC and rename it
  # @param pokemon_or_id [Integer, Symbol, PFM::Pokemon] the ID of the pokemon in the database or a Pokemon
  # @param level [Integer] the level of the Pokemon (if ID given)
  # @param shiny [Boolean, Integer] true means the Pokemon will be shiny, 0 means it'll have no chance to be shiny, other number are the chance (1 / n) the pokemon can be shiny.
  # @param num_char [Integer] the number of character the Pokemon can have in its name.
  # @return [PFM::Pokemon, nil] if nil, the Pokemon couldn't be stored in the PC or added to the party. Otherwise it's the Pokemon that was added.
  # @author Nuri Yuri
  def add_rename_pokemon(pokemon_or_id, level = 5, shiny = false, num_char = 12)
    pokemon = add_pokemon(pokemon_or_id, level, shiny)
    rename_pokemon(pokemon, num_char) if pokemon
    return pokemon
  end
  alias ajouter_renommer_pokemon add_rename_pokemon

  # Add an egg to the Party (or in the PC)
  # @param id [Integer, Hash, Symbol] the id of the Pokemon in the database
  # @return [PFM::Pokemon, nil]
  # @author Nuri Yuri
  def add_egg(id)
    id = GameData::Pokemon.get_id(id) if id.is_a?(Symbol)
    return nil if id == 0
    pokemon_id = id.is_a?(Hash) ? id[:id].to_i : id
    raise "Database Error : The Pokémon ##{pokemon_id} doesn't exists." unless GameData::Pokemon.id_valid?(pokemon_id)
    pokemon = id.class == Hash ? PFM::Pokemon.generate_from_hash(id) : PFM::Pokemon.new(id, 1)
    pokemon.egg_init
    return add_pokemon(pokemon)
  end
  alias ajouter_oeuf add_egg

  # Start a wild battle
  # @author Nuri Yuri
  # @overload call_battle_wild(id, level, shiny, no_shiny)
  #   @param id [Integer, Symbol] id of the Pokemon in the database
  #   @param level [Integer] level of the Pokemon
  #   @param shiny [Boolean] if the Pokemon is shiny
  #   @param no_shiny [Boolean] if the Pokemon cannot be shiny
  # @overload call_battle_wild(id, level, *args)
  #   @param id [PFM::Pokemon, Symbol] First Pokemon in the wild battle.
  #   @param level [Object] ignored
  #   @param args [Array<PFM::Pokemon>] other pokemon in the wild battle.
  # @overload call_battle_wild(id, level, *args)
  #   @param id [Integer, Symbol] id of the Pokemon in the database
  #   @param level [Integer] level of the first Pokemon
  #   @param args [Array<Integer, Integer>] array of id, level of the other Pokemon in the wild battle.
  def call_battle_wild(id, level, *args)
    id = GameData::Pokemon.get_id(id) if id.is_a?(Symbol)
    # /!\ the following condition can trigger some bugs...
    if args[0].is_a?(Numeric) || args[0].is_a?(Symbol) || args[0].class == PFM::Pokemon or id.class == PFM::Pokemon
      args[0] = GameData::Pokemon.get_id(args[0]) if args[0].is_a?(Symbol)
      $wild_battle.start_battle(id, level, *args)
    else
      $wild_battle.start_battle(::PFM::Pokemon.new(id, level, args[0], args[1] == true))
    end
    @wait_count = 2
  end
  alias demarrer_combat call_battle_wild

  # Save the team somewhere and make it empty in the point of view of the player.
  # @param id_storage [String] the specific name of the storage, if nil sent to $storage.other_party
  # @author Nuri Yuri
  def empty_and_save_party(id_storage = nil)
    var_id = id_storage ? "@_str_#{id_storage}".to_sym : :@other_party
    $actors.compact!
    party = Marshal.load(Marshal.dump($actors))
    $actors.clear
    $storage.instance_variable_set(var_id, party)
  end

  # Retrieve the saved team when emptied ( /!\ empty the current team)
  # @param id_storage [String] the specific name of the storage, if nil sent to $storage.other_party
  # @author Nuri Yuri
  def retrieve_saved_party(id_storage = nil)
    var_id = id_storage ? "@_str_#{id_storage}".to_sym : :@other_party
    party = $storage.instance_variable_get(var_id)
    return nil if party.empty?
    $actors.each do |pokemon|
      $storage.store(pokemon)
    end
    $actors = $pokemon_party.actors = party
    $storage.remove_instance_variable(var_id) if id_storage
  end
  alias retreive_saved_party retrieve_saved_party

  # Save some Pokemon of the team somewhere and remove them from the party
  # @param id_storage [String] the specific name of the storage, if nil sent to $storage.other_party
  # @param indexes [Array, Range] list of index in the team
  # @param no_save [Boolean] if the Pokémon are not saved.
  # @author Nuri Yuri
  def steal_pokemon(indexes, id_storage = nil, no_save = false)
    pokemons = []
    indexes.each do |i|
      pokemons << $actors[i]
    end
    pokemons.compact!
    pokemons.each do |pokemon|
      $actors.delete(pokemon)
    end
    unless no_save
      var_id = id_storage ? "@_str_#{id_storage}".to_sym : :@other_party
      $storage.instance_variable_set(var_id, pokemons)
    end
  end

  # Retrieve previously stolen Pokemon ( /!\ uses #add_pokemon)
  # @param id_storage [String] the specific name of the storage, if nil sent to $storage.other_party
  # @author Nuri Yuri
  def retrieve_stolen_pokemon(id_storage = nil)
    var_id = id_storage ? "@_str_#{id_storage}".to_sym : :@other_party
    party = $storage.instance_variable_get(var_id)
    return nil if party.empty?
    party.each do |pokemon|
      add_pokemon(pokemon) if pokemon
    end
    $storage.remove_instance_variable(var_id) if id_storage
  end
  alias retreive_stolen_pokemon retrieve_stolen_pokemon

  # Start an online Trade
  # @param server [Boolean] if the player is the server
  def start_trade(server)
    GamePlay::Trade.new(server).main
    Graphics.transition
    @wait_count = 2
  end

  # Show the Pokemon dex info
  # @overload show_pokemon(pokemon)
  #   @param pokemon [PFM::Pokemon] the Pokemon to show in the dex
  # @overload show_pokemon(pokemon_id)
  #   @param pokemon_id [Integer, Symbol] ID of the Pokemon in the dex
  def show_pokemon(pokemon_id)
    pokemon_id = GameData::Pokemon.get_id(pokemon_id) if pokemon_id.is_a?(Symbol)
    GamePlay::Dex.new(pokemon_id).main
    Graphics.transition
    @wait_count = 2
  end
  # TODO : Faire le reste
end
