#encoding: utf-8
Encoding.default_external="UTF-8"
Encoding.default_internal="UTF-8"
#===
#>Chargement des scripts principaux
#===
require_relative "App.rb"
=begin
require_relative "MainDialog.rb"
require_relative "PokemonDialog.rb"
require_relative "TypeDialog.rb"
require_relative "AtkDialog.rb"
require_relative "TextDialog.rb"
require_relative "PkAtkDialog.rb"
require_relative "ZoneEditor.rb"
require_relative "Debug.rb"
require_relative "ObjDialog.rb"
require_relative "PokemonPlusDialog.rb"
require_relative "TeamEdit.rb"
require_relative "GroupEdit.rb"
=end
require_relative "DialogHost.rb"
require_relative "DialogHost.defines.rb"
require_relative "DialogHost.updates.rb"
require_relative "DialogHost.utils.rb"
require_relative "Item_Dialog.rb"
require_relative "ItemHeal_Dialog.rb"
require_relative "ItemBall_Dialog.rb"
require_relative "ItemMisc_Dialog.rb"
require_relative "Text_Dialog.rb"
require_relative "Pokemon_Dialog.rb"
require_relative "Pokemon_Skill_Dialog.rb"
require_relative "Pokemon_Plus_Dialog.rb"
require_relative "Groupe_Dialog.rb"
require_relative "Type_Dialog.rb"
require_relative "Zone_Dialog.rb"
require_relative "Skill_Dialog.rb"
require_relative "MapLinks_Dialog.rb"
require_relative "Quest_Dialog.rb"
require_relative "Trainer_Dialog.rb"
require_relative "Main_Dialog.rb"
#require_relative "H_Parser.rb"
#===
#>Chargement des structures de data
#===
sleep(0.1)
=begin
require_relative "GameData/Item.rb"
require_relative "GameData/ItemHeal.rb"
require_relative "GameData/BallData.rb"
require_relative "GameData/ItemMisc.rb"
require_relative "GameData/Pokemon.rb"
require_relative "GameData/Skill.rb"
require_relative "GameData/Map.rb"
require_relative "GameData/Text.rb"
require_relative "GameData/Type.rb"
require_relative "RGSS/Color.rb"
=end
require_relative "GameData.rb"
sleep(0.1)
require_relative "../Plugin/socket.so"

Main_Dialog.instanciate