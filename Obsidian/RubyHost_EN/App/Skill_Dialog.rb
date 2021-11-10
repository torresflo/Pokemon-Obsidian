#encoding: utf-8
class Skill_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  DATA_FILE = "Data/PSDK/SkillData.rxdata"
  TYPE_FORMAT = '%d - %s'
  Skill_Targets = [
      :adjacent_pokemon,      #  eo eo ex / ux ao ax
      :adjacent_foe,          #  eo eo ex / ux ax ax
      :adjacent_all_foe,      #  e! e! ex / ux ax ax
      :all_foe,               #  e! e! e! / ux ax ax
      :adjacent_all_pokemon,  #  e! e! ex / ux a! ax
      :all_pokemon,           #  e! e! e! / u! a! a!
      :user,                  #  ex ex ex / u! ax ax
      :user_or_adjacent_ally, #  ex ex ex / uo ao ax
      :adjacent_ally,         #  ex ex ex / ux ao ax
      :all_ally,              #  ex ex ex / u! a! a!
      :any_other_pokemon,     #  eo eo eo / ux ao ao
      :random_foe             #  e? e? e? / ux ax ax
    ]
  Skill_Meth = [nil,:s_basic,:s_stat,:s_status,:s_multi_hit,:s_2hits,:s_ohko,:s_2turns,:s_self_stat,:s_self_statut]
  Skill_TextTarget = [
      "Normal :adjacent_pokemon",                      #  eo eo ex / ux ao ax
      "Adjacent foe :adjacent_foe",   #  eo eo ex / ux ax ax
      "All adjacent foes :adjacent_all_foe",                 #  e! e! ex / ux ax ax
      "All foes :all_foe",                          #  e! e! e! / ux ax ax
      "All adjacent Pokemon :adjacent_all_pokemon",     #  e! e! ex / ux a! ax
      "All Pokemon :all_pokemon",                        #  e! e! e! / u! a! a!
      "User :user",                                      #  ex ex ex / u! ax ax
      "User or ally :user_or_adjacent_ally",         #  ex ex ex / uo ao ax
      "Adjacent Ally :adjacent_ally",                        #  ex ex ex / ux ao ax
      "User field :all_ally",                           #  ex ex ex / u! a! a!
      "Any other pokemon :any_other_pokemon",                  #  eo eo eo / ux ao ao
      "Random foe :random_foe"                   #  e? e? e? / ux ax ax
    ]
  Critical = ["0 - Null", "1 - Normal 7%", "2 - High 13%", "3 - 25%", "4 - Interdit 34%", "5 - Interdit 50%"]
  Category = ["1 - Physical", "2 - Special", "3 - Status"]
  Text_Method = ["Special","Normal :s_basic","Statistic move :s_stat","Status :s_status","Dealing upto 5 hits :s_multi_hit","Two hits :s_2hits","OHKO :s_ohko","During 2 turns :s_2turns","Self statistic move :s_self_stat","Self status :s_self_statut"]
  Status = ["0 - None", "1 - Poison", "2 - Paralysis", "3 - Burn", "4 - Sleep", "5 - Freeze", "? - Confuse", "? - Flinch", "8 - Toxic"]
  Priority = Array.new(15) do |i| (i-7).to_s end
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    define_combo_controler(1, :_on_skill_change, :_skill_list)
    define_text_view(1, :_get_skill_name)
    define_text_view(2, :_get_skill_descr)
    define_combo(2, :_get_type_list, :_get_type, :_set_type)
    define_combo(3, Category, :_get_cat, :_set_cat)
    define_combo(4, Skill_TextTarget, :_get_target, :_set_target)
    define_combo(5, Critical, :_get_critical_rate, :_set_critical_rate)
    define_combo(6, Priority, :_get_priority, :_set_priority)
    define_combo(8, Status, :_get_status, :_set_status)
    define_combo_controler(7, :_on_meth_change, Text_Method)
    define_text_control(7, {getter: :_get_meth, setter: :_set_meth}, 128)
    define_unsigned_int(3, :@power, 0, 512)
    define_unsigned_int(4, :@accuracy, 0, 100)
    define_unsigned_int(5, :@pp_max, 5, 40)
    define_unsigned_int(6, :@map_use, 0, 99_999)
    define_unsigned_int(8, :@effect_chance, 0, 100)
    define_checkbox(1, :@direct)
    define_checkbox(3, :@snatchable)
    define_checkbox(4, :@blocable)
    define_checkbox(5, :@unfreeze)
    define_checkbox(6, :@gravity)
    define_checkbox(7, :@magic_coat_affected)
    define_checkbox(8, :@mirror_move)
    define_checkbox(9, :@king_rock_utility)
    define_checkbox(10, :@sound_attack)
    define_signed_int(9, {getter: :_get_atkm, setter: :_set_atkm}, -6, 6)
    define_signed_int(10, {getter: :_get_dfem, setter: :_set_dfem}, -6, 6)
    define_signed_int(11, {getter: :_get_spdm, setter: :_set_spdm}, -6, 6)
    define_signed_int(12, {getter: :_get_atsm, setter: :_set_atsm}, -6, 6)
    define_signed_int(13, {getter: :_get_dfsm, setter: :_set_dfsm}, -6, 6)
    define_signed_int(14, {getter: :_get_evam, setter: :_set_evam}, -6, 6)
    define_signed_int(15, {getter: :_get_accm, setter: :_set_accm}, -6, 6)
    define_button(1, :_edit_skill_name)
    define_button(2, :_edit_skill_descr)
    define_button(3, :_save)
    define_button(4, :_raz_skill)
    define_button(5, :_add)
    define_button(6, :_del)
    super
  end
  
  public
  def _save
    check_update_data
    App.save_data($game_data_skill, get_file_name(DATA_FILE))
  end
  
  def _raz_skill
    $game_data_skill = App.load_data(get_file_name(DATA_FILE))
    return :update_dialog
  end
  
  def _get_skill_name
    GameData::Text._get(@lang_id, 6, @skill_id)
  end
  
  def _get_skill_descr
    GameData::Text._get(@lang_id, 7, @skill_id)
  end
  
  def _edit_skill_name
    Text_Dialog.instanciate(@skill_id, 6, @hwnd)
    return :update_dialog
  end
  
  def _edit_skill_descr
    Text_Dialog.instanciate(@skill_id, 7, @hwnd)
    return :update_dialog
  end
  
  def _get_type_list
    if @type_list and (@type_list.size) == $game_data_types.size
      return @type_list
    else
      @type_list = Array.new($game_data_types.size) do |i| 
        sprintf(TYPE_FORMAT, i, $game_data_types[i].name)
      end
    end
    return @type_list
  end
  
  def _get_type
    @object.type
  end
  
  def _set_type(index, text)
    @object.type = text.to_i
  end
  
  def _get_status
    @object.status
  end
  
  def _set_status(index, text)
    @object.status = index
  end
  
  def _get_priority
    @object.priority #+ 7
  end
  
  def _set_priority(index, text)
    @object.priority = index#text.to_i
  end
  
  def _get_critical_rate
    @object.critical_rate
  end
  
  def _set_critical_rate(index, text)
    @object.critical_rate = text.to_i
  end
  
  def _get_cat
    @object.atk_class - 1
  end
  
  def _set_cat(index, text)
    @object.atk_class = text.to_i
  end
  
  def _get_target
    Skill_Targets.index(@object.target).to_i
  end
  
  def _set_target(index, text)
    @object.target = Skill_Targets[index]
  end
  
  def _get_atkm
    @object.battle_stage_mod[0]
  end
  
  def _set_atkm(value)
    @object.battle_stage_mod[0] = value.to_i
  end
  
  def _get_dfem
    @object.battle_stage_mod[1]
  end
  
  def _set_dfem(value)
    @object.battle_stage_mod[1] = value.to_i
  end
  
  def _get_spdm
    @object.battle_stage_mod[2]
  end
  
  def _set_spdm(value)
    @object.battle_stage_mod[2] = value.to_i
  end
  
  def _get_atsm
    @object.battle_stage_mod[3]
  end
  
  def _set_atsm(value)
    @object.battle_stage_mod[3] = value.to_i
  end
  
  def _get_dfsm
    @object.battle_stage_mod[4]
  end
  
  def _set_dfsm(value)
    @object.battle_stage_mod[4] = value.to_i
  end
  
  def _get_evam
    @object.battle_stage_mod[5]
  end
  
  def _set_evam(value)
    @object.battle_stage_mod[5] = value.to_i
  end
  
  def _get_accm
    @object.battle_stage_mod[6]
  end
  
  def _set_accm(value)
    @object.battle_stage_mod[6] = value.to_i
  end
  
  def _on_skill_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_skill.size)
    check_update_data
    @object = $game_data_skill[id]
    @skill_id = id
    @object.id = id
    return :update_dialog
  end
  
  def _on_meth_change(index, text)
    meth = Skill_Meth[index]
    if(meth)
      update_text(7, meth.to_s)
      @object.be_method = meth
    end
    return :update_dialog
  end
  
  def _get_meth
    update_combo(7, Skill_Meth.index(@object.be_method).to_i, false, false)
    @object.be_method.to_s
  end
  
  def _set_meth(value)
    if(@object.be_method.to_s != value)
      @object.be_method = value.to_sym
    end
  end
  
  def _skill_list
    if @skill_list and (@skill_list.size + 1) == $game_data_skill.size
      return @skill_list
    else
      lang = @lang_id
      @skill_list = Array.new($game_data_skill.size - 1) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 6, i+1), i+1)
      end
    end
    return @skill_list
  end
  
  def _add
    if(check_text_before_adding(size = $game_data_skill.size, @lang_id, 6, 7))
      check_update_data
      @object = atk = GameData::Skill.new
      @skill_id = size
      @object.id = size
      define_basic_object(atk)
      $game_data_skill << atk
      list = _skill_list
      position = list.index(sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 6, size), size)).to_i
      update_combo(1, position, true)
    else
      msgbox("Either a name, or description is missing.", self.class.to_s)
    end
  end
  
  def _del
    if(confirm("Any deletion can cause bugs in the game.\nAre you sure you want to delete this attack?", self.class.to_s))
      if @skill_id == ($game_data_skill.size-1) and @skill_id > 1
        $game_data_skill.pop
        text = _skill_list.last
        id = text.split(TEXT_SPLIT).last.to_i
        id = 1 if(id < 1 or id >= $game_data_skill.size)
        @object = $game_data_skill[@skill_id = id][0]
        update_combo(1, $game_data_skill.size - 2)
      else
        msgbox("L'attaque sera vidée.", self.class.to_s)
        @object = obj = GameData::Skill.new
        define_basic_object(obj)
        $game_data_skill[@skill_id] = obj
      end
      return :update_dialog
    end
  end
  
  def define_basic_object(sk)
    sk.direct = sk.snatchable = sk.blocable = sk.unfreeze = sk.gravity = sk.magic_coat_affected = sk.mirror_move = sk.king_rock_utility = sk.sound_attack = false
    sk.battle_stage_mod = [0,0,0,0,0,0,0]
    sk.power = 40
    sk.accuracy = 100
    sk.pp_max = 15
    sk.map_use = 0
    sk.effect_chance = 0
    sk.status = 0
    sk.type = 1
    sk.atk_class = 1
    sk.target = :adjacent_pokemon
    sk.critical_rate = 1
    sk.priority = 7
    sk.be_method = :s_basic
  end
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Skill_Dialog.new(App::Dialogs[:atk], 0) { |instance| @instance = instance}
  end
end