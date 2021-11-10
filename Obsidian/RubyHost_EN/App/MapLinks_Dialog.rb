#encoding: utf-8
class MapLinks_Dialog < DialogHost
  TEXT_FORMAT = "%s (%d)"
  TEXT_SPLIT = "("
  DATA_FILE = "Data/PSDK/Maplinks.rxdata"
  
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    define_combo_controler(1, :_on_map_change, :_map_list)
    define_combo(2, :_map_list2, :_get_east_map, :_set_east_map)
    define_combo(3, :_map_list2, :_get_west_map, :_set_west_map)
    define_combo(4, :_map_list2, :_get_south_map, :_set_south_map)
    define_combo(5, :_map_list2, :_get_north_map, :_set_north_map)
    define_signed_int(1, {getter: :_get_east_dec, setter: :_set_east_dec}, -500, 500)
    define_signed_int(3, {getter: :_get_west_dec, setter: :_set_west_dec}, -500, 500)
    define_signed_int(2, {getter: :_get_south_dec, setter: :_set_south_dec}, -500, 500)
    define_signed_int(4, {getter: :_get_north_dec, setter: :_set_north_dec}, -500, 500)
    define_button(1, :_save)
    super
  end
  public
  
  def _save
    check_update_data
    adjust_other_maps(@current_id, @object) if @object
    App.save_data($game_data_maplinks, get_file_name(DATA_FILE))
  end
  
  def _on_map_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    check_update_data
    return unless $mapinfos[id]
    $game_data_maplinks[id] ||= Array.new(8, 0)
    adjust_other_maps(@current_id, @object) if @object
    @object = $game_data_maplinks[@current_id = id]
    @copy = @object.clone
    return :update_dialog
  end
  
  def adjust_other_maps(id, data)
    sid = nil
    if (sid = data[0]) != 0 and sid != id
      $game_data_maplinks[sid] ||= Array.new(8, 0)
      $game_data_maplinks[sid][4] = id
      $game_data_maplinks[sid][5] = -data[1]
    end
    if (sid = data[2]) != 0 and sid != id
      $game_data_maplinks[sid] ||= Array.new(8, 0)
      $game_data_maplinks[sid][6] = id
      $game_data_maplinks[sid][7] = -data[3]
    end
    if (sid = data[4]) != 0 and sid != id
      $game_data_maplinks[sid] ||= Array.new(8, 0)
      $game_data_maplinks[sid][0] = id
      $game_data_maplinks[sid][1] = -data[5]
    end
    if (sid = data[6]) != 0 and sid != id
      $game_data_maplinks[sid] ||= Array.new(8, 0)
      $game_data_maplinks[sid][2] = id
      $game_data_maplinks[sid][3] = -data[7]
    end
  end
  
  def set_void_map(copy_index, link_index)
    if @copy[copy_index] != 0
      data = $game_data_maplinks[@copy[copy_index]]
      if data and data[link_index] == @current_id
        data[link_index] = 0
        data[link_index + 1] = 0
      end
    end
  end
  
  def _get_east_map
    return _find_map(@object[2].to_i)
  end
  
  def _set_east_map(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 unless $mapinfos[id]
    @object[2] = id
    set_void_map(2, 6) if(id == 0)
  end
  
  def _get_east_dec
    return @object[3].to_i
  end
  
  def _set_east_dec(value)
    @object[3] = value
  end
  
  def _get_west_map
    return _find_map(@object[6].to_i)
  end
  
  def _set_west_map(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 unless $mapinfos[id]
    @object[6] = id
    set_void_map(6, 2) if(id == 0)
  end
  
  def _get_west_dec
    return @object[7].to_i
  end
  
  def _set_west_dec(value)
    @object[7] = value
  end
  
  def _get_south_map
    return _find_map(@object[4].to_i)
  end
  
  def _set_south_map(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 unless $mapinfos[id]
    @object[4] = id
    set_void_map(4, 0) if(id == 0)
  end
  
  def _get_south_dec
    return @object[5].to_i
  end
  
  def _set_south_dec(value)
    @object[5] = value
  end
  
  def _get_north_map
    return _find_map(@object[0].to_i)
  end
  
  def _set_north_map(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 unless $mapinfos[id]
    @object[0] = id
    set_void_map(0, 4) if(id == 0)
  end
  
  def _get_north_dec
    return @object[1].to_i
  end
  
  def _set_north_dec(value)
    @object[1] = value
  end
  
  def _find_map(id)
    return 0 unless map = $mapinfos[id]
    return 0 if id == 0
    return @map_list2.index(@map_list2.grep(Regexp.new("\\(#{id}\\)$"))[0]).to_i
  end
  
  def _map_list
    return @map_list if @map_list
    maps = {}
    ignores = []
    $mapinfos.each do |id, data|
      next unless data
      if data.parent_id != 0
        maps[data.parent_id] ||= {}
        maps[id] ||= {}
        maps[data.parent_id][id] = maps[id]
        ignores << id
      else
        maps[id] ||= {}
      end
    end
    @map_list = []
    explore_maps(maps, @map_list, ignores, 0)
    return @map_list
  end
  
  def _map_list2
    return @map_list2 if @map_list2
    @map_list2 = _map_list.clone
    @map_list2.insert(0, "Vide (0)")
    return @map_list2
  end
  
  def explore_maps(maps, map_list, ignores, deepness)
    maps.each do |id, data|
      next if ignores.include?(id)
      map_list << sprintf(TEXT_FORMAT, ("+" * deepness) + $mapinfos[id].name, id)
      explore_maps(data, map_list, [], deepness + 1)
    end
  end
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    MapLinks_Dialog.new(App::Dialogs[:maplinks], 0) { |instance| @instance = instance}
  end
end