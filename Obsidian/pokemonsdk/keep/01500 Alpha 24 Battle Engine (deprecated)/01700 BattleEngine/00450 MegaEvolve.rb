module BattleEngine
  # List of tools that allow MEGA Evolution
  MEGA_EVOLVE_TOOLS = %i[mega_ring mega_bracelet mega_pendant mega_glasses mega_anchor mega_stickpin mega_tiara mega_anklet
                         mega_cuff]
  # List of trainer id that used "MEGA Evolution" (to prevent two mega in the same battle)
  @mega_evolved_trainer_ids = []
  # List of Pokemon&bag that should mega evolve
  @prepared_mega_evolve = []

  module_function

  # Reset the mega_evolved_trainer_ids
  def reset_mega_evolutions
    @mega_evolved_trainer_ids.clear
    @prepared_mega_evolve.clear
  end

  # Test if a Pokemon can Mega Evolve
  # @param pokemon [PFM::Pokemon] Pokemon that should mega evolve
  # @param bag [PFM::Bag] Bag that should contain the Mega Evolve tool
  # @return [Boolean]
  def can_pokemon_mega_evolve?(pokemon, bag)
    return false unless MEGA_EVOLVE_TOOLS.any? { |item_db_symbol| bag.contain_item?(item_db_symbol) }

    return !@mega_evolved_trainer_ids.include?(pokemon.trainer_id) && pokemon.can_mega_evolve?
  end

  # Add the Pokemon to the prepared mega evolve stack
  # @param pokemon [PFM::Pokemon] Pokemon that should mega evolve
  # @param bag [PFM::Bag] Bag that should contain the Mega Evolve tool
  def prepare_mega_evolve(pokemon, bag)
    @mega_evolved_trainer_ids << pokemon.trainer_id
    @prepared_mega_evolve << [pokemon, bag]
  end

  # Remove the Pokemon from the prepared mega evolve stack
  # @param pokemon [PFM::Pokemon] Pokemon that should mega evolve
  def unprepare_mega_evolve(pokemon)
    @mega_evolved_trainer_ids.delete(pokemon.trainer_id)
    @prepared_mega_evolve.delete_if { |cell| cell.first == pokemon }
  end

  # Clear the prepared mega evolve stack
  def clear_prepared_mega_evolve
    @prepared_mega_evolve.each { |cell| @mega_evolved_trainer_ids.delete(cell.first.trainer_id) }
    @prepared_mega_evolve.clear
  end

  # Iterate through the prepared mega evolve and clear the stack
  def each_prepared_mega_evolve
    @prepared_mega_evolve.each { |cells| yield(*cells) }
    @prepared_mega_evolve.clear
  end

  # Give the name of the mega tool used by the trainer
  # @param bag [PFM::Bag]
  # @return [String]
  def mega_tool_name(bag)
    symbol = MEGA_EVOLVE_TOOLS.find { |item_db_symbol| bag.contain_item?(item_db_symbol) }
    return GameData::Item[symbol || 0].name
  end
end
