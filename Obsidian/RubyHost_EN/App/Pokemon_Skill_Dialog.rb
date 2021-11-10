#encoding: utf-8
class Pokemon_Skill_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  DATA_FILE = "Data/PSDK/PokemonData.rxdata"
  
  attr_accessor :pokemon_id, :_pokemon_list
  attr_reader :level_list, :move_list
  def init_data(dialog)
    @lang_id = App.lang_id
    @sort_type = :level
    define_list_controler(1, :_on_pokemon_change, :_pokemon_list, @pokemon_id - 1)
    @object = $game_data_pokemon[@pokemon_id][0]
    build_lists
    define_list_controler(2, :_on_level_change, :level_list)
    define_list_controler(3, :_on_level_change, :move_list)
    define_combo_controler(1, :_on_skill_change, :_skill_list)
    define_combo_controler(2, :_on_form_change, :_form_list)
    define_text_view(1, :_get_pokemon_name)
    define_text_view(2, :_get_pokemon_type1)
    define_text_view(3, :_get_pokemon_type2)
    define_text_view(4, :_get_pokemon_stat)
    define_unsigned_int(5, {getter: :get_level, setter: :set_level}, 1, 255)
    define_button(1, :_raz_pokemon)
    define_button(3, :_save)
    define_button(4, :_edit_level)
    define_button(5, :_delete_skill)
    define_button(6, :_sort_level)
    define_button(7, :_sort_name)
    define_button(8, :_copy)
    define_button(9, :_paste)
    define_button(10, :_add)
    super
  end
  
  def _add
    check_update_data
    index = @level_index * 2
    @object.move_set[index + 1] = @skill_id
    @object.move_set[index] = @last_level
    build_lists
    update_list(2, @level_index)
    update_list(3, @level_index)
    return :update_dialog
  end
  
  def _copy
    @copy_data = @object.move_set.clone
  end
  
  def _paste
    return unless @copy_data
    @object.move_set += @copy_data
    build_lists
    update_list(2, @level_index)
    update_list(3, @level_index)
    return :update_dialog
  end
  
  def _sort_level
    if @sort_type != :level
      @sort_type = :level
      @last_move_set = nil
      build_lists
      update_list(2, @level_index)
      update_list(3, @level_index)
      return :update_dialog
    end
  end
  
  def _sort_name
    if @sort_type != :name
      @sort_type = :name
      @last_move_set = nil
      build_lists
      update_list(2, @level_index)
      update_list(3, @level_index)
      return :update_dialog
    end
  end
  
  def _delete_skill
    index = @level_index * 2
    if index < @object.move_set.size
      check_update_data
      @object.move_set[index] = @object.move_set[index + 1] = nil
      @object.move_set.compact!
      index -= 2 while index >= @object.move_set.size
      build_lists
      update_list(2, @level_index = index / 2)
      update_list(3, @level_index)
      return :update_dialog
    end
  end
  
  def _save
    check_update_data
    clean_pokemon_moves
    App.save_data($game_data_pokemon, get_file_name(DATA_FILE))
    build_lists
    return :update_dialog
  end
  
  def _raz_pokemon
    $game_data_pokemon = App.load_data(get_file_name(DATA_FILE))
    @object = $game_data_pokemon[@pokemon_id][@pokemon_form = 0]
    build_lists
    update_combo(2, 0)
    update_list(2, @level_index = 0)
    update_list(3, @level_index)
    return :update_dialog
  end
  
  def _edit_level
    if @level_index * 2 < @object.move_set.size
      check_update_data
      @object.move_set[@level_index * 2] = @last_level
      build_lists
      update_list(2, @level_index)
      update_list(3, @level_index)
      return :update_dialog
    end
  end
  
  def get_level
    level = @object.move_set[@level_index * 2]
    return @last_level unless level
    return @last_level = level
  end
  
  def set_level(value)
    @last_level = value
  end
  
  def _get_pokemon_type2
    $game_data_types[@object.type2].name
  end
  
  def _get_pokemon_type1
    $game_data_types[@object.type1].name
  end
  
  def _get_pokemon_stat
    pkmn = @object
    "HP: #{pkmn.base_hp}\r\nAttack: #{pkmn.base_atk}\r\nDefense: #{pkmn.base_dfe}\r\nSpeed: #{pkmn.base_spd}\r\nSp. Attack: #{pkmn.base_ats}\r\nSp. Defense: #{pkmn.base_dfs}\r\nHeight: #{pkmn.height} m\r\nWeight: #{pkmn.weight} kg"
  end
  
  def _get_pokemon_name
    GameData::Text._get(@lang_id, 0, @pokemon_id)
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
  
  def _on_level_change(index, text)
    @level_index = index
    update_list(2, index)
    update_list(3, index)
    return :update_dialog
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
    update_combo(2, 0)
    build_lists
    update_list(2, 0)
    update_list(3, 0)
    _on_level_change(0, nil)
    return :update_dialog
  end
  
  def build_lists
    atk = @object.move_set
    return if atk == @last_move_set
    @last_move_set = atk.clone
    sort_pokemon_moves(atk)
    levels = []
    skills = []
    lang = @lang_id
    0.step(atk.size-1 ,2) do |i|
      levels << "Lv. #{atk[i]}"
      sid = atk[i+1]
      skill = $game_data_skill[sid]
      skills << "#{GameData::Text._get(lang,6,sid)}, #{$game_data_types[skill.type].name}, #{skill.power==0 ? "---" : skill.power}, #{skill.accuracy==0 ? "---" : skill.accuracy} (#{sid})"
    end
    levels << "New"
    skills << "New"
    @level_list = levels
    @move_list = skills
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
    update_combo(2, form_index)
    build_lists
    update_list(2, 0)
    update_list(3, 0)
    _on_level_change(0, nil)
    @object.id = @pokemon_id
    @object.form = form_index
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
    Pokemon_Skill_Dialog.new(App::Dialogs[:atk_pk], hwnd) do |instance| 
      @instance = instance
      instance.pokemon_id = pokemon_id
      instance._pokemon_list = pokemon_list
    end
    @instance.clean_pokemon_moves
  end
  
  def sort_pokemon_moves(moveset)
    arr=Array.new(moveset.size/2) do |i| i end
    new_set=Array.new
    if(@sort_type != :name)
      arr.sort! do |a,b|
        moveset[a*2] <=> moveset[b*2]
      end
    else
      arr.sort! do |a,b|
        GameData::Text.get(6,moveset[a*2+1]) <=> GameData::Text.get(6,moveset[b*2+1])
      end
    end
    arr.each do |i|
      new_set<<moveset[i*2]
      new_set<<moveset[i*2+1]
    end
    new_set.each_index do |i|
      moveset[i]=new_set[i]
    end
  end
  
  #===
  #>Nettoyage des tables de moveset des Pokémon
  #===
  def clean_pokemon_moves
    i = nil
    pkmn = nil
    1.upto($game_data_pokemon.size-1) do |i|
      $game_data_pokemon[i].each do |pkmn|
        next unless pkmn
        moveset=pkmn.move_set
        arr_level=Array.new(moveset.size/2) do |i| i end
        arr_level.sort! do |a,b|
          moveset[a*2] <=> moveset[b*2]
        end
        new_set=Array.new
        arr_level.each do |i|
          new_set<<moveset[i*2]
          new_set<<moveset[i*2+1]
        end
        pkmn.move_set=new_set
      end
    end
  end
end