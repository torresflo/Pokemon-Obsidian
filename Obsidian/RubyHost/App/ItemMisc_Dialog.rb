#encoding: utf-8
class ItemMisc_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  DATA_FILE = "Data/PSDK/ItemData.rxdata"
  
  attr_accessor :item_id, :_item_list
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    @object = $game_data_item[@item_id].misc_data || new_misc_data
    @object.id = @item_id
    @original_item = @object
    @object = Marshal.load(Marshal.dump(@object))
    define_combo_controler(1, :_on_item_change, :_item_list, @item_id - 1)
    define_combo(2, :_skill_list, :_get_skill, :_set_skill)
    define_unsigned_int(1, :@event_id, 0, 99_999)
    define_unsigned_int(2, :@repel_count, 0, 1024)
    define_unsigned_int(3, {getter: :get_ct_id, setter: :set_ct_id}, 0, 1024)
    define_unsigned_int(4, {getter: :get_cs_id, setter: :set_cs_id}, 0, 1024)
    define_text_view(5, :_get_extended_edit)
    define_checkbox(3, :@stone)
    define_checkbox(4, :@flee)
    
    define_button(1, :_save)
    define_button(2, :update_dialog)
    super
  end
  
  public
  def self.instanciate(item_id, hwnd, item_list)
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    ItemMisc_Dialog.new(App::Dialogs[:item_misc], hwnd) do |instance| 
      @instance = instance
      instance.item_id = item_id
      instance._item_list = item_list
    end
  end
  
  ExtendedEdit = "Ce champ ne sert plus à rien. PSDK va changer sa façon de considérer les objets à effet en combat..."
  def _get_extended_edit
    ExtendedEdit
  end
  
  def get_ct_id
    return @object.ct_id.to_i
  end
  
  def set_ct_id(value)
    @object.ct_id = (value == 0 ? nil : value)
  end
  
  def get_cs_id
    return @object.cs_id.to_i
  end
  
  def set_cs_id(value)
    @object.cs_id = (value == 0 ? nil : value)
  end
  
  def _get_skill
    return @object.skill_learn.to_i
  end
  
  def _set_skill(index, text)
    @object.skill_learn = (index == 0 ? nil : index)
  end
  
  def _skill_list
    if @skill_list and (@skill_list.size + 2) == $game_data_skill.size
      return @skill_list
    else
      lang = @lang_id
      @skill_list = Array.new($game_data_skill.size) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 6, i), i)
      end
      @skill_list[0] = "Aucun (0)"
    end
    return @skill_list
  end
  
  def _on_item_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_item.size)
    check_update_data
    #> Vérification des données
    $game_data_item[@item_id].misc_data = nil unless check_item_misc_used
    #> Changement d'objet
    @object = $game_data_item[id].misc_data || new_misc_data
    $game_data_item[id].id = @object.id = id
    $game_data_item[id].misc_data = @object
    @item_id = id
    return :update_dialog
  end
  
  def _save
    check_update_data
    $game_data_item[@item_id].misc_data = nil unless check_item_misc_used
    App.save_data($game_data_item, get_file_name(DATA_FILE))
    $game_data_item[@item_id].misc_data = @object
  end
  
  def new_misc_data
    o = GameData::ItemMisc.new
    o.repel_count = 0
    o.event_id = 0
    return o
  end
  
  def check_item_misc_used
    used = false
    o = @object
    o.instance_variables.each do |variable_name|
      next if variable_name == :@repel_count or variable_name == :@event_id
      used = true if o.instance_variable_get(variable_name)
    end
    if(o.repel_count == 0 and o.event_id == 0 and !used)
      return false
    end
    return true
  end
end