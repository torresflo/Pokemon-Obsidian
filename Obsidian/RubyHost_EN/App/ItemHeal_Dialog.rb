#encoding: utf-8
class ItemHeal_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  States = [nil,[1],[2],[3],[4],[5],[6],[7],[8],[9],[1,8],[1,2,3,4,5,6,7,8]]
	EVS = ["Nothing","HP +10 (0)","ATK +10 (1)","DEF +10 (2)","SPEED +10 (3)","SP. ATK +10 (4)","SP. DEF +10 (5)","HP +1 (10)","ATK +1 (11)","DEF +1 (12)","SPEED +1 (13)","SP. ATK +1 (14)","SP. DEF +1 (15)"]
	Battle = ["Nothing","Attack (0)","Defense (1)","Speed (2)","Sp. Attack (3)","Sp. Defense (4)","Evasion (5)","Accuracy (6)"]
	StatesNames = ["Any","1 - Poison","2 - Paralysis","3 - Burn","4 - Sleep","5 - Gel","6 - Confusion","7 - ???","8 - Toxic","9 - K.O.","Empoisonnement","All (mort/K.O. excluded)"]
	PP = ["None", "+1","Max"]
  attr_accessor :item_id
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    @object = $game_data_item[@item_id].heal_data
    @object = GameData::ItemHeal.new unless @object
    @object.id = @item_id
    @original_item = @object
    @object = Marshal.load(Marshal.dump(@object))
    define_combo(1, StatesNames, :_get_state_cure, :_set_state_cure)
    define_combo(2, EVS, :_get_ev_gain, :_set_ev_gain)
    define_combo(3, PP, :_get_pp_plus, :_set_pp_plus)
    define_combo(4, Battle, :_get_battle_boost, :_set_battle_boost)
    define_text_view(1, :_get_item_name)
    define_unsigned_int(2, :@hp, 0, 9_000_000)
    define_unsigned_int(3, :@hp_rate, 0, 100)
    define_checkbox(1, {getter: :_get_all_pp, setter: :_set_all_pp}) #> Doit être avant edit 4
    define_unsigned_int(4, {getter: :_get_pp_heal, setter: :_set_pp_heal}, 0, 100)
    define_signed_int(5, {getter: :_get_loyalty, setter: :_set_loyalty}, -255, 255)
    define_unsigned_int(6, {getter: :_get_level, setter: :_set_level}, 0, 9000)
    define_button(1, :_validate)
    define_button(2, :_reset)
    super
  end
  
  public
  def self.instanciate(item_id, hwnd)
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    ItemHeal_Dialog.new(App::Dialogs[:item_heal], hwnd) { |instance| @instance = instance ; instance.item_id = item_id }
  end
  
  def _validate
    check_update_data
    o = @object
    if(o.hp == 0 and o.hp_rate == 0 and !o.loyalty and !o.pp and !o.all_pp and !o.states and !o.level and !o.boost_stat and !o.battle_boost and !o.add_pp)
      $game_data_item[@item_id].heal_data = nil
    else
      $game_data_item[@item_id].heal_data = @object
    end
    return :update_dialog
  end
  
  def _reset
    @object = Marshal.load(Marshal.dump(@original_item))
    return :update_dialog
  end
  
  def _get_level
    @object.level
  end
  
  def _set_level(value)
    value = nil if value == 0
    @object.level = value
  end
  
  def _get_loyalty
    @object.loyalty
  end
  
  def _set_loyalty(value)
    value = nil if value == 0
    @object.loyalty = value
  end
  
  def _get_pp_heal
    @all_pp ? @object.pp : @object.all_pp
  end
  
  def _set_pp_heal(value)
    value = nil if value == 0
    @object.pp = value unless @all_pp
    @object.all_pp = value if @all_pp
  end
  
  def _get_all_pp
    if @object.all_pp
      @object.pp = nil
      @all_pp = true
    else
      @all_pp = false
    end
  end
  
  def _set_all_pp(value)
    @all_pp = value
    @object.pp = nil if value
    @object.all_pp = nil unless value
  end
  
  def _get_item_name
    sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 12, @item_id), @item_id)
  end
  
  def _get_state_cure
    States.index(@object.states).to_i
  end
  
  def _set_state_cure(index, text)
    @object.states = States[index]
  end
  
  def _get_pp_plus
    @object.add_pp.to_i
  end
  
  def _set_pp_plus(index, text)
    return @object.add_pp = nil if index == 0
    @object.add_pp = index
  end
  
  def _get_battle_boost
    @object.battle_boost ? @object.battle_boost + 1 : 0
  end
  
  def _set_battle_boost(index, text)
    return @object.battle_boost = nil if index == 0
    @object.battle_boost = text.split(TEXT_SPLIT).last.to_i
  end
  
  def _get_ev_gain
    if(@object.boost_stat and @object.boost_stat >= 10)
      return @object.boost_stat - 3
    elsif(@object.boost_stat)
      return @object.boost_stat + 1
    end
    return 0
  end
  
  def _set_ev_gain(index, text)
    return @object.boost_stat = nil if index == 0
    @object.boost_stat = text.split(TEXT_SPLIT).last.to_i
  end
end