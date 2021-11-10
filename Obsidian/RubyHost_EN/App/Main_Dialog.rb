#encoding: utf-8
class Main_Dialog < DialogHost
  include DialogInterface
  include DialogInterface::Constants
  OpenProjectSTR = "Open a Project !"
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    define_text_view(1, :_get_dir)
    define_button(1, :_open_project)
    define_button(2, :_edit_pokemon)
    define_button(3, :_edit_atk)
    define_button(4, :_edit_item)
    define_button(5, :_edit_zone)
    define_button(6, :_edit_ability)
    define_button(7, :_edit_text)
    define_button(8, :_edit_messages)
    define_button(9, :_edit_types)
    define_button(10, :_test_game)
    define_button(11, :_edit_trainers)
    define_button(12, :_edit_groups)
    define_button(13, :_edit_maplinks)
    define_button(14, :_edit_quests)
    init_on_close(dialog)
    App.load_self_conf
    super
  end
  
  def init_on_close(dialog)
    def dialog.on_close(hDlg)
      if(App.warn?)
        if MessageBox(
              hDlg,
              "Are you sure you want to close the editor?",
              "Close the editor",
              MB_YESNO | MB_DEFBUTTON2 | MB_ICONASTERISK
            ) == IDNO
          return 412 
        end
      end
      PostQuitMessage(0)
      return true
    end
  end
  
  public
  def self.instanciate
    Main_Dialog.new(App::Dialogs[:main], 0, DialogInterface.method(:CreateDialog))
  end
  
  # def button_press(wmId)
    # super unless @wait
  # end
  
  def _edit_pokemon
    @locked = false
    Pokemon_Dialog.instanciate if @valid
  end
  
  def _edit_atk
    @locked = false
    Skill_Dialog.instanciate if @valid
  end
  
  def _edit_item
    @locked = false
    Item_Dialog.instanciate if @valid
  end
  
  def _edit_zone
    @locked = false
    Zone_Dialog.instanciate if @valid
  end
  
  def _edit_text
    @locked = false
    Text_Dialog.instanciate if @valid
  end
  
  def _edit_messages
    @locked = false
  
  end
  
  def _edit_types
    @locked = false
    Type_Dialog.instanciate if @valid
  end
  
  def _test_game
    @locked = false
  
  end
  
  def _edit_trainers
    @locked = false
    Trainer_Dialog.instanciate if @valid
  end
  
  def _edit_maplinks
    @locked = false
    MapLinks_Dialog.instanciate if @valid
  end
  
  def _edit_quests
    @locked = false
    Quest_Dialog.instanciate if @valid
  end
  
  def _edit_groups
    @locked = false
    Groupe_Dialog.instanciate if @valid
  end
  
  def _get_dir
    dir = App.get_dir
    unless dir
      @valid = false
      return OpenProjectSTR
    else
      @valid = true
      unless(true or Normalize_Dialog.check_normalized)
        Normalize_Dialog.instanciate(@hwnd, [:data_backup])
      end
      return dir
    end
  end
  
  def _edit_ability
    return unless @valid
    texts = GameData::Text.get_text_file(App.lang_id,4)
    if($game_data_abilities.size < (texts.size - 1) && texts.size <= GameData::Text.get_text_file(App.lang_id,5).size)
      base = $game_data_abilities.size
      (texts.size - 1 - base).times do |i|
        base+=1
        $game_data_abilities<<base
      end
      msgbox("Les talents ont été rafraichis et sauvegardés (par rapport aux textes).", "Information")
      App.save_data($game_data_abilities, get_file_name("Data/PSDK/Abilities.rxdata"))
    else
      msgbox("The abilities are up to date.", "Information")
    end
  end
  
  def _open_project
    #>On vérifie si ça a pas déjà été chargé
    if(App.get_dir)
      if(!confirm("Are you sure you want to change the Project Data's destination?","Change the folder"))
        return false
      end
    end
    #>Sinon on demande l'ouverture d'un fichier .rxdata du dossier
    script_file = open_file_dialog("Projet RPG Maker XP",".rxproj")
    if(script_file)
      arr = script_file.split("\\")
      arr.pop
      App.set_dir(arr.join("/") + "/Data/")
      return :update_dialog
    end
  end
end