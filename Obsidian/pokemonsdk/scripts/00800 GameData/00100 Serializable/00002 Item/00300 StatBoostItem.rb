module GameData
  # Item that boost a specific stat of a Pokemon in Battle
  class StatBoostItem < HealingItem
    # Get the index of the stat too boost (see: GameData::Stages)
    # @return [Integer]
    attr_reader :stat_index
    # Get the power of the stat to boost
    # @return [Integer]
    attr_reader :count
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param stat_index [Integer] index of the stat too boost (see: GameData::Stages)
    # @param count [Integer] power of the stat to boost
    def initialize(*initialize_params, loyalty_malus, stat_index, count)
      super(*initialize_params, loyalty_malus)
      @stat_index = stat_index.to_i
      @count = count.to_i
    end
  end
end

safe_code('Register StatBoostItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::StatBoostItem) do
    next !$game_temp.in_battle
  end

  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::StatBoostItem) do |item, pokemon|
    next false if pokemon.egg? || !PFM::PokemonBattler.from(pokemon).position

    next pokemon.battle_stage[GameData::StatBoostItem.from(item).stat_index] < 6
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::StatBoostItem) do |item, pokemon, scene|
    boost_item = GameData::StatBoostItem.from(item)
    pokemon.loyalty -= boost_item.loyalty_malus
    stat = Battle::Logic::StatChangeHandler::STAT_INDEX.key(boost_item.stat_index)

    scene.logic.stat_change_handler.stat_change(stat, boost_item.count, pokemon)
  end
end
