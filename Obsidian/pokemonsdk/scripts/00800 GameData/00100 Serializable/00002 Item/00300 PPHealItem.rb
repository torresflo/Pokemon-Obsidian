module GameData
  # Item that heals a certain amount of PP of a single move
  class PPHealItem < HealingItem
    # Get the number of PP of the move that gets healed
    # @return [Integer]
    attr_reader :pp_count
    # Create a new HealingItem
    # @param initialize_params [Array] params to create the Item object
    # @param loyalty_malus [Integer] power of the loyalty malus
    # @param pp_count [Integer] number of PP of the move that gets healed
    def initialize(*initialize_params, loyalty_malus, pp_count)
      super(*initialize_params, loyalty_malus)
      @pp_count = pp_count.to_i
    end
  end
end

safe_code('Register PPHealItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::PPHealItem) do |_, pokemon|
    next false if pokemon.egg?

    moves = $game_temp.in_battle ? PFM::PokemonBattler.from(pokemon).moveset : pokemon.skills_set
    next moves.any? { |move| move.pp < move.ppmax }
  end

  PFM::ItemDescriptor.define_on_move_usability(GameData::PPHealItem, 34) do |_, skill|
    next skill.pp < skill.ppmax
  end

  PFM::ItemDescriptor.define_on_move_use(GameData::PPHealItem) do |item, pokemon, skill, scene|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus

    skill.pp += GameData::PPHealItem.from(item).pp_count
    scene.display_message_and_wait(parse_text(22, 114, PFM::Text::MOVE[0] => skill.name))
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::PPHealItem) do |item, pokemon, skill, scene|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus

    skill.pp += GameData::PPHealItem.from(item).pp_count
    scene.display_message_and_wait(parse_text(22, 114, PFM::Text::MOVE[0] => skill.name))
  end
end
