#encoding: utf-8
class ItemBall_Dialog < DialogHost
  TEXT_FORMAT = "%s (%03d)"
  TEXT_SPLIT = "("
  States = [nil,[1],[2],[3],[4],[5],[6],[7],[8],[9],[1,8],[1,2,3,4,5,6,7,8]]
	StatesNames = ["Aucune","1 - Poison","2 - Paralysie","3 - Brûlure","4 - Sommeil","5 - Gel","6 - Confusion","7 - ???","8 - Toxique","9 - K.O.","Empoisonnement","Tous (mort/K.O. exclu)"]
	EVS = ["Rien","HP +10 (0)","ATK +10 (1)","DFE +10 (2)","SPD +10 (3)","ATS +10 (4)","DFS +10 (5)","HP +1 (10)","ATK +1 (11)","DFE +1 (12)","SPD +1 (13)","ATS +1 (14)","DFS +1 (15)"]
	Battle = ["Aucun","Attaque (0)","Défense (1)","Vitesse (2)","Attaque spé (3)","Défense spé (4)","Esquive (5)","Précision (6)"]
	PP = ["Rien", "+1","Max"]
  attr_accessor :item_id
  private
  #===
  #> Définition des champs du Dialog
  #===
  def init_data(dialog)
    @lang_id = App.lang_id
    @object = $game_data_item[@item_id].ball_data
    @object = GameData::BallData.new unless @object
    @object.id = @item_id
    @original_item = @object
    @object = Marshal.load(Marshal.dump(@object))
    define_text_view(1, :_get_item_name)
    define_text_control(2, :@img, 512)
    define_text_control(3, :@catch_rate, 64, :_float_value)
    define_text_control(5, {getter: :_get_special_catch, setter: :_set_special_catch}, 4096)
    define_button(1, :_validate)
    define_button(2, :_reset)
    super
  end
  
  public
  def self.instanciate(item_id, hwnd)
    if @instance and !@instance.closed?
      return @instance.set_forground
    end
    ItemBall_Dialog.new(App::Dialogs[:item_ball], hwnd) { |instance| @instance = instance ; instance.item_id = item_id }
  end
  
  def _validate
    check_update_data
    o = @object
    if(!o.img or o.img.size == 0 or (o.catch_rate == 0 and !o.special_catch))
      $game_data_item[@item_id].ball_data = nil
    else
      $game_data_item[@item_id].ball_data = @object
    end
    return :update_dialog
  end
  
  def _reset
    @object = Marshal.load(Marshal.dump(@original_item))
    return :update_dialog
  end
  
  def _get_item_name
    sprintf(TEXT_FORMAT, GameData::Text._get(@lang_id, 12, @item_id), @item_id)
  end
  
  def _float_value(value)
    value = value.to_f
    return 0 if value < 0
    return value.to_i if value.to_i == value
    value
  end
  
  def _get_special_catch
    if(@object.special_catch.class == Hash)
      @object.special_catch.inspect.gsub(/\:([^=]+)\=\>/) do "\r\n  #$1: " end.gsub("}","\r\n}")
    else
      return ""
    end
  end
  
  def _set_special_catch(value)
    value = eval(value)
    if(value.class == Hash)
      @object.special_catch = value
    else
      @object.special_catch = nil
    end
  end
end