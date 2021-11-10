# This script allow to convert the project to a PSDK Editor Project
#
# To get access to this script write :
#   ScriptLoader.load_tool('PSDKEditor')
#
# To execute this script write :
#   PSDKEditor.convert
module PSDKEditor
  # Root folder of the PSDK Editor data
  ROOT = 'Data/PSDK-Editor'

  module_function

  # Convert the project to a PSDK Editor Project
  def convert
    create_paths
    convert_pokemon
    convert_items
    convert_types
    convert_moves
    convert_zones
    convert_worldmaps
    convert_trainers
    convert_quests
  end

  # Function that creates all the necessary path
  def create_paths
    Dir.mkdir(ROOT) unless Dir.exist?(ROOT)
    all_paths = %w[pokemon items types moves zones worldmaps trainers quests].map { |dirname| File.join(ROOT, dirname) }
    all_paths.each do |path|
      Dir.mkdir(path) unless Dir.exist?(path)
    end
  end

  # Function that convert Item data to PSDK Editor format
  def convert_items
    GameData::Item.all.each do |item|
      item_data = {
        klass: item.class.to_s.split(':').last, id: item.id, dbSymbol: item.db_symbol,
        icon: item.icon, price: item.price, socket: item.socket, position: item.position, isBattleUsable: item.battle_usable,
        isMapUsable: item.map_usable, isLimited: item.limited, isHoldable: item.holdable, flingPower: item.fling_power,
        **item.extra_psdk_editor_data
      }
      next if check_db_symbol(item)

      File.write(File.join(ROOT, 'items', "#{item.db_symbol}.json"), item_data.to_json)
    end
  end

  # Function that convert Type data to PSDK Editor format
  def convert_types
    GameData::Type.all.each_with_index do |type, index|
      type_data = {
        textId: type.text_id, klass: 'Type', id: type.id, dbSymbol: type.db_symbol,
        damageTo: GameData::Type.all.map do |def_type|
          def_type.on_hit_tbl[index] != 1 ? { defensiveType: def_type.id, factor: def_type.on_hit_tbl[index] } : nil
        end.compact
      }
      next if check_db_symbol(type)

      File.write(File.join(ROOT, 'types', "#{type.db_symbol}.json"), type_data.to_json)
    end
  end

  # Function that convert Move data to PSDK Editor format
  def convert_moves
    attack_category = %w[Physical Physical Special Status]
    GameData::Skill.all.each do |move|
      move_data = {
        id: move.id, dbSymbol: move.db_symbol, klass: 'Move', mapUse: move.map_use, battleEngineMethod: move.be_method, type: move.type,
        power: move.power, accuracy: move.accuracy, pp: move.pp_max, category: attack_category[move.atk_class], movecriticalRate: move.critical_rate,
        priority: move.priority - Battle::Logic::MOVE_PRIORITY_OFFSET, isDirect: move.direct, isCharge: move.charge, isBlocable: move.blocable,
        isSnatchable: move.snatchable, isMirrorMove: move.mirror_move, isPunch: move.punch, isGravity: move.gravity,
        isMagicCoatAffected: move.magic_coat_affected, isUnfreeze: move.unfreeze, isSoundAttack: move.sound_attack, isDistance: move.distance,
        isHeal: move.heal, isAuthentic: move.authentic, isBite: move.bite, isPulse: move.pulse, isBallistics: move.ballistics,
        isMental: move.mental, isNonSkyBattle: move.non_sky_battle, isDance: move.dance, isKingRockUtility: move.king_rock_utility,
        isEffectChance: move.effect_chance == 100, battleEngineAimedTarget: move.target,
        battleStageMod: move.battle_stage_mod.map.with_index do |value, index|
          value != 0 ? { battleStage: GameData::Stages::PSDK_EDITOR_VALUES[index], modificator: value } : nil
        end.compact
      }
      move_data.merge!(moveStatus: [{ status: GameData::States::PSDK_EDITOR_VALUES[move.status], luckRate: move.effect_chance }]) if move.status
      next if check_db_symbol(move)

      File.write(File.join(ROOT, 'moves', "#{move.db_symbol}.json"), move_data.to_json)
    end
  end

  # Function that convert the Zone data to PSDK Editor format
  def convert_zones
    GameData::Zone.all.each do |zone|
      zone_data = {
        id: zone.id, dbSymbol: zone.db_symbol, klass: 'Zone', maps: [zone.map_id].compact.flatten, worldmaps: [zone.worldmap_id].flatten,
        pannelId: zone.panel_id, warpX: zone.warp_x, warpY: zone.warp_y, positionX: zone.pos_x, positionY: zone.pos_y, isFlyAllowed: zone.fly_allowed,
        isWarpDisallowed: zone.warp_disallowed, forcedWeather: zone.forced_weather, subZones: [], wildGroups: create_wild_groups(zone)
      }
      File.write(File.join(ROOT, 'zones', "#{zone.id}.json"), zone_data.to_json)
    end
  end

  # Function that convert the WorldMap data to PSDK Editor format
  def convert_worldmaps
    GameData::WorldMap.all.each do |worldmap|
      grid = worldmap.data.ysize.times.map { |y| worldmap.data.xsize.times.map { |x| worldmap.data[x, y] } }
      if worldmap.name_file_id.is_a?(String)
        region_name = { csvFileId: 9, csvTextIndex: 0 }
      else
        region_name = { csvFileId: worldmap.name_file_id || 9, csvTextIndex: worldmap.name_id || 0 }
      end
      worldmap_data = {
        id: worldmap.id, dbSymbol: worldmap.db_symbol, klass: 'WorldMap',
        image: worldmap.image, grid: grid,
        regionName: region_name
      }
      File.write(File.join(ROOT, 'worldmaps', "#{worldmap.id}.json"), worldmap_data.to_json)
    end
  end

  # Function that convert the trainers
  def convert_trainers
    GameData::Trainer.all.each do |trainer|
      trainer_data = {
        klass: 'TrainerBattleSetup', id: trainer.id, dbSymbol: trainer.db_symbol,
        vsType: trainer.vs_type, isCouple: false, baseMoney: trainer.base_money,
        battlers: [trainer.battler], bags: [], battleId: 0, ai: 0,
        parties: [convert_trainer_party(trainer.team)]
      }
      File.write(File.join(ROOT, 'trainers', "#{trainer.id}.json"), trainer_data.to_json)
    end
  end

  # Function that convert Pokemon data to PSDK Editor format
  def convert_pokemon
    GameData::Pokemon.all.each do |entry|
      pokemon_array = Array.from(entry)
      # @type [Integer]
      id = pokemon_array.first.id
      db_symbol = pokemon_array.first.db_symbol
      specie_data = map_pokemon_array_to_forms(pokemon_array.compact)
      next if check_db_symbol(pokemon_array.first)

      filename = File.join(ROOT, 'pokemon', "#{db_symbol}.json")
      File.write(filename, { id: id, dbSymbol: db_symbol, forms: specie_data, klass: 'Specie' }.to_json)
    end
  end

  # Function that map a Pokemon Array to a form list
  # @param pokemon_array [Array<GameData::Pokemon>]
  # @return [Array<Hash>]
  def map_pokemon_array_to_forms(pokemon_array)
    return pokemon_array.map do |pokemon|
      next {
        form: pokemon.form, height: pokemon.height, weight: pokemon.weight, type1: pokemon.type1, type2: pokemon.type2, baseHp: pokemon.base_hp,
        baseAtk: pokemon.base_atk, baseDfe: pokemon.base_dfe, baseSpd: pokemon.base_spd, baseAts: pokemon.base_ats, baseDfs: pokemon.base_dfs,
        evHp: pokemon.ev_hp, evAtk: pokemon.ev_atk, evDfe: pokemon.ev_dfe, evSpd: pokemon.ev_spd, evAts: pokemon.ev_ats, evDfs: pokemon.ev_dfs,
        evolutionId: pokemon.evolution_id, evolutionLevel: pokemon.evolution_level, specialEvolutions: build_special_evolution(pokemon),
        experienceType: pokemon.exp_type, baseExperience: pokemon.base_exp, baseLoyalty: pokemon.base_loyalty, catchRate: pokemon.rareness,
        femaleRate: pokemon.female_rate, breedGroups: pokemon.breed_groupes, hatchSteps: pokemon.hatch_step, babyId: pokemon.baby,
        itemHeld: pokemon.items.each_slice(2).map { |(id, chance)| { dbSymbol: GameData::Item[id].db_symbol, chance: chance.to_i } },
        abilities: pokemon.abilities.map { |id| GameData::Abilities.db_symbol(id) }, frontOffsetY: pokemon.front_offset_y.to_i,
        moveSet: build_moveset(pokemon)
      }
    end
  end

  # Function that builds the moveset of a Pokemon
  # @param pokemon [GameData::Pokemon]
  # @return [Array<Hash>]
  def build_moveset(pokemon)
    # @type [Array]
    moveset = pokemon.move_set.each_slice(2).select { |(level, _)| level > 0 }
                     .map { |(level, id)| { klass: 'LevelLearnableMove', level: level, move: GameData::Skill[id].db_symbol } }
    moveset.concat(pokemon.master_moves.map { |id| { klass: 'TutorLearnableMove', move: GameData::Skill[id].db_symbol } })
    moveset.concat(pokemon.tech_set.map { |id| { klass: 'TechLearnableMove', move: GameData::Skill[id].db_symbol } })
    moveset.concat(pokemon.move_set.each_slice(2).select { |(level, _)| level <= 0 }
      .map { |(_, id)| { klass: 'EvolutionLearnableMove', move: GameData::Skill[id].db_symbol } })
    moveset.concat(pokemon.breed_moves.map { |id| { klass: 'BreedLearnableMove', move: GameData::Skill[id].db_symbol } })
    return moveset
  end

  # Function that build the special evolution of a Pokemon
  # @param pokemon [GameData::Pokemon]
  # @return [Array<Hash>]
  def build_special_evolution(pokemon)
    return nil unless pokemon.special_evolution

    special_evolutions = []
    pokemon.special_evolution.each do |special_evolution|
      data = {}
      data[:dbSymbol] = GameData::Pokemon[special_evolution[:id]].db_symbol if special_evolution[:id]
      data[:minLevel] = special_evolution[:min_level] if special_evolution[:min_level]
      data[:maxLevel] = special_evolution[:max_level] if special_evolution[:max_level]
      data[:tradeWith] = GameData::Pokemon[special_evolution[:trade_with]].db_symbol if special_evolution[:trade_with]
      data[:trade] = GameData::Pokemon[special_evolution[:trade]].db_symbol if special_evolution[:trade]
      data[:stone] = GameData::Item[special_evolution[:stone]].db_symbol if special_evolution[:stone]
      data[:itemHold] = GameData::Item[special_evolution[:item_hold]].db_symbol if special_evolution[:item_hold]
      data[:minLoyalty] = special_evolution[:min_loyalty] if special_evolution[:min_loyalty]
      data[:maxLoyalty] = special_evolution[:max_loyalty] if special_evolution[:max_loyalty]
      data[:skill1] = GameData::Skill[special_evolution[:skill_1]].db_symbol if special_evolution[:skill_1]
      data[:skill2] = GameData::Skill[special_evolution[:skill_2]].db_symbol if special_evolution[:skill_2]
      data[:skill3] = GameData::Skill[special_evolution[:skill_3]].db_symbol if special_evolution[:skill_3]
      data[:skill4] = GameData::Skill[special_evolution[:skill_4]].db_symbol if special_evolution[:skill_4]
      data[:weather] = special_evolution[:weather] if special_evolution[:weather]
      data[:env] = special_evolution[:env] if special_evolution[:env]
      data[:gender] = special_evolution[:gender] if special_evolution[:gender]
      data[:dayNight] = special_evolution[:day_night] if special_evolution[:day_night]
      data[:func] = special_evolution[:func] if special_evolution[:func]
      data[:maps] = special_evolution[:maps] if special_evolution[:maps]
      special_evolutions << data
    end
    return special_evolutions
  end

  GROUP_TOOLS = { 8 => 'OldRod', 9 => 'GoodRod', 10 => 'SuperRod', 11 => 'RockSmash', 12 => 'HeadButt' }
  GROUP_ZONE_SYSTEM_TAG = %w[RegularGround Grass TallGrass Cave Mountain Sand Pond UnderWater Snow Ice]
  # Function that creates the wild groups of a Zone
  # @param zone
  def create_wild_groups(zone)
    zone.groups&.map do |group|
      group_terrain_tag = group[1] >= 8 ? { tool: GROUP_TOOLS[group[1]], terrainTag: 0 } : { terrainTag: group[1] }
      sw = group.instance_variable_get(:@enable_switch)
      map_id = group.instance_variable_get(:@map_id) || 0
      custom_conditions = []
      custom_conditions << { enabledSwitch: sw, relationWithPreviousCondition: 'AND' } if sw
      custom_conditions << { mapId: map_id, relationWithPreviousCondition: 'AND' } if map_id != 0
      next {
        systemTag: GROUP_ZONE_SYSTEM_TAG[group.first],
        doubleBattle: group[3] == 2,
        hordeBattle: false,
        customCondition: custom_conditions,
        encounters: create_wild_encounters(group[2], group[4..-1].each_slice(3).to_a),
        **group_terrain_tag
      }
    end || []
  end

  # Function that create the wild encounter setup
  # @param delta [Integer]
  # @param encounters [Array<Array>]
  # @return [Array<Hash>]
  def create_wild_encounters(delta, encounters)
    minus = (-(delta - 1) / 2).clamp(-999, 0)
    plus = delta / 2
    return encounters.map do |(id, level, chance)|
      if level.is_a?(Hash)
        pkmn = level
        level = level[:level]
        setup = {
          specie: GameData::Pokemon[id].db_symbol, formIndex: pkmn[:form] || 0, shinySetup: { kind: 'automatic' },
          levelSetup: { kind: 'minmax', minimumLevel: level + minus, maximumLevel: level + plus, randomEncounterChance: chance }
        }
        expand_pokemon_setup(setup, pkmn)
        next setup
      else
        next {
          specie: GameData::Pokemon[id].db_symbol, formIndex: 0, shinySetup: { kind: 'automatic' },
          levelSetup: { kind: 'minmax', minimumLevel: level + minus, maximumLevel: level + plus, randomEncounterChance: chance }
        }
      end
    end
  end

  # Function that creates the Trainer party
  # @param party [Array<Hash>]
  # @return [Array<Hash>]
  def convert_trainer_party(party)
    return party.map do |pkmn|
      setup = {
        specie: GameData::Pokemon[pkmn[:id]].db_symbol, formIndex: pkmn[:form] || 0, shinySetup: { kind: 'automatic' },
        levelSetup: { kind: 'fixed', fixedLevel: pkmn[:level] }
      }
      expand_pokemon_setup(setup, pkmn)
      next setup
    end
  end

  # Function that expends the Pokemon setup with the extended data
  # @param setup [Hash] current Pokemon setup
  # @param pkmn [Hash] pokemon data to use to expand the setup
  def expand_pokemon_setup(setup, pkmn)
    setup[:shinySetup] = { kind: 'rate', rate: 1 } if pkmn[:shiny]
    setup[:shinySetup] = { kind: 'rate', rate: 0 } if pkmn[:no_shiny]
    setup[:givenName] = pkmn[:given_name] if pkmn[:given_name]
    setup[:caughtWith] = GameData::Item[pkmn[:captured_with]].db_symbol if pkmn[:captured_with]
    setup[:gender] = pkmn[:gender] if pkmn[:gender]
    setup[:nature] = pkmn[:nature] if pkmn[:nature]
    setup[:ivs] = %i[hp atk dfe spd ats dfs].map.with_index { |stat, i| [stat, pkmn[:stats][i]] }.to_h if pkmn[:stats]
    setup[:evs] = %i[hp atk dfe spd ats dfs].map.with_index { |stat, i| [stat, pkmn[:bonus][i]] }.to_h if pkmn[:bonus]
    setup[:itemHeld] = GameData::Item[pkmn[:item]].db_symbol if pkmn[:item]
    setup[:ability] = GameData::Abilities.db_symbol(pkmn[:ability]) if pkmn[:ability]
    setup[:rareness] = pkmn[:rareness] if pkmn[:rareness]
    setup[:loyalty] = pkmn[:loyalty] if pkmn[:loyalty]
    setup[:moves] = pkmn[:moves].map { |id| GameData::Skill[id].db_symbol } if pkmn[:moves]
    setup[:originalTrainerName] = pkmn[:trainer_name] if pkmn[:trainer_name]
    setup[:originalTrainerId] = pkmn[:trainer_id] if pkmn[:trainer_id]
  end

  # Function that converts the quests
  def convert_quests
    GameData::Quest.all.each do |quest|
      quest_data = {
        klass: 'Quest', id: quest.id, isPrimary: quest.primary,
        objectives: build_objectives(quest.objectives),
        earnings: build_earnings(quest.earnings)
      }
      File.write(File.join(ROOT, 'quests', "#{quest.id}.json"), quest_data.to_json)
    end
  end

  # Function that builds the objective of a quest
  # @param objectives [Array<GameData::Quest::Objective>] the objectives of the quest
  # @return [Array<Hash>]
  def build_objectives(objectives)
    return objectives.map do |objective|
      next {
        objectiveMethodName: objective.test_method_name,
        objectiveMethodArgs: build_objective_method_args(objective),
        textFormatMethodName: objective.text_format_method_name,
        hiddenByDefault: objective.hidden_by_default
      }
    end
  end

  # Function that build the objective method arguments
  # @param objective [GameData::Quest::Objective] an objectif of the quest
  # @return [Array]
  def build_objective_method_args(objective)
    method_name = objective.test_method_name
    if method_name == :objective_obtain_item
      item_id = objective.test_method_args[0]
      return [GameData::Item[item_id].db_symbol, objective.test_method_args[1]]
    end
    if method_name == :objective_see_pokemon
      pokemon_id = objective.test_method_args[0]
      return [GameData::Pokemon[pokemon_id].db_symbol]
    end
    if %i[objective_beat_pokemon objective_catch_pokemon].include?(method_name)
      pokemon_id = objective.test_method_args[0]
      return [GameData::Pokemon[pokemon_id].db_symbol, objective.test_method_args[1]]
    end
    return objective.test_method_args
  end

  # Function that builds the earning of a quest
  # @param earnings [Array<GameData::Quest::Earnings>] earnings of the quest
  # @return [Array<Hash>]
  def build_earnings(earnings)
    return earnings.map do |earning|
      next {
        earningMethodName: earning.give_method_name,
        earningArgs: build_earning_args(earning),
        textFormatMethodName: earning.text_format_method_name
      }
    end
  end

  # Function that build the earning method arguments
  # @param earning [GameData::Quest::Earnings] an earning of the quest
  # @return [Array]
  def build_earning_args(earning)
    method_name = earning.give_method_name
    if method_name == :earning_item
      item_id = earning.give_args[0]
      return [GameData::Item[item_id].db_symbol, earning.give_args[1]]
    end
    return earning.give_args
  end

  # Function that check the db_symbol
  # @param data [GameData::Base] a game data
  # @return [Boolean] true if db_symbol is null or equals to :none, :undef, :egg
  def check_db_symbol(data)
    return true unless data.db_symbol
    return %i[none __undef__ egg].include?(data.db_symbol)
  end
end

module GameData
  class Item
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return {}
    end
  end

  class BallItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(spriteFilename: img, catchRate: catch_rate, color: color.to_psdk_editor)
    end
  end

  class TechItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(move: GameData::Skill[move_learnt].db_symbol, isHm: is_hm)
    end
  end

  class RepelItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(repelCount: repel_count)
    end
  end

  class HealingItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(loyaltyMalus: loyalty_malus)
    end
  end

  class RateHealItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(hpRate: hp_rate)
    end
  end

  class StatusRateHealItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(statusList: status_list.map { |state| States::PSDK_EDITOR_VALUES[state] })
    end
  end

  class ConstantHealItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(hpCount: hp_count)
    end
  end

  class StatusConstantHealItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(statusList: status_list.map { |state| States::PSDK_EDITOR_VALUES[state] })
    end
  end

  class StatusHealItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(statusList: status_list.map { |state| States::PSDK_EDITOR_VALUES[state] })
    end
  end

  class EventItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(eventId: event_id)
    end
  end

  class PPHealItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(ppCount: pp_count)
    end
  end

  class PPIncreaseItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(isMax: max)
    end
  end

  class LevelIncreaseItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(levelCount: level_count)
    end
  end

  class StatBoostItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(stat: Stages::PSDK_EDITOR_VALUES[stat_index], count: count)
    end
  end

  class EVBoostItem
    # Convert extra data to PSDK Editor data
    # @return [Hash]
    def extra_psdk_editor_data
      return super.merge(stat: EV::PSDK_EDITOR_VALUES[stat_index], count: count)
    end
  end

  module States
    # Hash helping to convert state ID to their PSDK Editor counter part
    PSDK_EDITOR_VALUES = {
      POISONED => 'POISONED', PARALYZED => 'PARALYZED', BURN => 'BURN', ASLEEP => 'ASLEEP', FROZEN => 'FROZEN', CONFUSED => 'CONFUSED',
      TOXIC => 'TOXIC', DEATH => 'DEATH', FLINCH => 'FLINCH'
    }
  end

  module Stages
    # Hash helping to convert stage ID to its PSDK Editor counter part
    PSDK_EDITOR_VALUES = {
      ATK_STAGE => 'ATK_STAGE', ATS_STAGE => 'ATS_STAGE', DFE_STAGE => 'DFE_STAGE', DFS_STAGE => 'DFS_STAGE',
      SPD_STAGE => 'SPD_STAGE', EVA_STAGE => 'EVA_STAGE', ACC_STAGE => 'ACC_STAGE'
    }
  end

  module EV
    # Hash helping to convert EV stat ID to its PSDK Editor counter part
    PSDK_EDITOR_VALUES = {
      ATK => 'ATK', ATS => 'ATS', DFE => 'DFE', DFS => 'DFS', SPD => 'SPD', HP => 'HP'
    }
  end
end

class Color
  # Convert a color in the PSDK editor format
  # @return [Hash]
  def to_psdk_editor
    {
      red: red,
      green: green,
      blue: blue,
      alpha: alpha
    }
  end
end
