#encoding: utf-8

# Run by writing : Game --util=update_db_symbol
#  in cmd.bat

#> Prevent the game from launching
$GAME_LOOP = proc {}

#> Prevent GameData::Text from loading user language
$pokemon_party = nil

#> Change the default lang
module GameData
  module Text
    module_function
    def default_lang
      "en"
    end
    load
  end
end

NewText = "NewText"
Undef = "???"

UndefTexts = [NewText, Undef]

def make_symbol(text)
  if UndefTexts.include?(text)
    return :__undef__
  end
  text.downcase.gsub(' ', '_').to_sym
end

#> Load all abilities symbol
GameData::Abilities.load
abilities_symbol = GameData::Abilities.psdk_id_to_gf_id.each_index.collect do |psdk_id|
  text = GameData::Abilities.name(psdk_id)
  make_symbol(text)
end
save_data(abilities_symbol, 'Data/PSDK/Abilities_Symbols.rxdata')

#> Load all the item symbols
GameData::Item.load
GameData::Item.all.each_with_index do |item, index|
  text = GameData::Item.name(index)
  item.db_symbol = make_symbol(text)
  item.id = index
end
save_data(GameData::Item.all, "Data/PSDK/ItemData.rxdata")

#> Load all the pokemon symbols
GameData::Pokemon.load
GameData::Pokemon.all.each_with_index do |pokemon, index|
  text = GameData::Pokemon.name(index)
  sym = make_symbol(text)
  pokemon.each do |form|
    next unless form
    form.db_symbol = sym
    form.id = index
  end
end
save_data(GameData::Pokemon.all, "Data/PSDK/PokemonData.rxdata")

#> Load all the skill symbols
GameData::Skill.load
GameData::Skill.all.each_with_index do |skill, index|
  text = GameData::Skill.name(index)
  skill.db_symbol = make_symbol(text)
  skill.id = index
end
save_data(GameData::Skill.all, "Data/PSDK/SkillData.rxdata")

#> Load all the type symbols
GameData::Type.load
GameData::Type.all.each_with_index do |type, index|
  text = GameData::Type.name(index)
  type.db_symbol = make_symbol(text)
  type.id = index
end
save_data(GameData::Type.all, "Data/PSDK/Types.rxdata")