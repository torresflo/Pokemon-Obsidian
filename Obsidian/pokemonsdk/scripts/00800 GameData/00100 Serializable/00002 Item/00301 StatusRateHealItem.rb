module GameData
  # Item that heals a rate amount of hp and heals status as well
  class StatusRateHealItem < RateHealItem
    # Get the list of states the item heals
    # @return [Array<Integer>]
    attr_accessor :status_list
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param hp_rate [Float] rate of hp this item can heal
    # @param status_list [Array<Integer>]
    def initialize(*initialize_params, loyalty_malus, hp_rate, status_list)
      super(*initialize_params, loyalty_malus, hp_rate)
      @status_list = status_list
    end
  end
end

safe_code('Define StatusRateHealItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::StatusRateHealItem) do |item, pokemon|
    next false if pokemon.egg?

    states = GameData::StatusRateHealItem.from(item).status_list
    include_death = states.include?(GameData::States::DEATH)
    next false if pokemon.dead? && !include_death
    next false if pokemon.alive? && include_death && states.size == 1

    confuse_check = $game_temp.in_battle && pokemon.confused? && states.include?(GameData::States::CONFUSED)
    next pokemon.hp < pokemon.max_hp || confuse_check || states.include?(pokemon.status)
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::StatusRateHealItem) do |item, pokemon, scene|
    original_hp = pokemon.hp
    pokemon.hp += (pokemon.max_hp * GameData::StatusRateHealItem.from(item).hp_rate).to_i
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    diff = pokemon.hp - original_hp
    if diff > 0
      message = parse_text(22, 109, PFM::Text::PKNICK[0] => pokemon.given_name, PFM::Text::NUM3[1] => diff.to_s)
      scene.display_message_and_wait(message)
    end
    status = pokemon.status
    if status != 0
      pokemon.status = 0
      message = parse_text(22, PFM::ItemDescriptor::BagStatesHeal[status], PFM::Text::PKNICK[0] => pokemon.given_name)
      scene.display_message_and_wait(message)
    end
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::StatusRateHealItem) do |item, pokemon, scene|
    battle_item = GameData::StatusRateHealItem.from(item)
    pokemon.loyalty -= battle_item.loyalty_malus
    was_dead = pokemon.dead?
    scene.logic.damage_handler.heal(pokemon, (pokemon.max_hp * battle_item.hp_rate).to_i, test_heal_block: false)
    if was_dead && pokemon.position >= 0 && pokemon.position < scene.battle_info.vs_type
      scene.visual.battler_sprite(pokemon.bank, pokemon.position).go_in
      scene.visual.show_info_bar(pokemon)
    end
    states = battle_item.status_list
    scene.logic.status_change_handler.status_change(:cure, pokemon) if states.include?(pokemon.status)
    if states.include?(GameData::States::CONFUSED) && pokemon.confused?
      scene.logic.status_change_handler.status_change(:confuse_cure, pokemon, message_overwrite: 351)
    end
  end
end
