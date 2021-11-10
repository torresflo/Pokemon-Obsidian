#encoding: utf-8
class Item_Dialog < DialogHost
  BAG_SOCKET = ["0 - Any", "1 - Items", "2 - Pokéballs", "3 - TM/HMs", "4 - Berries", "5 - Key Items", "6 - Medicine"]
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  ICON_PATH = "Graphics\\Icons\\"
  ICON_EXT = ".png"
  EXT_DESCR = "Image PNG"
  DATA_FILE = "Data/PSDK/ItemData.rxdata"
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    define_combo_controler(1, :_on_item_change, :_item_list)
    define_text_view(1, :_get_item_name)
    define_text_view(2, :_get_item_descr)
    define_text_control(3, :@icon, 64)
    define_unsigned_int(4, :@price, 0, 9_000_000)
    define_combo(2, BAG_SOCKET, :_get_item_socket, :_set_item_socket)
    define_signed_int(5, :@position, -9_000_000, 9_000_000)
    define_unsigned_int(6, :@fling_power, 0, 9_000_000)
    define_checkbox(1, :@battle_usable)
    define_checkbox(2, :@map_usable)
    define_checkbox(3, :@limited)
    define_checkbox(5, :@holdable)
    define_image(1, :_icon_filename, :_change_icon)
    define_button(1, :_edit_item_name)
    define_button(2, :_edit_item_descr)
    define_button(3, :_open_item_heal_dlg)
    define_button(4, :_open_item_ball_dlg)
    define_button(5, :_open_item_misc_dlg)
    define_button(6, :_save)
    define_button(7, :update_dialog)
    define_button(8, :_add)
    define_button(9, :_del)
    super
  end
  
  public
  def self.instanciate
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    Item_Dialog.new(App::Dialogs[:objets], 0) { |instance| @instance = instance}
  end
  
  def _get_item_name
    GameData::Text._get(@lang_id, 12, @item_id)
  end
  
  def _get_item_descr
    GameData::Text._get(@lang_id, 13, @item_id)
  end
  
  def _get_item_socket
    @object.socket
  end
  
  def _set_item_socket(index, text)
    @object.socket = text.to_i
  end
  
  def _on_item_change(index, text)
    id = text.split(TEXT_SPLIT).last.to_i
    id = 1 if(id < 1 or id >= $game_data_item.size)
    check_update_data
    @object = $game_data_item[id]
    $game_data_item[id].id = id
    @item_id = id
    return :update_dialog
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
  
  def _icon_filename
    get_file_name("#{ICON_PATH}#{@object.icon}#{ICON_EXT}")
  end
  
  def _change_icon
    filename = open_file_dialog(EXT_DESCR, ICON_EXT, ICON_PATH)
    if(filename)
      check_update_data
      @object.icon = filename
      @last_time -= 2
      return :update_dialog
    end
  end
  
  def _edit_item_name
    Text_Dialog.instanciate(@item_id, 12, @hwnd)
    return :update_dialog
  end
  
  def _edit_item_descr
    Text_Dialog.instanciate(@item_id, 13, @hwnd)
    return :update_dialog
  end
  
  def _open_item_heal_dlg
    ItemHeal_Dialog.instanciate(@item_id, @hwnd)
  end
  
  def _open_item_ball_dlg
    ItemBall_Dialog.instanciate(@item_id, @hwnd)
  end
  
  def _open_item_misc_dlg
    ItemMisc_Dialog.instanciate(@item_id, @hwnd, _item_list)
  end
  
  def _save
    check_update_data
    App.save_data($game_data_item, get_file_name(DATA_FILE))
  end
  
  def _add
    if(check_text_before_adding(size = $game_data_item.size, @lang_id, 12, 13))
      check_update_data
      @object = obj = GameData::Item.new
      @item_id = size
      define_basic_object(obj)
      obj.id = $game_data_item.size
      $game_data_item << obj
      list = _item_list
      position = list.index(sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 12, size), size)).to_i
      update_combo(1, position, true)
    else
      msgbox("There is not enough text to add a new item, make sure to add a name and description.", self.class.to_s)
    end
  end
  
  def _del
    if(confirm("Deleting an item can cause bugs in your game.\nAre you sure you want to delete this item?", self.class.to_s))
      if @item_id == ($game_data_item.size-1) and @item_id > 1
        $game_data_item.pop
        text = _item_list.last
        id = text.split(TEXT_SPLIT).last.to_i
        id = 1 if(id < 1 or id >= $game_data_item.size)
        @object = $game_data_item[@item_id = id]
        update_combo(1, $game_data_item.size - 2)
      else
        msgbox("L'objet sera vidé.", self.class.to_s)
        @object = obj = GameData::Item.new
        define_basic_object(obj)
        $game_data_item[@item_id] = obj
      end
      return :update_dialog
    end
  end
  
  def define_basic_object(obj)
    obj.icon = "return"
    obj.price = obj.position = obj.fling_power = 0
    obj.socket = 1
    obj.battle_usable = false
    obj.map_usable = obj.limited = obj.holdable = true
  end
end