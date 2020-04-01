#encoding: utf-8
class Text_Dialog < DialogHost
  TEXT_LIST = ["0 - Nom des Pokémon", "1 - Espèces des Pokémon", "2 - Description des Pokémon",
"3 - Types","4 - Nom des talents","5 - Description des talents","6 - Nom des attaques",
"7 - Description des attaques", "8 - Nom des natures","9 - Régions","10 - Nom des lieux",
"11 - Magasin","12 - Nom des objets","13 - Description des objets",
"14 - Menu Principal","15 - Poches du sac","16 - Nom des boites","17 - Messages évent communs",
"18 - String combat","19 - String combat","20 - String combat (menu)","21 - Utilisation attaque",
"22 - Sac", "23 - Equipe", "24 - Apprentissage","25 - Chargement","26 - Sauvegarde","27 - Résumé Pokémon",
"28 - Résumé informations","29 - Classes des dresseurs", "30 - Capture d'un Pokémon", 
"31 - Evolution",  "32 - Autres chaine combat",  "33 - Gestion boîte",  "34 - CDD",  "35 - Centre Pokémon",
"36 - Pension Pokémon", "37 - Textes de CS", "38 - Plantation Baies", "39 - Textes IN MAP","40 - Nom des baies", 
"41 - Obtension de choses", "42 - Options", "43 - Message Nommage", "44 - Rubans", "45 - Nom Quêtes", "46 - Description Quêtes",
"47 - Phrase de victoire", "48 - Phrase de défaite"]
  
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
    if(confirm("Êtes-vous sûr de vouloir remettre les textes à zéro ?", self.class.to_s))
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