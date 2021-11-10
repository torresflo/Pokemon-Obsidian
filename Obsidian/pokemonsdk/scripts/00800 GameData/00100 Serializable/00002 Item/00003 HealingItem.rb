module GameData
  # All items that heals Pokemon
  class HealingItem < Item
    # Get the loyalty malus
    # @return [Integer]
    attr_reader :loyalty_malus
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    def initialize(*initialize_params, loyalty_malus)
      super(*initialize_params)
      @loyalty_malus = loyalty_malus.to_i
    end
  end
end

safe_code('Register HealingItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::HealingItem) do |item, pokemon|
    next false if pokemon.egg?

    next (pokemon.dup.loyalty -= GameData::HealingItem.from(item).loyalty_malus) != pokemon.loyalty
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::HealingItem) do |item, pokemon|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::HealingItem) do |item, pokemon|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
  end
end
