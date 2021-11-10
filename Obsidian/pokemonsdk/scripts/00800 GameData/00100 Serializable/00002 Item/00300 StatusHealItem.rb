module GameData
  # Item that heals status
  class StatusHealItem < HealingItem
    # Get the list of states the item heals
    # @return [Array<Integer>]
    attr_accessor :status_list
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param status_list [Array<Integer>]
    def initialize(*initialize_params, loyalty_malus, status_list)
      super(*initialize_params, loyalty_malus)
      @status_list = status_list
    end
  end
end

safe_code('Register StatusHealItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::StatusHealItem) do |item, pokemon|
    next false if pokemon.egg?

    states = GameData::StatusHealItem.from(item).status_list
    confuse_check = $game_temp.in_battle && pokemon.confused? && states.include?(GameData::States::CONFUSED)
    next confuse_check || states.include?(pokemon.status)
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::StatusHealItem) do |item, pokemon, scene|
    pokemon.loyalty -= GameData::StatusHealItem.from(item).loyalty_malus
    status = pokemon.status
    pokemon.status = 0
    message = parse_text(22, PFM::ItemDescriptor::BagStatesHeal[status], PFM::Text::PKNICK[0] => pokemon.given_name)
    scene.display_message_and_wait(message)
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::StatusHealItem) do |item, pokemon, scene|
    states = GameData::StatusHealItem.from(item).status_list
    pokemon.loyalty -= GameData::StatusHealItem.from(item).loyalty_malus
    scene.logic.status_change_handler.status_change(:cure, pokemon) if states.include?(pokemon.status)
    if states.include?(GameData::States::CONFUSED) && pokemon.confused?
      scene.logic.status_change_handler.status_change(:confuse_cure, pokemon, message_overwrite: 351)
    end
  end
end
