# If PSDK works in 4G mode or not
# @note Not implemented yet
GameData::Flag_4G = false

Graphics.on_start do
  # Load natures
  GameData::Natures.load

  # Load Types
  GameData::Type.load

  # Load association abilityID -> TextID
  GameData::Abilities.load

  # Load Moves
  GameData::Skill.load

  # Load Pokemon
  GameData::Pokemon.load

  # Load the items
  GameData::Item.load

  # Load Zone data
  GameData::Zone.load

  # Load Maplinks
  $game_data_maplinks = load_data('Data/PSDK/Maplinks.rxdata')

  # Load SystemTags
  $data_system_tags = load_data('Data/PSDK/SystemTags.rxdata')

  # Load Quests
  GameData::Quest.load

  # Load Trainers
  GameData::Trainer.load

  # Load World Maps (PSDK 24.28+)
  GameData::WorldMap.load
end
