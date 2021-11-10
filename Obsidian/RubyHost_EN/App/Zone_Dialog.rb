#encoding: utf-8
class Zone_Dialog < DialogHost
  DATA_FILE = "Data/PSDK/MapData.rxdata"
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  MAP_ID_MULT = ","
  MAP_ID_CR1 = "["
  MAP_ID_CR2 = "]"
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    define_combo_controler(1, :_on_zone_change, :_zone_list)
    define_text_control(1, {getter: :_get_mapname, setter: :_set_mapname}, 512)
    define_text_control(2, :@map_id, 20_000, :_map_id_value)
    define_unsigned_int(3, :@panel_id, 0, 99_999)
    define_text_control(4, :@warp_x, 100, :_normalize_warp)
    define_text_control(5, :@warp_y, 100, :_normalize_warp)
    define_text_control(6, :@pos_x, 100, :_normalize_warp)
    define_text_control(7, :@pos_y, 100, :_normalize_warp)
    define_text_control(8, :@forced_weather, 100, :_normalize_warp)
    define_checkbox(1, :@warp_dissalowed)
    define_checkbox(2, :@fly_allowed)
    
    define_button(1, :_save)
    define_button(2, :_add)
    define_button(4, :_remove)
	define_button(5, :_edit_zone_name)
    super
  end
  
  public
  #> Ajout
  def _add
    check_update_data
    if(check_text_before_adding(size = $game_data_zone.size, @lang_id, 10))
      @object = GameData::Map.new(0)
      @zone_id = $game_data_zone.size
      @object.id = @zone_id
      $game_data_zone << @object
      update_combo(1, @zone_id)
    else
      msgbox("Il manque des textes de Nom de Lieu (10) pour créer une nouvelle zone...", self.class.to_s)
    end
    return :update_dialog
  end
  #> Suppression
  def _remove
    return if $game_data_zone.size <= 1
    if(@zone_id != $game_data_zone.size - 1)
      return unless confirm("Attention, all the following zones will be decreased by 1. Delete anyways?", self.class.to_s)
    end
    if @object.groups.size > 0
      return unless confirm("This area contains groups, do you want to delete it?", self.class.to_s)
    end
    $game_data_zone[@zone_id] = nil
    $game_data_zone.compact!
    $game_data_zone.each_with_index do |el, id|
      el.id = id
    end
    @zone_id -= 1 if(@zone_id >= $game_data_zone.size)
    @object = $game_data_zone[@zone_id]
    @object.groups = [] unless @object.groups
    update_combo(1, @zone_id)
    return :update_dialog
  end
  #New by BJ
  def _edit_zone_name
	Text_Dialog.instanciate(@group_id, 10, @hwnd)
    return :update_dialog
  end
  #> Sauvegarde
  def _save
    check_update_data
    App.save_data([$game_data_map, $game_data_zone], get_file_name(DATA_FILE))
  end
  
  def _normalize_warp(value)
    return nil if value.bytesize == 0
    return value.to_i
  end
  
  def _get_mapname
    if @object.map_name
      return @object.map_name
    end
    GameData::Text._get(@lang_id, 10, @zone_id)
  end
  
  def _set_mapname(value)
    
  end
  
  def _map_id_value(value)
    if(value.include?(MAP_ID_MULT))
      if(value.include?(MAP_ID_CR1))
        value += MAP_ID_CR2 unless(value.include?(MAP_ID_CR2))
      else
        value = MAP_ID_CR1 + value
        value += MAP_ID_CR2 unless(value.include?(MAP_ID_CR2))
      end
      value = eval(value) rescue 0
      value = 0 if value.class != Array
      return value
    else
      return value.to_i
    end
  end
  
  def _on_zone_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_zone.size)
    check_update_data
    @zone_id = id
    @object = $game_data_zone[id]
    @object.groups = [] unless @object.groups
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
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Zone_Dialog.new(App::Dialogs[:zone], 0) { |instance| @instance = instance }
  end
end