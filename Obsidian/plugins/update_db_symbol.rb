#encoding: utf-8

# Run by writing : Game --util=update_db_symbol
#  in cmd.bat

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
  new_symbol_str = text.tr('é♀♂', 'efm').downcase.gsub(/[^a-z0-9]/, '_').gsub(/__+/, '_').gsub(/_$/, '')
  new_symbol_str = "s#{new_symbol_str}" unless new_symbol_str.match?(/^[a-z][a-z0-9_]*[a-z0-9]$/)
  # old_symbol_str = text.downcase.gsub(' ', '_')
  # puts "#{old_symbol_str} => #{new_symbol_str}" if old_symbol_str != new_symbol_str
  return new_symbol_str.to_sym
end

def deduplicate_symbols(collection)
  original_collection = Marshal.load(Marshal.dump(collection)).each_with_index
  return collection.map.with_index do |e, index|
    v = e.db_symbol
    next e if v == :__undef__
    c = original_collection.count { |value, i| i <= index && value.db_symbol == v }
    e.db_symbol = :"#{v}#{c}" if c > 1
    next e
  end
end

#> Load all abilities symbol
GameData::Abilities.load
abilities_symbol = GameData::Abilities.psdk_id_to_gf_id.each_index.map do |psdk_id|
  text = GameData::Abilities.name(psdk_id)
  make_symbol(text)
end
save_data(abilities_symbol, 'Data/PSDK/Abilities_Symbols.rxdata')

#> Load all the item symbols
GameData::Item.load
(data = load_data('Data/PSDK/ItemData.rxdata')).each_with_index do |item, index|
  text = GameData::Item[index].name
  item.db_symbol = make_symbol(text)
  item.id = index
end
save_data(deduplicate_symbols(data), "Data/PSDK/ItemData.rxdata")

#> Load all the pokemon symbols
GameData::Pokemon.load
GameData::Pokemon.all.each_with_index do |pokemon, index|
  text = GameData::Pokemon[index].name
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
  text = GameData::Skill[index].name
  skill.db_symbol = make_symbol(text)
  skill.id = index
end
save_data(deduplicate_symbols(GameData::Skill.all), "Data/PSDK/SkillData.rxdata")

#> Load all the type symbols
GameData::Type.load
GameData::Type.all.each_with_index do |type, index|
  text = GameData::Type[index].name
  type.db_symbol = make_symbol(text)
  type.id = index
end
save_data(deduplicate_symbols(GameData::Type.all), "Data/PSDK/Types.rxdata")
