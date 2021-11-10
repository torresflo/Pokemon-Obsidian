#encoding: utf-8
class Trainer_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  TYPE_FORMAT = '%d - %s'
  Genders = ["Random", "Undetermined (0)","Male (1)","Female (2)"]
  RandomForm = "Random Form"
  RandomAbility = "Random Ability"
  DefaultAttack = "Default (0)"
  DATA_FILE = "Data/PSDK/Trainers.rxdata"
  BATTLER_FILE = "Graphics\\Battlers\\%s_sma.png"
  BATTLER_FILE2 = "Graphics\\Battlers\\%s.png"
  BATTLER_PATH = "Graphics\\Battlers\\"
  BATTLER_EXT = ".png"
  EXT_DESCR = "Image PNG"
  NAME_SPLIT = ","
  attr_reader :group_id
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    #> Définition des contrôls principaux
    define_combo_controler(1, :_on_pokemon_change, :_pokemon_list)
    #define_combo_controler(13, :_on_zone_change, :_zone_list)
    define_list_controler(1, :_on_group_change, :_group_list)
    define_list_controler(2, :_on_pokemon_group_change, :_pokemon_group_list)

    define_checkbox(2, {getter: :_get_is_2v2, setter: :_set_is_2v2})
    #> Définition des propriétés des Pokémon
    define_combo(2, :_ball_list, :_get_ball, :_set_ball)
    define_combo_controler(3, :_set_form, :_form_list, _get_form)
    define_combo(4, :_item_list, :_get_item, :_set_item)
    define_combo(5, Genders, :_get_gender, :_set_gender)
    define_combo(6, :_get_ability_list, :_get_ability, :_set_ability)
    define_combo(7, :_get_attack_list, :_get_attack1, :_set_attack1)
    define_combo(8, :_get_attack_list, :_get_attack2, :_set_attack2)
    define_combo(9, :_get_attack_list, :_get_attack3, :_set_attack3)
    define_combo(10, :_get_attack_list, :_get_attack4, :_set_attack4)
    
    define_unsigned_int(1, {getter: :_get_no_team, setter: :_set_no_team}, 0, 1)
    define_text_control(2, {getter: :_get_nickname, setter: :_set_nickname}, 64)
    define_unsigned_int(6, {getter: :_get_level, setter: :_set_level}, 1, 99_999)
    define_unsigned_int(7, {getter: :_get_loyalty, setter: :_set_loyalty}, 0, 255)
    define_unsigned_int(8, {getter: :_get_bonus0, setter: :_set_bonus0}, 0, 252)
    define_unsigned_int(9, {getter: :_get_bonus1, setter: :_set_bonus1}, 0, 252)
    define_unsigned_int(10, {getter: :_get_bonus2, setter: :_set_bonus2}, 0, 252)
    define_unsigned_int(11, {getter: :_get_bonus4, setter: :_set_bonus4}, 0, 252)
    define_unsigned_int(12, {getter: :_get_bonus5, setter: :_set_bonus5}, 0, 252)
    define_unsigned_int(13, {getter: :_get_bonus3, setter: :_set_bonus3}, 0, 252)
    define_unsigned_int(14, {getter: :_get_stats0, setter: :_set_stats0}, 0, 31)
    define_signed_int(15, {getter: :_get_stats1, setter: :_set_stats1}, -1, 31)
    define_signed_int(16, {getter: :_get_stats2, setter: :_set_stats2}, -1, 31)
    define_signed_int(17, {getter: :_get_stats4, setter: :_set_stats4}, -1, 31)
    define_signed_int(18, {getter: :_get_stats5, setter: :_set_stats5}, -1, 31)
    define_signed_int(19, {getter: :_get_stats3, setter: :_set_stats3}, -1, 31)
    define_text_control(20, {getter: :_get_names, setter: :_set_names}, 512)
    define_unsigned_int(21, :@base_money, 0, 500)
    define_unsigned_int(22, :@special_group, 0, 999_999)
    define_unsigned_int(23, {getter: :group_id, setter: :_void_setter}, 0, 999_999)
    define_checkbox(1, {getter: :_get_shiny, setter: :_set_shiny})
    #> Définition des actions
    define_button(1, :_add)
    define_button(2, :_save)
    define_button(3, :_add_trainer)
    define_button(4, :_remove_trainer)
    define_button(5, :_remove)
    define_button(6, :_edit_victory_phrase)
    define_button(7, :_edit_defeat_phrase)
    define_button(8, :_edit_trainer_class)
    define_image(1, :_battler_image, :_change_battler_image)
    super
  end
  
  public
  def _add_trainer
    if(check_text_before_adding(size = $game_data_trainer.size, @lang_id, 29, 47, 48))
      check_update_data
      obj = GameData::Trainer.new
      obj.id = $game_data_trainer.size
      $game_data_trainer << obj
      update_list(1, @group_id = $game_data_trainer.size - 1, true)
      update_list(2, 0)
      __change_pokemon(0)
    else
      msgbox("There is not enough text to add a new trainer. Make sure you set their trainer class, as well as their victory and their defeat messages.", self.class.to_s)
    end
  end
  
  def _remove_trainer
    if(confirm("Deleting a trainer can cause bugs in your game.\nAre you sure you want to delete this trainer?", self.class.to_s))
      if @group_id == $game_data_trainer.size - 1 and @group_id > 0
        $game_data_trainer.pop
        @object = $game_data_trainer.last
        _add_pokemon if @object.team.size == 0
        update_list(1, @group_id = $game_data_trainer.size - 1)
      else
        msgbox("The trainer will be deleted.", self.class.to_s)
        @object = $game_data_trainer[@group_id] = GameData::Trainer.new
        _add_pokemon
      end
      @pokemon_group_list = nil
      update_list(2, 0)
      __change_pokemon(0)
      return :update_dialog
    end
  end
  
  def _edit_victory_phrase
    check_update_data
    Text_Dialog.instanciate(@group_id, 47, @hwnd)
    return :update_dialog
  end
  
  def _edit_defeat_phrase
    check_update_data
    Text_Dialog.instanciate(@group_id, 48, @hwnd)
    return :update_dialog
  end
  
  
  def _edit_trainer_class
    Text_Dialog.instanciate(@group_id, 29, @hwnd)
    return :update_dialog
  end
  
  #> Ajout d'un Pokémon au groupe
  def _add
    check_update_data
    _add_pokemon
    index = @object.team.size - 1
    update_list(2, index)
    __change_pokemon(index)
    return :update_dialog
  end
  
  #> Suppression d'un Pokémon au groupe
  def _remove
    if @object.team.size <= 1
      return msgbox("Trainers must have at least one Pokémon!", self.class.to_s)
    end
    @object.team[@pokemon_index] = nil
    @object.team.compact!
    index = @pokemon_index
    index -=1 unless @object.team[index]
    update_list(2, index)
    __change_pokemon(index)
    return :update_dialog
  end
  #> Sauvegarde
  def _save
    check_update_data
    App.save_data($game_data_trainer, get_file_name(DATA_FILE))
  end
  
  def _get_names
    return @object.internal_names.join(NAME_SPLIT)
  end
  
  def _set_names(value)
    @object.internal_names = value.split(NAME_SPLIT)
  end
  
  def _get_no_team
    @pokemon_data[:trainer_id]
  end
  
  def _set_no_team(value)
    value = 0 if value >= @object.internal_names.size
    @pokemon_data[:trainer_id] = value
    @pokemon_data[:trainer_name] = @object.internal_names[value]
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
  
  def _get_stats0
    @pokemon_data[:stats][0].to_i
  end
  
  def _set_stats0(value)
    @pokemon_data[:stats][0] = value
  end
  
  def _get_stats1
    @pokemon_data[:stats][1].to_i
  end
  
  def _set_stats1(value)
    @pokemon_data[:stats][1] = value
  end
  
  def _get_stats2
    @pokemon_data[:stats][2].to_i
  end
  
  def _set_stats2(value)
    @pokemon_data[:stats][2] = value
  end
  
  def _get_stats3
    @pokemon_data[:stats][3].to_i
  end
  
  def _set_stats3(value)
    @pokemon_data[:stats][3] = value
  end
  
  def _get_stats4
    @pokemon_data[:stats][4].to_i
  end
  
  def _set_stats4(value)
    @pokemon_data[:stats][4] = value
  end
  
  def _get_stats5
    @pokemon_data[:stats][5].to_i
  end
  
  def _set_stats5(value)
    @pokemon_data[:stats][5] = value
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
  
  def _get_item
    @pokemon_data[:item].to_i
  end
  
  def _set_item(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_item.size)
    @pokemon_data[:item] = id
  end
  
  def _get_ball
    @ball_list_index.index(@pokemon_data[:ball]).to_i
  end
  
  def _set_ball(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_item.size)
    @pokemon_data[:ball] = id
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
  
  def _get_is_2v2
    return @object.vs_type == 2
  end
  
  def _set_is_2v2(value)
    @object.vs_type = value ? 2 : 1
  end
  
  def _on_pokemon_group_change(index, text)
    check_update_data
    __change_pokemon(index)
    return :update_dialog
  end
  
  def __change_pokemon(index)
    @pokemon_data = @object.team[index]
    @pokemon_index = index
    update_combo(3, _get_form)
  end
  
  def _pokemon_group_list
    return @pokemon_group_list if @pokemon_group_list and @object.team.size == @pokemon_group_list.size
    @pokemon_group_list = Array.new(@object.team.size) do |i| 
      "#{GameData::Text._get(@lang_id, 0 , @object.team[i][:id])} / #{@object.team[i][:trainer_id]}"
    end
    return @pokemon_group_list
  end
  
  def _on_group_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if id < 0 or id >= $game_data_trainer.size
    check_update_data
    @object = $game_data_trainer[id]
    @group_id = id
    _add_pokemon if @object.team.size == 0
    @pokemon_group_list = nil
    update_list(2, 0)
    __change_pokemon(0)
    return :update_dialog
  end
  
  def _group_list
    @group_list = Array.new($game_data_trainer.size) do |i|
      sprintf("%s %s (%03d)", GameData::Trainer.name(i), $game_data_trainer[i].internal_names.join, i)
    end
    return @group_list
  end
  
  def _form_list
    pokemon_id = @pokemon_data[:id]
    pkmn = $game_data_pokemon[pokemon_id]
    if pkmn
      arr = Array.new(Pokemon_Dialog::Forms.size) do |i|
        next(Pokemon_Dialog::Forms2[i]) if pkmn[i]
        next(Pokemon_Dialog::Forms[i])
      end
    else
      arr = []
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
  
  def _item_list
    if @item_list and (@item_list.size + 1) == $game_data_item.size
      return @item_list
    else
      lang = @lang_id
      @item_list = Array.new($game_data_item.size) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 12, i), i)
      end
    end
    return @item_list
  end
  
  def _ball_list
    return @ball_list if @ball_list
    @ball_list = []
    @ball_list_index = []
    $game_data_item.each_with_index do |item, i| 
      if item.ball_data
        @ball_list << sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 12, i), i)
        @ball_list_index << i
      end
    end
    return @ball_list
  end
  
  
  def _add_group
    #@group_data << [1, 0, 3, 1]
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
    hash[:stats] = Array.new(6, 0)
    hash[:trainer_id] = 0
    hash[:trainer_name] = @object.internal_names[0]
    @object.team << hash
  end
  
  def _battler_image
    filename = get_file_name(sprintf(BATTLER_FILE, @object.battler))
    unless File.exist?(filename)
      filename = get_file_name(sprintf(BATTLER_FILE2, @object.battler))
    end
    return filename
  end
  
  def _change_battler_image
    filename = open_file_dialog(EXT_DESCR, BATTLER_EXT, BATTLER_PATH)
    if(filename)
      check_update_data
      @object.battler = filename.gsub(/(_sma|_sha|_big)/,"")
      @last_time -= 2
      return :update_dialog
    end
  end
  
  def _void_setter(value)
  
  end
  
  def preinit_data
    @lang_id = App.lang_id
    @pokemon_id = 1
    @object = $game_data_trainer[0]
    _add_pokemon if @object.team.size == 0
    @pokemon_data = @object.team[0]
    _form_list
  end
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Trainer_Dialog.new(App::Dialogs[:team_edit], 0) { |instance| @instance = instance ; instance.preinit_data}
  end
end