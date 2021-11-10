module GameData
  # Item that boost an EV stat of a Pokemon
  class EVBoostItem < StatBoostItem
  end
end

safe_code('Register EVBoostItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevention(GameData::EVBoostItem) do
    next $game_temp.in_battle
  end

  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::EVBoostItem) do |item, pokemon|
    next false if pokemon.egg?

    ev_boost = GameData::EVBoostItem.from(item)
    next pokemon.ev_check(ev_boost.stat_index, false, ev_boost.count)
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::EVBoostItem) do |item, pokemon, scene|
    boost_item = GameData::EVBoostItem.from(item)
    pokemon.loyalty -= boost_item.loyalty_malus
    pokemon.ev_check(boost_item.stat_index, true, boost_item.count)
    stat_name = text_get(22, PFM::ItemDescriptor::EVStat[boost_item.stat_index])
    message = parse_text(22, 118, PFM::Text::PKNICK[0] => pokemon.given_name, '[VAR EVSTAT(0001)]' => stat_name)
    scene.display_message_and_wait(message)
  end
end
