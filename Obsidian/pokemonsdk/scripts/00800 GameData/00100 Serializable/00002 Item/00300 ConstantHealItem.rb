module GameData
  # Item that heals a constant amount of hp
  class ConstantHealItem < HealingItem
    # Get the number of hp the item heals
    # @return [Integer]
    attr_reader :hp_count
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param hp_count [Integer] number of hp it heals
    def initialize(*initialize_params, loyalty_malus, hp_count)
      super(*initialize_params, loyalty_malus)
      @hp_count = hp_count.to_i
    end
  end
end

safe_code('Define ConstantHealItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::ConstantHealItem) do |_, pokemon|
    next false if pokemon.dead?

    next pokemon.hp < pokemon.max_hp
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::ConstantHealItem) do |item, pokemon, scene|
    original_hp = pokemon.hp
    pokemon.hp += GameData::ConstantHealItem.from(item).hp_count
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    diff = pokemon.hp - original_hp
    message = parse_text(22, 109, PFM::Text::PKNICK[0] => pokemon.given_name, PFM::Text::NUM3[1] => diff.to_s)
    scene.display_message_and_wait(message)
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::ConstantHealItem) do |item, pokemon, scene|
    battle_item = GameData::ConstantHealItem.from(item)
    pokemon.loyalty -= battle_item.loyalty_malus
    scene.logic.damage_handler.heal(pokemon, battle_item.hp_count, test_heal_block: false)
  end
end
