#encoding: utf-8
class DialogHost
  public
  def define_spin_controler(index, on_change)
    @spins = {} unless @spins
    @spins[App::Spin[index]] = {
      on_change_method: on_change
    }
  end
  
  def define_list_controler(index, on_change, list_data, initial_index = 0)
    list_data_callback, list_data = get_list_data_var(list_data)
    @combos[App::List[index]] = {
      on_change_method: on_change,
      last_index: 0,
      list_data: list_data,
      list_data_callback: list_data_callback,
      get_pos_method: :get_list_pos,
      set_pos_method: :set_list_pos,
      set_list_method: :set_list_list,
      initial_index: initial_index
    }
  end
  
  def define_combo_controler(index, on_change, list_data, initial_index = 0)
    list_data_callback, list_data = get_list_data_var(list_data)
    @combos[App::Combo[index]] = {
      on_change_method: on_change,
      last_index: 0,
      list_data: list_data,
      list_data_callback: list_data_callback,
      get_pos_method: :get_combo_pos,
      set_pos_method: :set_combo_pos,
      set_list_method: :set_combo_list,
      initial_index: initial_index
    }
  end
  
  def define_list(index, list_data, getter, setter)
    list_data_callback, list_data = get_list_data_var(list_data)
    @fields[App::List[index]] = {
      type: :list,
      list_data: list_data,
      list_data_callback: list_data_callback,
      getter: getter,
      setter: setter
    }
  end
  
  def define_combo(index, list_data, getter, setter)
    list_data_callback, list_data = get_list_data_var(list_data)
    @fields[App::Combo[index]] = {
      type: :combo,
      list_data: list_data,
      list_data_callback: list_data_callback,
      getter: getter,
      setter: setter
    }
  end
  
  def define_button(index, callback)
    @buttons[App::Button[index]] = {
      callback_method: callback
    }
  end
  
  def define_image(index, loader, selector = nil)
    @fields[id = App::Images[index]] = {
      type: :image,
      loader: loader,
      current_bitmap: nil
    }
    return unless selector
    @buttons[id] = {
      callback_method: selector
    }
  end
  
  def define_text_view(index, getter)
    @fields[App::Edit[index]] = {
      type: :text_view,
      getter: getter
    }
  end
  
  def define_text_control(index, instance_variable, text_size, text_check_sym = nil)
    @fields[App::Edit[index]] = {
      type: :text,
      ivar: instance_variable,
      text_check: text_check_sym,
      text_size: text_size,
    }
  end
  
  def define_signed_int(index, instance_variable, min, max)
    @fields[App::Edit[index]] = {
      type: :signed,
      ivar: instance_variable,
      min: min,
      max: max
    }
  end
  
  def define_unsigned_int(index, instance_variable, min, max)
    @fields[App::Edit[index]] = {
      type: :unsigned,
      ivar: instance_variable,
      min: min,
      max: max
    }
  end
  
  def define_checkbox(index, instance_variable)
    @fields[App::Check[index]] = {
      type: :checkbox,
      ivar: instance_variable
    }
  end
  
  private
  def get_list_data_var(list_data)
    if list_data.is_a?(Symbol)
      return list_data, public_send(list_data)
    else
      return nil, list_data
    end
  end
end