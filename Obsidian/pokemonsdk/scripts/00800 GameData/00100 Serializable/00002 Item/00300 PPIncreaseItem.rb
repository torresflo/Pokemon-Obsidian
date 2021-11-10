module GameData
  # Item that increase the PP of a move
  class PPIncreaseItem < HealingItem
    # Tell if this item sets the PP to the max possible amount
    # @return [Boolean]
    attr_reader :max
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param max [Boolean] if this item sets the PP to the max possible amount
    def initialize(*initialize_params, loyalty_malus, max)
      super(*initialize_params, loyalty_malus)
      @max = max
    end
  end
end

safe_code('Register PPIncreaseItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::PPIncreaseItem) do
    next $game_temp.in_battle
  end

  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::PPIncreaseItem) do |_, pokemon|
    next false if pokemon.egg?

    moves = $game_temp.in_battle ? PFM::PokemonBattler.from(pokemon).moveset : pokemon.skills_set
    next moves.any? { |move| (move.data.pp_max * 8 / 5) > move.ppmax }
  end

  PFM::ItemDescriptor.define_on_move_usability(GameData::PPIncreaseItem, 35) do |_, skill|
    next (skill.data.pp_max * 8 / 5) > skill.ppmax
  end

  PFM::ItemDescriptor.define_on_move_use(GameData::PPIncreaseItem) do |item, pokemon, skill, scene|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    if GameData::PPIncreaseItem.from(item).max
      skill.ppmax = skill.data.pp_max * 8 / 5
    else
      skill.ppmax += skill.data.pp_max * 1 / 5
    end
    skill.pp += 99
    scene.display_message_and_wait(parse_text(22, 117, PFM::Text::MOVE[0] => skill.name))
  end
end
