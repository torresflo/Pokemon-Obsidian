#encoding: utf-8
class Groupe_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  TYPE_FORMAT = '%d - %s'
  Zones = ["Grass (0)","Tall Grass (1)","Very Tall Grass (2)","Cave (3)","Mountain (4)","Sand (5)","Pond (6)","Ocean (7)","Underwater (8)","Snow (9)","Ice (10)"]
  Tags = ["0","1","2","3","4","5","6","7","OldRod","GoodRod","SuperRod","RockSmash","Headbutt"]
  Genders = ["Random", "Undetermined (0)","Male (1)","Female (2)"]
  NewGroup = "New Group"
  RandomForm = "Random Form"
  RandomAbility = "Random Ability"
  DefaultAttack = "Default (0)"
  DATA_FILE = "Data/PSDK/MapData.rxdata"
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    #> Définition des contrôls principaux
    define_combo_controler(1, :_on_pokemon_change, :_pokemon_list)
    define_combo_controler(13, :_on_zone_change, :_zone_list)
    define_list_controler(1, :_on_group_change, :_group_list)
    define_list_controler(2, :_on_pokemon_group_change, :_pokemon_group_list)
    #> Définition des infos du groupe
    define_combo(11, Zones, :_get_systemtag, :_set_systemtag)
    define_combo(12, Tags, :_get_tag, :_set_tag)
    define_unsigned_int(14, {getter: :_get_switch, setter: :_set_switch}, 0, 99_999)
    define_unsigned_int(15, {getter: :_get_mapid, setter: :_set_mapid}, 0, 99_999)
    define_unsigned_int(21, {getter: :_get_ecart, setter: :_set_ecart}, 0, 99_999)
    define_checkbox(3, {getter: :_get_is_2v2, setter: :_set_is_2v2})
    #> Définition des propriétés des Pokémon
    define_combo_controler(3, :_set_form, :_form_list)
    define_combo(5, Genders, :_get_gender, :_set_gender)
    define_combo(6, :_get_ability_list, :_get_ability, :_set_ability)
    define_combo(7, :_get_attack_list, :_get_attack1, :_set_attack1)
    define_combo(8, :_get_attack_list, :_get_attack2, :_set_attack2)
    define_combo(9, :_get_attack_list, :_get_attack3, :_set_attack3)
    define_combo(10, :_get_attack_list, :_get_attack4, :_set_attack4)
    
    define_text_control(2, {getter: :_get_nickname, setter: :_set_nickname}, 64)
    define_unsigned_int(6, {getter: :_get_level, setter: :_set_level}, 1, 99_999)
    define_unsigned_int(7, {getter: :_get_loyalty, setter: :_set_loyalty}, 0, 255)
    define_unsigned_int(20, {getter: :_get_rate, setter: :_set_rate}, 1, 100)
    define_unsigned_int(8, {getter: :_get_bonus0, setter: :_set_bonus0}, 0, 252)
    define_unsigned_int(9, {getter: :_get_bonus1, setter: :_set_bonus1}, 0, 252)
    define_unsigned_int(10, {getter: :_get_bonus2, setter: :_set_bonus2}, 0, 252)
    define_unsigned_int(11, {getter: :_get_bonus3, setter: :_set_bonus3}, 0, 252)
    define_unsigned_int(12, {getter: :_get_bonus4, setter: :_set_bonus4}, 0, 252)
    define_unsigned_int(13, {getter: :_get_bonus5, setter: :_set_bonus5}, 0, 252)
    define_checkbox(1, {getter: :_get_shiny, setter: :_set_shiny})
    #> Définition des actions
    define_button(1, :_add)
    define_button(2, :_save)
    define_button(5, :_remove)
    define_button(6, :_remove_group)
    super
  end
  
  public
  #> Suppression d'un groupe
  def _remove_group
    index = @group_data.index(@current_group)
    return unless index
    @group_data.delete(@current_group)
    if(@group_data.size == 0)
      index = 0
    elsif(index >= @group_data.size)
      index = @group_data.size - 1
    end
    update_list(1, index)
    _on_group_change(index, _group_list[index])
    return :update_dialog
  end
  #> Ajout d'un Pokémon au groupe
  def _add
    check_update_data
    _add_pokemon
    index = (@current_group.size - 4 ) / 3 - 1
    update_list(2, index)
    __change_pokemon(index)
    return :update_dialog
  end
  #> Suppression d'un Pokémon au groupe
  def _remove
    size = (@current_group.size - 4 ) / 3
    if(size <= 1)
      return msgbox("Les groupes doivent au moins contenir un Pokémon...", self.class.to_s)
    end
    4.upto(6) { |i| @current_group[@pokemon_index * 3 + i] = nil }
    @current_group.compact!
    if(@current_group[@pokemon_index * 3 + 4])
      index = @pokemon_index
    else
      index = @pokemon_index - 1
    end
    update_list(2, index)
    __change_pokemon(index)
    return :update_dialog
  end
  #> Sauvegarde
  def _save
    check_update_data
    App.save_data([$game_data_map, $game_data_zone], get_file_name(DATA_FILE))
  end
  
  def _get_nickname
    unless @pokemon_data[:given_name]
      return GameData::Text._get(@lang_id, 0, @pokemon_data[:id])
    end
    @pokemon_data[:given_name]
  end
  
  def _set_nickname(value)
    if value == GameData::Text._get(@lang_id, 0, @pokemon_data[:id])
      return @pokemon_data[:given_name] = nil
    end
    @pokemon_data[:given_name] = value
  end
  
  def _get_bonus0
    @pokemon_data[:bonus][0].to_i
  end
  
  def _set_bonus0(value)
    @pokemon_data[:bonus][0] = value
  end
  
  def _get_bonus1
    @pokemon_data[:bonus][1].to_i
  end
  
  def _set_bonus1(value)
    @pokemon_data[:bonus][1] = value
  end
  
  def _get_bonus2
    @pokemon_data[:bonus][2].to_i
  end
  
  def _set_bonus2(value)
    @pokemon_data[:bonus][2] = value
  end
  
  def _get_bonus3
    @pokemon_data[:bonus][3].to_i
  end
  
  def _set_bonus3(value)
    @pokemon_data[:bonus][3] = value
  end
  
  def _get_bonus4
    @pokemon_data[:bonus][4].to_i
  end
  
  def _set_bonus4(value)
    @pokemon_data[:bonus][4] = value
  end
  
  def _get_bonus5
    @pokemon_data[:bonus][5].to_i
  end
  
  def _set_bonus5(value)
    @pokemon_data[:bonus][5] = value
  end
  
  def _get_attack1
    @pokemon_data[:moves][0].to_i
  end
  
  def _set_attack1(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_skill.size)
    @pokemon_data[:moves][0] = id
  end
  
  def _get_attack2
    @pokemon_data[:moves][1].to_i
  end
  
  def _set_attack2(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_skill.size)
    @pokemon_data[:moves][1] = id
  end
  
  def _get_attack3
    @pokemon_data[:moves][2].to_i
  end
  
  def _set_attack3(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_skill.size)
    @pokemon_data[:moves][2] = id
  end
  
  def _get_attack4
    @pokemon_data[:moves][3].to_i
  end
  
  def _set_attack4(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_skill.size)
    @pokemon_data[:moves][3] = id
  end
  
  def _get_ability
    return @__last_ability unless @pokemon_data[:ability]
    @pokemon_data[:ability]
  end
  
  def _set_ability(index, text)
    if text == RandomAbility
      @pokemon_data[:ability] = nil
    else
      id = text.split(TEXT_SPLIT).last.to_i
      id = 0 if(id < 0 or id >= $game_data_abilities.size)
      @pokemon_data[:ability] = id
    end
  end
  
  def _get_gender
    return 0 unless @pokemon_data[:gender]
    @pokemon_data[:gender] + 1
  end
  
  def _set_gender(index, text)
    if text == Genders[0]
      @pokemon_data[:gender] = nil
    else
      @pokemon_data[:gender] = index - 1
    end
  end
  
  def _get_form
    return @__last_form unless @pokemon_data[:form]
    @pokemon_data[:form]
  end
  
  def _set_form(index, text)
    if text == RandomForm
      @pokemon_data[:form] = nil
    else
      form = text.to_i
      form = 0 unless $game_data_pokemon[@pokemon_data[:id]][form]
      @pokemon_data[:form] = form
    end
  end
  
  def _get_shiny
    @pokemon_data[:shiny] == true
  end
  
  def _set_shiny(value)
    @pokemon_data[:shiny] = value
  end
  
  def _get_loyalty
    @pokemon_data[:loyalty].to_i
  end
  
  def _set_loyalty(value)
    @pokemon_data[:loyalty] = value
  end
  
  def _get_level
    @pokemon_data[:level].to_i
  end
  
  def _set_level(value)
    @pokemon_data[:level] = value
  end
  
  def _get_systemtag
    @current_group[0].to_i
  end
  
  def _set_systemtag(index, text)
    @current_group[0] = index
  end
  
  def _get_tag
    @current_group[1].to_i
  end
  
  def _set_tag(index, text)
    @current_group[1] = index
  end
  
  def _get_rate
    return @current_group[@pokemon_index*3 + 6]
  end
  
  def _set_rate(value)
    @current_group[@pokemon_index*3 + 6] = value
  end
  
  def _get_is_2v2
    return @current_group[3] == 2
  end
  
  def _set_is_2v2(value)
    @current_group[3] = value ? 2 : 1
  end
  
  def _get_ecart
    return @current_group[2].to_i
  end
  
  def _set_ecart(value)
    @current_group[2] = value
  end
  
  def _get_switch
    return @current_group.instance_variable_get(:@enable_switch).to_i
  end
  
  def _set_switch(value)
    @current_group.instance_variable_set(:@enable_switch, value == 0 ? nil : value)
  end
  
  def _get_mapid
    return @current_group.instance_variable_get(:@map_id).to_i
  end
  
  def _set_mapid(value)
    @current_group.instance_variable_set(:@map_id, value == 0 ? nil : value)
  end
  
  def _on_pokemon_group_change(index, text)
    check_update_data
    __change_pokemon(index)
    update_list(2, index)
    return :update_dialog
  end
  
  def __change_pokemon(index)
    @pokemon_data = @current_group[index * 3 + 5]
    @pokemon_index = index
    update_combo(3, _get_form)
  end
  
  def _pokemon_group_list
    _add_group if @group_data.size == 0
    @current_group = @group_data.first unless @current_group
    nb_pokemon = (@current_group.size - 4) / 3
    if(nb_pokemon == 0)
      _add_pokemon
      @pokemon_index = 0
      nb_pokemon = 1
    end
    lang = @lang_id
    @pokemon_group_list = Array.new(nb_pokemon) do |i| 
      "#{GameData::Text._get(lang,0,@current_group[i*3+5][:id])} #{@current_group[i*3+6]}%"
    end
    return @pokemon_group_list
  end
  
  def _on_group_change(index, text)
    check_update_data
    if text == NewGroup
      _add_group
      @current_group = @group_data.last
      update_list(1, index)
    else
      @current_group = @group_data[index]
    end
    update_list(2, 0)
    __change_pokemon(0)
    return :update_dialog
  end
  
  def _group_list
    @group_list = Array.new(@group_data.size) do |i| 
      "#{Zones[@group_data[i][0]].split(TEXT_SPLIT).first} tag #{@group_data[i][1]} : #{@group_data[i][3]}"
    end
    @group_list << NewGroup
    return @group_list
  end
  
  def _on_zone_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_zone.size)
    check_update_data
    @zone_id = id
    @group_data = $game_data_zone[id].groups
    @group_data = $game_data_zone[id].groups = [] unless @group_data #> Petite sécurité
    _add_group if @group_data.size == 0
    @current_group = @group_data.first
    @pokemon_index = 0
    @group_list = nil
    update_list(1, 0)
    update_list(2, 0)
    __change_pokemon(0)
    return :update_dialog
  end
  
  def _zone_list
    if @zone_list and (@zone_list.size) == $game_data_zone.size
      return @zone_list
    else
      lang = @lang_id
      @zone_list = Array.new($game_data_zone.size) do |i| 
        if $game_data_zone[i].map_name
          sprintf(TEXT_FORMAT, $game_data_zone[i].map_name, i)
        else
          sprintf(TEXT_FORMAT, GameData::Text._get(lang, 10, i), i)
        end
      end
    end
    return @zone_list
  end
  
  def _form_list
    pokemon_id = @pokemon_data[:id]
    pkmn = $game_data_pokemon[pokemon_id]
    arr = Array.new(Pokemon_Dialog::Forms.size) do |i|
      next(Pokemon_Dialog::Forms2[i]) if pkmn[i]
      next(Pokemon_Dialog::Forms[i])
    end
    arr << RandomForm
    @__last_form = arr.size - 1
    return arr
  end
  
  def _get_ability_list
    if @ability_list and (@ability_list.size - 1) == $game_data_abilities.size
      return @ability_list
    else
      @ability_list = Array.new($game_data_abilities.size) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 4, $game_data_abilities[i]), i)
      end
      @ability_list << RandomAbility
      @__last_ability = @ability_list.size - 1
    end
    return @ability_list
  end
  
  def _on_pokemon_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_pokemon.size)
    @pokemon_id = id
  end
  
  def _pokemon_list
    if @pokemon_list and (@pokemon_list.size + 1) == $game_data_pokemon.size
      return @pokemon_list
    else
      lang = @lang_id
      @pokemon_list = Array.new($game_data_pokemon.size - 1) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 0, i+1), i+1)
      end
    end
    return @pokemon_list
  end
  
  def _get_attack_list
    if @attack_list and (@attack_list.size + 1) == $game_data_skill.size
      return @attack_list
    else
      lang = @lang_id
      @attack_list = Array.new($game_data_skill.size - 1) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 6, i+1), i+1)
      end
      @attack_list.insert(0, DefaultAttack)
    end
    return @attack_list
  end
  
  def _add_group
    @group_data << [1, 0, 3, 1]
    @pokemon_index = 0
  end
  
  def _add_pokemon
    hash = @pokemon_data = Hash.new
    id = hash[:id] = @pokemon_id
    
    hash[:given_name] = GameData::Text._get(@lang_id, 0, id)
    hash[:level] = 1
    hash[:loyalty] = $game_data_pokemon[id][0].base_loyalty
    hash[:shiny] = false
    hash[:gender] = nil
    hash[:moves] = Array.new(4, 0)
    hash[:ball] = 4
    hash[:bonus] = Array.new(6, 0)
    
    @current_group << id
    @current_group << hash
    @current_group << 20
  end
  
  def preinit_data
    @lang_id = App.lang_id
    @pokemon_id = 1
    @zone_id = id = 0
    @group_data = $game_data_zone[id].groups
    @group_data = $game_data_zone[id].groups = [] unless @group_data #> Petite sécurité
    _add_group if @group_data.size == 0
    @current_group = @group_data.first
    @pokemon_index = 0
    if(@current_group.size == 4)
      _add_pokemon
    else
      @pokemon_data = @current_group[5]
    end
  end
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Groupe_Dialog.new(App::Dialogs[:group_edit], 0) { |instance| @instance = instance ; instance.preinit_data}
  end
end