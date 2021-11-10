#encoding: utf-8
class Text_Dialog < DialogHost
  TEXT_LIST = ["0 - Pokémon Name", "1 - Pokémon Species", "2 - Pokémon Description",
"3 - Types","4 - Ability Names","5 - Ability Descriptions","6 - Attack Names",
"7 - Attack Descriptions", "8 - Nature Names","9 - Regions","10 - Name of Places",
"11 - Mart","12 - Item Names","13 - Item Descriptions",
"14 - Menu","15 - Bag Pockets","16 - Box Names","17 - Common Event Messages",
"18 - Battle Text","19 - Battle Text","20 - Battle Text (menu)","21 - Use Attack",
"22 - Bag", "23 - Party/Team", "24 - Learning New Move","25 - Loading Menu","26 - Saving Menu","27 - Pokémon Summary",
"28 - Summary Info","29 - Trainer Classes", "30 - Caught Pokémon", 
"31 - Evolution",  "32 - Other Battle Text",  "33 - Box Options",  "34 - Trainer Card (CDD)",  "35 - Pokémon Center",
"36 - Pokémon Day Care", "37 - HM/TM Text", "38 - Berry Text", "39 - Overworld Text","40 - Berry Names", 
"41 - Obtaining Text", "42 - Options", "43 - Naming Messages", "44 - Ribbons", "45 - Quest Names", "46 - Quest Descriptions",
"47 - Victory Text", "48 - Defeat Text"]
  
  attr_accessor :file_id, :text_id
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @file_id = 0 unless @file_id
    @text_id = 0 unless @text_id
    @files = Array.new(GameData::Text::Available_Langs.size)
    _get_files
    define_combo_controler(1, :_on_text_file_change, TEXT_LIST, @file_id)
    define_text_view(1, :_get_text_id)
    define_text_view(2, :_get_max_text_id)
    define_text_control(3, {getter: :_get_jap_line, setter: :_set_jap_line}, 4096)
    define_text_control(4, {getter: :_get_english_line, setter: :_set_english_line}, 4096)
    define_text_control(5, {getter: :_get_french_line, setter: :_set_french_line}, 4096)
    define_text_control(6, {getter: :_get_italian_line, setter: :_set_italian_line}, 4096)
    define_text_control(7, {getter: :_get_deutsch_line, setter: :_set_deutsch_line}, 4096)
    define_text_control(8, {getter: :_get_español_line, setter: :_set_español_line}, 4096)
    define_text_control(9, {getter: :_get_korean_line, setter: :_set_korean_line}, 4096)
    define_spin_controler(1, :_change_text_id)
    define_button(1, :_add_text)
    define_button(2, :_remove_text)
    define_button(3, :_save_text)
    define_button(4, :_reload_text)
    define_button(5, :check_update_data)
    define_button(6, :_goto_text_id)
    #> Faire usage des update_unsigned_int etc... pour la mise à jour des text, il y a aussi l'aspect setter/getter des ivar
    super
  end
  
  public
  def self.instanciate(text_id = nil, file_id = nil, hwnd = nil)
    if !hwnd and @instance and !@instance.closed?
      return @instance.set_forground
    end
    Text_Dialog.new(App::Dialogs[:text], hwnd.to_i) do |instance| 
      if hwnd
        instance.file_id = file_id
        instance.text_id = text_id
      else
        @instance = instance
      end
    end
  end
  
  def _reload_text
    if(confirm("Are you sure you want to reload the text?", self.class.to_s))
      GameData::Text.load_all
      _get_files
      max = _get_max_text_id
      @text_id = max if @text_id > max
      return :update_dialog
    end
  end
  
  def _save_text
    check_update_data
    GameData::Text.save_all
  end
  
  def _add_text
    @files.each { |file| file << "NewText"}
    check_update_data
    @text_id = _get_max_text_id
    return :update_dialog
  end
  
  def _remove_text
    if(confirm("Toute suppression peut entrainer des bugs dans le jeu.\nVoulez-vous vraiment supprimer ce texte ?", self.class.to_s))
      text_id = @text_id
      if text_id != _get_max_text_id or text_id == 0
        msgbox("Le texte sera vidé.", self.class.to_s)
        @files.each { |file| file[text_id].clear }
      else
        @files.each { |file| file.pop }
        @text_id -= 1
      end
      return :update_dialog
    end
  end
  
  def _change_text_id(delta)
    return if delta > 0 and @text_id >= _get_max_text_id
    return if delta < 0 and @text_id <= 0
    check_update_data
    @text_id += delta
    update_unsigned_int(1, @text_id)
    return :update_dialog
  end
  
  def _goto_text_id
    id = get_edit_value(1, :unsigned)
    id = 0 if id <= 0
    max = _get_max_text_id
    id = max if id > max
    if(@text_id != id)
      check_update_data
      @text_id = id
      return :update_dialog
    end
  end
  
  def _get_korean_line
    @files[6][@text_id]
  end
  
  def _set_korean_line(value)
    @files[6][@text_id] = value
  end
  
  def _get_español_line
    @files[5][@text_id]
  end
  
  def _set_español_line(value)
    @files[5][@text_id] = value
  end
  
  def _get_deutsch_line
    @files[4][@text_id]
  end
  
  def _set_deutsch_line(value)
    @files[4][@text_id] = value
  end
  
  def _get_italian_line
    @files[3][@text_id]
  end
  
  def _set_italian_line(value)
    @files[3][@text_id] = value
  end
  
  def _get_french_line
    @files[2][@text_id]
  end
  
  def _set_french_line(value)
    @files[2][@text_id] = value
  end
  
  def _get_english_line
    @files[1][@text_id]
  end
  
  def _set_english_line(value)
    @files[1][@text_id] = value
  end
  
  def _get_jap_line
    @files[0][@text_id]
  end
  
  def _set_jap_line(value)
    @files[0][@text_id] = value
  end
  
  def _on_text_file_change(index, text)
    return if(TEXT_LIST.size <= index)
    check_update_data
    @file_id = index
    _get_files
    max = _get_max_text_id
    @text_id = max if @text_id > max
    return :update_dialog
  end
  
  def _get_files
    @files.size.times do |i|
      @files[i] = GameData::Text.get_text_file(i, @file_id)
    end
  end
  
  def _get_max_text_id
    @files[0].size - 1
  end
  
  def _get_text_id
    @text_id
  end
end