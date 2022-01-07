module GameData
  # Item that heals a rate (0~100% using a number between 0 & 1) of hp
  class RateHealItem < HealingItem
    # Get the rate of hp this item can heal
    # @return [Float]
    attr_reader :hp_rate
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param hp_rate [Float] rate of hp this item can heal
    def initialize(*initialize_params, loyalty_malus, hp_rate)
      super(*initialize_params, loyalty_malus)
      @hp_rate = hp_rate.to_f.clamp(0, 1)
    end
  end
end

safe_code('Define RateHealItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::RateHealItem) do |_, pokemon|
    next false if pokemon.dead?

    next pokemon.hp < pokemon.max_hp
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::RateHealItem) do |item, pokemon, scene|
    original_hp = pokemon.hp
    pokemon.hp += (pokemon.max_hp * GameData::RateHealItem.from(item).hp_rate).to_i
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    diff = pokemon.hp - original_hp
    message = parse_text(22, 109, PFM::Text::PKNICK[0] => pokemon.given_name, PFM::Text::NUM3[1] => diff.to_s)
    scene.display_message_and_wait(message)
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::RateHealItem) do |item, pokemon, scene|
    battle_item = GameData::RateHealItem.from(item)
    pokemon.loyalty -= battle_item.loyalty_malus
    scene.logic.damage_handler.heal(pokemon, (pokemon.max_hp * battle_item.hp_rate).to_i, test_heal_block: false)
  end
end
