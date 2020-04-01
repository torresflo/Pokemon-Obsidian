# Convert PSDK Data to JSON
#
# To use it, write `ScriptLoader.load_tool('GameData/GameData2JSON/GameData2JSON')`
# in a script or the PSDK Console.
#
# Then, to convert a PSDK DATA to JSON, write :
#   - `GameData::Abilities.to_json('abilities.json')`
#   - `GameData::Item.to_json('items.json')`
#   - `GameData::Natures.to_json('natures.json')`
#   - `GameData::Pokemon.to_json('pokemon.json')`
#   - `GameData::Quest.to_json('quests.json')`
#   - `GameData::Skill.to_json('moves.json')`
#   - `GameData::Trainer.to_json('trainers.json')`
#   - `GameData::Type.to_json('types.json')`
#
# According to what you need to convert to JSON.
#
# Credit to Romnair for the JSON conversion!
def GameData2JSON(this, is_not, a_method)
  raise 'Don\'t call that'
end
ScriptLoader.load_tool('GameData/GameData2JSON/JSONFromDataCollection')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Abilities')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Item')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Natures')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Pokemon')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Quest')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Skill')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Trainer')
ScriptLoader.load_tool('GameData/GameData2JSON/z_JFDC__Types')
