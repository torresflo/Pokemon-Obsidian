module GameData
  # Item that heals a certain amount of PP of all moves
  class AllPPHealItem < PPHealItem
  end
end

safe_code('Register AllPPHealItem ItemDescriptor') do
  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::AllPPHealItem) do |_, pokemon|
    next false if pokemon.egg?

    moves = $game_temp.in_battle ? PFM::PokemonBattler.from(pokemon).moveset : pokemon.skills_set
    next moves.any? { |move| move.pp < move.ppmax }
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::AllPPHealItem) do |item, pokemon, scene|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    pp_count = GameData::AllPPHealItem.from(item).pp_count

    pokemon.skills_set.each { |skill| skill.pp += pp_count }
    scene.display_message_and_wait(parse_text(22, 114, PFM::Text::PKNICK[0] => pokemon.given_name))
  end

  PFM::ItemDescriptor.define_on_pokemon_battler_use(GameData::AllPPHealItem) do |item, pokemon, scene|
    pokemon.loyalty -= GameData::HealingItem.from(item).loyalty_malus
    pp_count = GameData::AllPPHealItem.from(item).pp_count

    pokemon.moveset.each { |move| move.pp += pp_count }
    scene.display_message_and_wait(parse_text(22, 114, PFM::Text::PKNICK[0] => pokemon.given_name))
  end
end
