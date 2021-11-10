#encoding: utf-8
class DialogHost
  SEL_CHANGE = 1
  PRESS_BUTTON = 0
  BASE_TIME = (Time.new - 5).to_i
  OpenFileDialog_Descr = "%s\x00*%s\x00"
  Empty_String = ""
  UTF_8 = "UTF-8"
  
  attr_reader :locked, :dlg
  def initialize(dialog_id, parent_hwnd = 0, call_method = DialogInterface.method(:DialogBox))
    @locked = true
    @combos = {} #> Liste des descriptions des différentes liste ou combobox
    @buttons = {} #> Liste des descriptions des différents boutons
    @fields = {} #> Liste des descriptions des différents champs
    @object = nil #> Objet manipulé
    call_method.call(dialog_id, parent_hwnd) do |dialog|
      @hwnd = dialog.hwnd
      @dlg = dialog
      yield(self) if block_given?
      init_dialog(dialog)
      @locked = false
    end
  end
  
  public
  def combo_list_sel_change(id)
    return false unless combo = @combos.fetch(id, nil)
    @locked = true
    last_index = combo.fetch(:last_index)
    current_index = @dlg.public_send(combo.fetch(:get_pos_method), id)
    if last_index != current_index
      return_value = public_send(combo.fetch(:on_change_method), current_index, combo.fetch(:list_data)[current_index])
      update_dialog if return_value == :update_dialog
      combo[:last_index] = current_index
    end
    @locked = false
  end
  
  def button_press(id)
    return unless button = @buttons.fetch(id, nil)
    @locked = true
    return_value = public_send(button.fetch(:callback_method))
    update_dialog if return_value == :update_dialog
    @locked = false
  end
  
  def spin_notify(id, lParam)
    return unless @spins
    return false unless spin = @spins.fetch(id, nil)
    delta = -@dlg.get_delta_from_lParam(lParam)
	  return if delta == 0
    @locked = true
    return_value = public_send(spin.fetch(:on_change_method), delta)
    update_dialog if return_value == :update_dialog
    @locked = false
  end
  
  def set_forground
    DialogInterface::SetForgroundWindow(@hwnd)
  end
  
  def closed?
    @dlg.closed
  end
  
  private
  def init_dialog(dialog)
    def dialog.on_command(hDlg, wmId, wmEvent, lParam)
      return if @host.locked
      case wmEvent
      when SEL_CHANGE
        @host.combo_list_sel_change(wmId)
      when PRESS_BUTTON
        @host.button_press(wmId)
      end
    end
    
    def dialog.on_notify(hDlg, wmId, wmEvent, lParam)
      return if @host.locked
      @host.spin_notify(wmId, lParam)
    end
    
    dialog.instance_variable_set(:@host, self)
    init_data(dialog)
  end
  
  def init_data(dialog)
    @last_time = (Time.new - BASE_TIME).to_i
    @combos.each do |id, combo|
      dialog.public_send(combo.fetch(:set_list_method), id, list_data = combo.fetch(:list_data))
      initial_index = combo.fetch(:initial_index)
      dialog.public_send(combo.fetch(:set_pos_method), id, initial_index, true)
      public_send(combo.fetch(:on_change_method), initial_index, list_data[initial_index])
    end
    @fields.each do |id, field|
      type = field.fetch(:type)
      case type
      when :list
        dialog.set_list_list(id, list_data = field.fetch(:list_data))
      when :combo
        dialog.set_combo_list(id, list_data = field.fetch(:list_data))
      end
    end
    update_dialog
  end
end