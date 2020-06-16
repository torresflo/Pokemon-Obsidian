# A module that helps the PSDK_DEBUG to perform some commands
module Debugger
  module_function

  # Switch command format
  Switch_cmd = "$game_switches[%{name}] = %{value} %{opt}\r\n"
  # Command that list switch based on a part of its name
  # @param name [String, Regexp] the name of the switch
  # @param _system_mod [Module] the module that list the system switch id in constants
  # @param _container [Game_Switches, Game_Variables] the object that holds the switches values
  # @param _game_name [Array<String>] the object that holds the switches names
  # @param _command [String] the format of the PSDK_DEBUG switch command
  # @return [String] the output result
  # @author Nuri Yuri
  def find_switch(name,
      _system_mod = ::Yuki::Sw,
      _container = $game_switches,
      _game_name = $data_system.switches,
      _command = Switch_cmd
    )

    _container ||= Hash.new("undef")
    system_switch = _system_mod.constants.grep(name)
    game_switch = _game_name.grep(name)
    return_data = ''
    id_data = {}

    system_switch.each do |switch_constant|
      return_data << format(
        _command,
        name: "#{_system_mod}::#{switch_constant}",
        value: _container[_system_mod.const_get(switch_constant)],
        opt: nil
      )
    end

    game_switch.each do |switch_name|
      id = find_switch_id(switch_name, _game_name, id_data)
      return_data << format(
        _command,
        name: id,
        value: _container[id],
        opt: "# #{switch_name}"
      )
    end

    return_data
  end
  # Variable command format
  Var_cmd = "$game_variables[%{name}] = %{value} %{opt}\r\n"
  # Find variable based on a part of its name
  # @param name [String, Regexp] the name of the variable
  # @return [String] the output result
  def find_var(name)
    find_switch(name, ::Yuki::Var, $game_variables, $data_system.variables, Var_cmd)
  end

  # Find the ID of a switch
  # @param name [String] the name of the switch
  # @param _game_name [Array<String>] list of the switch name
  # @param id_data [Hash{String => Integer}] an id cache
  # @return [Integer] the index
  # @author Nuri Yuri
  def find_switch_id(name, _game_name, id_data)
    base_index = id_data.fetch(name, -1)
    index = 0
    _game_name.map.with_index do |sw_name, i|
      next if i <= base_index
      break(index = i) if sw_name == name
    end
    id_data[name] = index if base_index < index
    return index
  end

  # The id => name format string
  ID_NAME_FORMAT = "%d : %s\r\n"
  # The no result message
  NoResult = "Aucun résultat\r\n"
  # Find a Pokemon based on a part of its name
  # @param name [String, Regexp] the name of the Pokemon
  # @param text_id [Integer] the file id of the text that contain the Names of the Pokemon
  # @param table [Array] a table that contain every defined Pokemon
  # @return [String] the output data
  # @author Nuri Yuri
  def find_pokemon(name, text_id = 0, table = GameData::Pokemon.all)
    return_data = ''
    text = GameData::Text
    pokemon_name = nil
    table.each_index do |i|
      pokemon_name = text.get(text_id, i)
      if pokemon_name =~ name
        return_data << format(ID_NAME_FORMAT, i, pokemon_name)
      end
    end
    return_data << NoResult if return_data.bytesize == 2
    return_data
  end

  # Find a pokemon nature based on a part of the nature name
  # @param name [String, Regexp] the name
  # @return [String] the output data
  def find_nature(name)
    find_pokemon(name, 8, GameData::Natures.all)
  end

  # Find an ability based on a part of its name
  # @param name [String, Regexp] the name
  # @return [String] the output data
  def find_ability(name)
    find_pokemon(name, 4, GameData::Abilities.psdk_id_to_gf_id)
  end

  # Find a skill based on a part of its name
  # @param name [String, Regexp] the name
  # @return [String] the output data
  def find_skill(name)
    find_pokemon(name, 6, GameData::Skill.all)
  end

  # Find an item based on a part of its name
  # @param name [String, Regexp] the name
  # @return [String] the output data
  def find_item(name)
    find_pokemon(name, 12, GameData::Item.all)
  end

  # Find a type based on a part of its name
  # @param name [String, Regexp] the name
  # @return [String] the output data
  # @author Nuri Yuri
  def find_type(name)
    return_data = ''
    pokemon_name = nil
    GameData::Type.all.each_with_index do |type, i|
      type_name = type.name
      if type_name.match?(name)
        return_data << format(ID_NAME_FORMAT, i, type_name)
      end
    end
    return_data << NoResult if return_data.bytesize == 2
    return_data
  end

  # Warp Error message
  WarpError = 'Aucune map de cet ID'
  # Name of the map to load to prevent warp error
  WarpMapName = 'Data/Map%03d.rxdata'
  # Warp command
  # @param id [Integer] ID of the map to warp
  # @param x [Integer] X position
  # @param y [Integer] Y position
  # @author Nuri Yuri
  def warp(id, x = -1, y = -1)
    map = load_data(format(WarpMapName, id)) rescue nil
    return WarpError unless map
    if y < 0
      unless __find_maker_warp(id)
        __find_map_warp(map)
      end
    else
      $game_temp.player_new_x = x + ::Yuki::MapLinker.get_OffsetX
      $game_temp.player_new_y = y + ::Yuki::MapLinker.get_OffsetY
    end
    $game_temp.player_new_direction = 0
    $game_temp.player_new_map_id = id
    $game_temp.player_transferring = true
  end

  # Fight a specific trainer by its ID
  # @param id [Integer] ID of the trainer in Ruby Host
  # @param bgm [Array(String, Integer, Integer)] bgm description of the trainer battle
  # @param troop_id [Integer] ID of the RMXP Troop to use
  def battle_trainer(id, bgm = Interpreter::DEFAULT_TRAINER_BGM, troop_id = 3)
    original_battle_bgm = $game_system.battle_bgm
    $game_system.battle_bgm = RPG::AudioFile.new(*bgm)
    $game_variables[Yuki::Var::Trainer_Battle_ID] = id
    $game_temp.battle_abort = true
    $game_temp.battle_calling = true
    $game_temp.battle_troop_id = troop_id
    $game_temp.battle_can_escape = false
    $game_temp.battle_can_lose = false
    $game_temp.battle_proc = proc do |n|
      $game_system.battle_bgm = original_battle_bgm
    end
  end

  # Find the normal position where the player should warp in a specific map
  # @param id [Integer] id of the map
  # @return [Boolean] if a normal position has been found
  # @author Nuri Yuri
  def __find_maker_warp(id)
    GameData::Zone.all.each do |data|
      if data.map_included?(id)
        if data.warp_x && data.warp_y
          $game_temp.player_new_x = data.warp_x + ::Yuki::MapLinker.get_OffsetX
          $game_temp.player_new_y = data.warp_y + ::Yuki::MapLinker.get_OffsetY
          return true
        end
        break
      end
    end
    return false
  end

  # Find an alternative position where to warp
  # @param map [RPG::Map] the map data
  # @author Nuri Yuri
  def __find_map_warp(map)
    warp_x = cx = map.width / 2
    warp_y = cy = map.height / 2
    lowest_radius = ((cx * cy) * 2) ** 2
    map.events.each_value do |event|
      radius = (cx - event.x) ** 2 + (cy - event.y) ** 2
      if(radius < lowest_radius)
        if(__warp_command_found(event.pages))
          warp_x = event.x
          warp_y = event.y
          lowest_radius = radius
        end
      end
    end
    $game_temp.player_new_x = warp_x + ::Yuki::MapLinker.get_OffsetX
    $game_temp.player_new_y = warp_y + ::Yuki::MapLinker.get_OffsetY
  end

  # Detect a teleport command in the pages of an event
  # @param pages [Array<RPG::Event::Page>] the list of event page
  # @return [Boolean] if a command has been found
  # @author Nuri Yuri
  def __warp_command_found(pages)
    pages.each do |page|
      page.list.each do |command|
        return true if command.code == 201
      end
    end
    false
  end
end
