module GameData
  # Item that increase the level of the Pokemon
  class LevelIncreaseItem < HealingItem
    # Get the number of level this item increase
    # @return [Integer]
    attr_reader :level_count
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param level_count [Integer] number of level this item increase
    def initialize(*initialize_params, loyalty_malus, level_count)
      super(*initialize_params, loyalty_malus)
      @level_count = level_count.to_i
    end
  end
end

safe_code('Register LevelIncreaseItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::LevelIncreaseItem) do
    next $game_temp.in_battle
  end

  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::LevelIncreaseItem) do |item, pokemon|
    next false if pokemon.egg?

    next (pokemon.level + GameData::LevelIncreaseItem.from(item).level_count) <= pokemon.max_level
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::LevelIncreaseItem) do |item, pokemon, scene|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    GameData::LevelIncreaseItem.from(item).level_count.times do
      next unless pokemon.level_up

      list = pokemon.level_up_stat_refresh
      Audio.me_play(PFM::ItemDescriptor::LVL_SOUND)
      message = parse_text(22, 128, PFM::Text::PKNICK[0] => pokemon.given_name, PFM::Text::NUM3[1] => pokemon.level.to_s)
      scene.display_message_and_wait(message)
      pokemon.level_up_window_call(list[0], list[1], 40_005)
      scene.message_window.update while scene.message_window && $game_temp.message_window_showing
      # Learn move
      pokemon.check_skill_and_learn
      # Evolve
      id, form = pokemon.evolve_check(:level_up)
      GamePlay.make_pokemon_evolve(pokemon, id, form, false) if id
    end
  end
end
