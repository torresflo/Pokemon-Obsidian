#encoding: utf-8
class Type_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  TYPE_FORMAT = '%d - %s'
  DATA_FILE = "Data/PSDK/Types.rxdata"
  TypeEfficiency = ["x 0","x 1/2","x 1","x 2"]
  TypeEfficiencyIndexs = {0 => 0, 0.5 => 1, 1 => 2, 2 => 3}
  TypeEfficiencyValues = [0, 0.5, 1, 2]
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    @dfe_type = 0
    @atk_type = 0
    define_combo_controler(1, :_on_dfe_type_change, :_get_type_list)
    define_combo_controler(2, :_on_atk_type_change, :_get_type_list)
    define_combo(3, TypeEfficiency, :_get_efficency, :_set_efficency)
    define_button(1, :_raz)
    define_button(2, :_save)
    define_button(3, :_add)
    define_button(4, :_del)
    super
  end
  
  public
  def _on_dfe_type_change(index, text)
    check_update_data
    value = text.to_i
    @dfe_type = value if $game_data_types.size > value
    return :update_dialog
  end
  
  def _on_atk_type_change(index, text)
    check_update_data
    value = text.to_i
    @atk_type = value if $game_data_types.size > value
    return :update_dialog
  end
  
  def _get_efficency
    TypeEfficiencyIndexs.fetch($game_data_types[@dfe_type].hit_by(@atk_type), 0)
  end
  
  def _set_efficency(index, text)
    $game_data_types[@dfe_type].on_hit_tbl[@atk_type] = TypeEfficiencyValues[index]
  end
  
  def _save
    check_update_data
    App.save_data($game_data_types, get_file_name(DATA_FILE))
  end
  
  def _raz
    $game_data_types = App.load_data(get_file_name(DATA_FILE))
    _sub_update_combos
    return :update_dialog
  end
  
  def _add
    if(check_text_before_adding((size = $game_data_types.size)-1, @lang_id, 3))
      $game_data_types<<GameData::Type.new(size - 1, $game_data_types[0].on_hit_tbl.clone)
      $game_data_types.each do |type|
        type.on_hit_tbl << 1 if type.on_hit_tbl.size <= size
      end
      _sub_update_combos
    else
      msgbox("There is not enough information to add a new type, make sure you added a name.", self.class.to_s)
    end
  end
  
  def _del
    if(confirm("Removing a type can cause bugs in your game.\nAre you sure you want to remove this type?", self.class.to_s))
      $game_data_types.pop
      _sub_update_combos
      return :update_dialog
    end
  end
  
  def _sub_update_combos
    size = $game_data_types.size
    update_combo(1, @dfe_type = size <= @dfe_type ? size - 1 : @dfe_type)
    update_combo(2, @atk_type = size <= @atk_type ? size - 1 : @atk_type)
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
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Type_Dialog.new(App::Dialogs[:type], 0) { |instance| @instance = instance}
  end
end