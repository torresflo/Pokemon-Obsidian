#encoding: utf-8
class Pokemon_Plus_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  DATA_FILE = "Data/PSDK/PokemonData.rxdata"
  
  attr_accessor :pokemon_id, :_pokemon_list
  attr_reader :tech_list, :breed_list
  def init_data(dialog)
    @lang_id = App.lang_id
    @sort_type = :level
    @object = $game_data_pokemon[@pokemon_id][0]
    build_lists
    define_list_controler(1, :_on_tech_index_change, :tech_list)
    define_list_controler(2, :_on_breed_index_change, :breed_list)
    define_combo_controler(1, :_on_pokemon_change, :_pokemon_list, @pokemon_id - 1)
    define_combo_controler(2, :_on_ct_change, :_ct_list)
    define_combo_controler(3, :_on_skill_change, :_skill_list)
    define_combo_controler(8, :_on_form_change, :_form_list)
    define_combo(4, :_item_list, :_get_item1, :_set_item1)
    define_combo(5, :_item_list, :_get_item2, :_set_item2)
    define_combo(6, :_skill_list2, :_get_master_move1, :_set_master_move1)
    define_combo(7, :_skill_list2, :_get_master_move2, :_set_master_move2)
    define_unsigned_int(1, {setter: :_set_item_rate1, getter: :_get_item_rate1}, 0, 100)
    define_unsigned_int(2, {setter: :_set_item_rate2, getter: :_get_item_rate2}, 0, 100)
    define_button(1, :_copy_ct)
    define_button(2, :_past_ct)
    define_button(3, :_add_ct)
    define_button(4, :_del_ct)
    define_button(5, :_add_breed_move)
    define_button(6, :_del_breed_move)
    define_button(7, :_copy_breed_move)
    define_button(8, :_past_breed_move)
    define_button(9, :_save)
    super
  end
  
  def check_update_data
    super
    @object.master_moves.compact!
  end
  
  def _copy_breed_move
    @breed_moves_copy = @object.breed_moves.clone
  end
  
  def _past_breed_move
    if @breed_moves_copy
      @object.breed_moves = @breed_moves_copy.clone
      @breed_list = generate_list(@object.breed_moves, @lang_id)
      update_list(2, 0)
    end
  end
  
  def _add_breed_move
    unless @object.breed_moves.include?(@skill_id)
      @object.breed_moves << @skill_id
      @breed_list = generate_list(@object.breed_moves, @lang_id)
      update_list(2, @breed_index = (@breed_index >= @breed_list.size ? @breed_list.size - 1 : @breed_index))
    end
  end
  
  def _del_breed_move
    @object.breed_moves[@breed_index] = nil
    @object.breed_moves.compact!
    @breed_list = generate_list(@object.breed_moves, @lang_id)
    update_list(2, @breed_index = (@breed_index >= @breed_list.size ? @breed_list.size - 1 : @breed_index))
    @breed_index = 0 if @breed_index < 0
  end
  
  def _add_ct
    unless @object.tech_set.include?(@ct_skill_id)
      @object.tech_set << @ct_skill_id
      @tech_list = generate_list(@object.tech_set, @lang_id, @ct_names)
      update_list(1, @tech_index = (@tech_index >= @tech_list.size ? @tech_list.size - 1 : @tech_index))
    end
  end
  
  def _del_ct
    @object.tech_set[@tech_index] = nil
    @object.tech_set.compact!
    @tech_list = generate_list(@object.tech_set, @lang_id, @ct_names)
    update_list(1, @tech_index = (@tech_index >= @tech_list.size ? @tech_list.size - 1 : @tech_index))
    @tech_index = 0 if @tech_index < 0
  end
  
  def _copy_ct
    @ct_copy = @object.tech_set.clone
  end
  
  def _past_ct
    if @ct_copy
      @object.tech_set = @ct_copy.clone
      @tech_list = generate_list(@object.tech_set, @lang_id, @ct_names)
      update_list(1, 0)
    end
  end
  
  def _save
    check_update_data
    App.save_data($game_data_pokemon, get_file_name(DATA_FILE))
    build_lists
    return :update_dialog
  end
  
  def _on_tech_index_change(index, text)
    @tech_index = index < 0 ? 0 : index
  end
  
  def _on_breed_index_change(index, text)
    @breed_index = index < 0 ? 0 : index
  end
  
  def _get_master_move1
    return @object.master_moves[0].to_i
  end
  
  def _set_master_move1(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_skill.size)
    @object.master_moves[0] = (id == 0 ? nil : id)
  end
  
  def _get_master_move2
    return @object.master_moves[1].to_i
  end
  
  def _set_master_move2(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_skill.size)
    @object.master_moves[1] = (id == 0 ? nil : id)
  end
  
  def _set_item_rate1(value)
    @object.items[1] = value
  end
  
  def _get_item_rate1
    return @object.items[1].to_i
  end
  
  def _set_item_rate2(value)
    @object.items[3] = value
  end
  
  def _get_item_rate2
    return @object.items[3].to_i
  end
  
  def _get_item1
    return @object.items[0].to_i
  end
  
  def _set_item1(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_item.size)
    @object.items[0] = id
  end
  
  def _get_item2
    return @object.items[2].to_i
  end
  
  def _set_item2(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_item.size)
    @object.items[2] = id
  end
  
  def _item_list
    _ct_list unless @item_list
    return @item_list
  end
  
  def _ct_list
    if(@ct_list)
      return @ct_list
    end
    lang = @lang_id
    j = 0
    imisc = nil
    arr2 = Array.new
    hash = {}
    
    arr = Array.new($game_data_item.size-1) do |i| 
      j = i+1
      if(imisc = $game_data_item[j].misc_data)
        if(imisc.skill_learn)
          arr2<<(hash[imisc.skill_learn] = sprintf("%s %s (%03d)",GameData::Text._get(lang,12,j), GameData::Text._get(lang,6,imisc.skill_learn),imisc.skill_learn))
        end
      end
      next(sprintf("%s (%03d)",GameData::Text._get(lang,12,j),j))
    end
    #arr.sort! if App.sort_alpha #/!\ getter non adapté !
    arr.insert(0, "None (0)")
    @ct_names = hash
    @item_list = arr
    return @ct_list = arr2
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
  
  def _skill_list2
    if @skill_list2 and (@skill_list2.size + 2) == $game_data_skill.size
      return @skill_list2
    else
      lang = @lang_id
      @skill_list2 = Array.new($game_data_skill.size) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 6, i), i)
      end
      @skill_list2[0] = "None (0)"
    end
    return @skill_list2
  end
  
  def _on_ct_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_skill.size)
    @ct_skill_id = id
  end
  
  def _on_skill_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_skill.size)
    @skill_id = id
  end
  
  def _on_pokemon_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_pokemon.size)
    check_update_data
    @object = $game_data_pokemon[id][0]
    @pokemon_id = id
    @object.id = id
    @object.form = 0
    @pokemon_form = 0
    update_combo(8, 0)
    build_lists
    update_list(1, @tech_index = 0)
    update_list(2, @breed_index = 0)
    return :update_dialog
  end
  
  def build_lists
    @tech_list = generate_list(@object.tech_set, @lang_id, @ct_names)
    @breed_list = generate_list(@object.breed_moves, @lang_id)
  end
  
  def generate_list(var, lang, tech = false)
    arr = Array.new
    i = nil
    if tech
      var.each do |i|
        arr << (tech[i] || sprintf("Err : %s (%03d)", GameData::Text._get(lang,6,i),i))
      end
      return arr
    else
      var.each do |i|
        arr << sprintf("%s (%03d)", GameData::Text._get(lang,6,i),i)
      end
    end
    return arr
  end
  
  def _on_skill_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_skill.size)
    @skill_id = id
  end
  
  def _on_form_change(index, text)
    form_index = text.to_i
    check_update_data
    last_object = @object
    @object = $game_data_pokemon[@pokemon_id][form_index]
    unless @object
      @object = $game_data_pokemon[@pokemon_id][form_index] =
        Marshal.load(Marshal.dump(last_object))
    end
    @pokemon_form = form_index
    update_combo(8, form_index)
    @object.id = @pokemon_id
    @object.form = form_index
    build_lists
    update_list(1, @tech_index = 0)
    update_list(2, @breed_index = 0)
    return :update_dialog
  end
  
  def _form_list
    @pokemon_id = 1 unless @pokemon_id
    pkmn = $game_data_pokemon[@pokemon_id]
    return Array.new(Pokemon_Dialog::Forms.size) do |i|
      next(Pokemon_Dialog::Forms2[i]) if pkmn[i]
      next(Pokemon_Dialog::Forms[i])
    end
  end
  
  def self.instanciate(hwnd, pokemon_id, pokemon_list)
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Pokemon_Plus_Dialog.new(App::Dialogs[:ct_pk], hwnd) do |instance| 
      @instance = instance
      instance.pokemon_id = pokemon_id
      instance._pokemon_list = pokemon_list
    end
  end
  
end