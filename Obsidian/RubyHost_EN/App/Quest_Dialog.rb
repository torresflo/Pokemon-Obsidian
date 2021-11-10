#encoding: utf-8
class Quest_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  TEXT_SPLIT2 = ">"
  TEXT_SPLIT3 = " "
  DATA_FILE = "Data/PSDK/Quests.rxdata"
  
  Objectifs = ["Speak to an NPC", "Beat an NPC", "Find an Item", "Find a Pokémon", "Beat a Pokémon", "Capture a Pokémon", "Obtain an Egg", "Hatch an Egg"]
  Recompenses = ["Money", "Item"]
  attr_reader :objective_list, :earning_list
  attr_accessor :details, :name, :amount
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    @quest_id = 0
    @object = $game_data_quest[0]
    define_combo_controler(1, :_on_quest_change, :_quest_list)
    define_combo_controler(2, :_on_objective_type_change, Objectifs)
    define_combo_controler(5, :_on_earning_type_change, Recompenses)
    define_combo_controler(3, :_on_item_change, :_item_list)
    define_combo_controler(4, :_on_pokemon_change, :_pokemon_list)
    build_lists
    define_list_controler(1, :_on_objective_change, :objective_list)
    define_list_controler(2, :_on_earning_change, :earning_list)
    define_checkbox(1, :@primary)
    @details = ""
    @name = "Jean"
    @amount = 1
    @objective_list_index = 0
    define_unsigned_int(1, {getter: :amount, setter: :amount=}, 1, 999_999_999)
    define_text_control(2, {getter: :details, setter: :details=}, 4096)
    define_text_control(3, {getter: :name, setter: :name=}, 512)
    define_text_view(4, :_get_descr)
    define_button(1, :_add_objective)
    define_button(2, :_del_objective)
    define_button(3, :_add_earning)
    define_button(4, :_del_earning)
    define_button(5, :_edit_quest_descr)
    define_button(6, :_add_quest)
    define_button(7, :_del_quest)
    define_button(8, :_save)
    
    super
  end
  public
  def _add_earning
    check_update_data
    case @earning_type
    when 0 #> Argent
      @object.earnings << {money: @amount}
    when 1 #> Objet
      @object.earnings << {item: @item_id, item_amount: @amount}
    end
    build_earnings
    @earning_index -= 1 while @earning_index >= @earning_list.size
    update_list(2, @earning_index)
    return :update_dialog
  end
  
  def _del_earning
    check_update_data
    @object.earnings.delete_at(@earning_index)
    build_earnings
    @earning_index -= 1 while @earning_index >= @earning_list.size
    update_list(2, @earning_index)
    return :update_dialog
  end
  
  def _add_objective
    check_update_data
    case @objective_type
    when 0 #> Parler à un PNJ
      @object.speak_to ||= []
      @object.speak_to << @name
    when 1 #> Battre un PNJ
      @object.beat_npc ||= []
      @object.beat_npc << @name
      @object.beat_npc_amount ||= []
      @object.beat_npc_amount << @amount
    when 2 #> Trouver un objet
      @object.items ||= []
      @object.items << @item_id
      @object.item_amount ||= []
      @object.item_amount << @amount
    when 3 #> Voir un Pokémon
      @object.see_pokemon ||= []
      @object.see_pokemon << @pokemon_id
    when 4 #> Battre un Pokémon
      @object.beat_pokemon ||= []
      @object.beat_pokemon << @pokemon_id
      @object.beat_pokemon_amount ||= []
      @object.beat_pokemon_amount << @amount
    when 5 #> Capturer un Pokémon
      @object.catch_pokemon ||= []
      details = (@details.size > 2 ? eval(@details) : nil) rescue nil
      @object.catch_pokemon << (details.is_a?(Hash) ? details : @pokemon_id)
      @object.catch_pokemon_amount ||= []
      @object.catch_pokemon_amount << @amount
    when 6 #> Obtenir un oeuf
      @object.get_egg_amount = @amount
    when 7 #> Faire éclore un oeuf
      @object.hatch_egg_amount = @amount
    end
    build_objectives
    @objective_list_index -= 1 while @objective_list_index >= @objective_list.size
    update_list(1, @objective_list_index)
    _on_objective_change(@objective_list_index, @objective_list[@objective_list_index])
    return :update_dialog
  end
  
  ObjectivCat = ["speak", "beat_npc", "items", "see", "beat", "catch", "egg", "hatch"]
  def _del_objective
    return unless @objective_category
    check_update_data
    index = ObjectivCat.index(@objective_category)
    case index
    when 0 #> Parler à un PNJ
      @object.speak_to.delete_at(@objective_index)
      @object.speak_to = nil if @object.speak_to.empty?
    when 1 #> Battre un PNJ
      @object.beat_npc.delete_at(@objective_index)
      @object.beat_npc = nil if @object.beat_npc.empty?
      @object.beat_npc_amount.delete_at(@objective_index)
      @object.beat_npc_amount = nil if @object.beat_npc_amount.empty?
    when 2 #> Trouver un objet
      @object.items.delete_at(@objective_index)
      @object.items = nil if @object.items.empty?
      @object.item_amount.delete_at(@objective_index)
      @object.item_amount = nil if @object.item_amount.empty?
    when 3 #> Voir un Pokémon
      @object.see_pokemon.delete_at(@objective_index)
      @object.see_pokemon = nil if @object.see_pokemon.empty?
    when 4 #> Battre un Pokémon
      @object.beat_pokemon.delete_at(@objective_index)
      @object.beat_pokemon = nil if @object.beat_pokemon.empty?
      @object.beat_pokemon_amount.delete_at(@objective_index)
      @object.beat_pokemon_amount = nil if @object.beat_pokemon_amount.empty?
    when 5 #> Capturer un Pokémon
      @object.catch_pokemon.delete_at(@objective_index)
      @object.catch_pokemon = nil if @object.catch_pokemon.empty?
      @object.catch_pokemon_amount.delete_at(@objective_index)
      @object.catch_pokemon_amount = nil if @object.catch_pokemon_amount.empty?
    when 6 #> Obtenir un oeuf
      @object.get_egg_amount = nil
    when 7 #> Faire éclore un oeuf
      @object.hatch_egg_amount = nil
    end
    build_objectives
    new_index = @objective_list_index
    new_index -= 1 while new_index >= @objective_list.size
    update_list(1, new_index)
    _on_objective_change(new_index, @objective_list[new_index])
    return :update_dialog
  end
  
  def _edit_quest_descr
    Text_Dialog.instanciate(@quest_id, 46, @hwnd)
    return :update_dialog
  end
  
  def _get_descr
    return GameData::Text._get(@lang_id, 46, @quest_id)
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
  
  def _on_item_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_item.size)
    @item_id = id
  end
  
  def _item_list
    if @item_list and (@item_list.size + 1) == $game_data_item.size
      return @item_list
    else
      lang = @lang_id
      @item_list = Array.new($game_data_item.size - 1) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 12, i+1), i+1)
      end
    end
    return @item_list
  end
  
  def _on_objective_type_change(index, text)
    @objective_type = index
  end
  
  def _on_earning_type_change(index, text)
    @earning_type = index
  end
  
  def _on_objective_change(index, text)
    @objective_list_index = index
    return @objective_category = nil unless text
    @objective_category, @objective_index = text.split(TEXT_SPLIT2).last.split(TEXT_SPLIT3)
    @objective_index = @objective_index.to_i
  end
  
  def _on_earning_change(index, text)
    @earning_index = index
  end
  
  def build_lists
    @object.earnings = [] unless @object.earnings
    build_objectives
    build_earnings
  end
  
  def build_earnings
    @earning_list = []
    lang = @lang_id
    @object.earnings.each_with_index do |earning, index|
      if earning[:money]
        @earning_list << "#{earning[:money]} $"
      elsif earning[:item]
        @earning_list << "#{earning[:item_amount]} #{GameData::Text._get(lang, 12, earning[:item])}"
      else
        @earning_list << "???"
      end
    end
  end
  
  def build_objectives
    @objective_list = []
    lang = @lang_id
    if(@object.speak_to)
      @object.speak_to.each_with_index do |name, index|
        @objective_list << "Speak to #{name} > speak #{index}"
      end
    end
    if(@object.beat_npc)
      @object.beat_npc.each_with_index do |name, index|
        @objective_list << "Beat #{name} #{@object.beat_npc_amount[index]} times > beat_npc #{index}"
      end
    end
    if(@object.items)
      @object.items.each_with_index do |item_id, index|
        @objective_list << "Find #{@object.item_amount[index]} #{GameData::Text._get(lang, 12, item_id)} > items #{index}"
      end
    end
    if(@object.see_pokemon)
      @object.see_pokemon.each_with_index do |pokemon_id, index|
        @objective_list << "See #{GameData::Text._get(lang, 0, pokemon_id)} > see #{index}"
      end
    end
    if(@object.beat_pokemon)
      @object.beat_pokemon.each_with_index do |pokemon_id, index|
        @objective_list << "Beat #{@object.beat_pokemon_amount[index]} #{GameData::Text._get(lang, 0, pokemon_id)} > beat #{index}"
      end
    end
    if(@object.catch_pokemon)
      @object.catch_pokemon.each_with_index do |pokemon_id, index|
        name = pokemon_id.is_a?(Integer) ? GameData::Text._get(lang, 0, pokemon_id) : pokemon_id.to_s
        @objective_list << "Catch #{@object.catch_pokemon_amount[index]} #{name} > catch #{index}"
      end
    end
    if(@object.get_egg_amount)
      @objective_list << "Get #{@object.get_egg_amount} eggs > egg 0"
    end
    if(@object.hatch_egg_amount)
      @objective_list << "Hatch #{@object.hatch_egg_amount} eggs > hatch 0"
    end
  end
  
  def _save
    check_update_data
    App.save_data($game_data_quest, get_file_name(DATA_FILE))
  end
  
  def _add_quest
    if(check_text_before_adding(size = $game_data_quest.size, @lang_id, 45, 46))
      check_update_data
      @object = GameData::Quest.new
      @quest_id = size
      $game_data_quest << @object
      build_lists
      update_combo(1, size)
      update_list(1, 0)
      _on_objective_change(0, @objective_list.first)
      update_list(2, 0)
      _on_earning_change(0, nil)
      return :update_dialog
    else
      msgbox("There is either a name, or description text missing for quests.", self.class.to_s)
    end
  end
  
  def _del_quest
    if(confirm("Any deletion can cause bugs in the game.\nAre you sure you want to delete this quest?", self.class.to_s))
      if @quest_id == $game_data_quest.size - 1 and @quest_id > 0
        $game_data_quest.pop
        text = _quest_list.last
        id = text.split(TEXT_SPLIT).last.to_i
        id = 1 if(id < 1 or id >= $game_data_quest.size)
        @object = $game_data_quest[@quest_id = id]
        update_combo(1, $game_data_quest.size - 1)
      else
        msgbox("La quête sera vidée.", self.class.to_s)
        $game_data_quest[@quest_id] = @object = GameData::Quest.new
      end
      build_lists
      update_list(1, 0)
      _on_objective_change(0, @objective_list.first)
      update_list(2, 0)
      _on_earning_change(0, nil)
      return :update_dialog
    end
  end
  
  def _on_quest_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 0 if(id < 0 or id >= $game_data_quest.size)
    check_update_data
    @object = $game_data_quest[id]
    @quest_id = id
    @object.id = id
    build_lists
    update_list(1, 0)
    _on_objective_change(0, @objective_list.first)
    update_list(2, 0)
    _on_earning_change(0, nil)
    return :update_dialog
  end
  
  def _quest_list
    if @quest_list and (@quest_list.size) == $game_data_quest.size
      return @quest_list
    else
      lang = @lang_id
      @quest_list = Array.new($game_data_quest.size) do |i| 
        sprintf(TEXT_FORMAT, GameData::Text._get(lang, 45, i), i)
      end
    end
    return @quest_list
  end
  
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Quest_Dialog.new(App::Dialogs[:quest], 0) do |instance| 
      @instance = instance
      $game_data_quest << GameData::Quest.new if $game_data_quest.size == 0
    end
  end
end