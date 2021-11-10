#encoding: utf-8
class DialogHost
  public
  def update_dialog
    dialog = @dlg
    @fields.each do |id, field|
      type = field.fetch(:type)
      case type
      when :list
        dialog.set_list_pos(id, public_send(field.fetch(:getter)), true)
      when :combo
        dialog.set_combo_pos(id, public_send(field.fetch(:getter)), true)
      when :text
        dialog.set_item_text(id, ivar_get(field.fetch(:ivar)).to_s)
        dialog.set_item_text_limit(id, field.fetch(:text_size))
      when :text_view
        dialog.set_item_text(id, public_send(field.fetch(:getter)).to_s)
      when :signed
        dialog.set_item_int(id, ivar_get(field.fetch(:ivar)).to_i, true)
      when :unsigned
        dialog.set_item_int(id, ivar_get(field.fetch(:ivar)).to_i, false)
      when :checkbox
        dialog.set_check_state(id, ivar_get(field.fetch(:ivar)), true)
      when :image
        load_image(dialog, id, field)
      end
    end
  end
  
  def update_data
    dialog = @dlg
    @fields.each do |id, field|
      type = field.fetch(:type)
      case type
      when :list
        value = dialog.get_list_pos(id)
        public_send(field.fetch(:setter), value, field.fetch(:list_data)[value])
      when :combo
        value = dialog.get_combo_pos(id)
        public_send(field.fetch(:setter), value, field.fetch(:list_data)[value])
      when :text
        value = dialog.get_item_text(id, field.fetch(:text_size)).to_s
        value.force_encoding(UTF_8)
        check = field.fetch(:text_check)
        value = public_send(check, value) if check
        ivar_set(field.fetch(:ivar), value)
      when :signed
        value = normalize_value(dialog.get_item_int(id, true), field)
        ivar_set(field.fetch(:ivar), value)
      when :unsigned
        value = normalize_value(dialog.get_item_int(id, false), field)
        ivar_set(field.fetch(:ivar), value)
      when :checkbox
        ivar_set(field.fetch(:ivar), dialog.get_check_state(id))
      end
    end
  end
  
  def update_combo(index, position, update_dlg = false, update_list = true)
    id = App::Combo[index]
    combo = @combos[id]
    check_update_data if update_dlg
    combo[:last_index] = position
    if(update_list)
      list_data = combo.fetch(:list_data_callback)
      if list_data
        list_data = public_send(list_data)
        @dlg.public_send(combo.fetch(:set_list_method), id, list_data) if combo[:list_data] != list_data
        combo[:list_data] = list_data
      end
    end
    @dlg.set_combo_pos(id, position, true)
    update_dialog if update_dlg
  end
  
  def update_list(index, position, update_dlg = false, update_list = true)
    id = App::List[index]
    combo = @combos[id]
    check_update_data if update_dlg
    combo[:last_index] = position
    if(update_list)
      list_data = combo.fetch(:list_data_callback)
      if list_data
        list_data = public_send(list_data)
        @dlg.public_send(combo.fetch(:set_list_method), id, list_data) if combo[:list_data] != list_data
        combo[:list_data] = list_data
      end
    end
    @dlg.set_list_pos(id, position, true)
    update_dialog if update_dlg
  end
  
  def update_text(index, text)
    @dlg.set_item_text(App::Edit[index], text)
  end
  
  def update_signed_int(index, value)
    @dlg.set_item_int(App::Edit[index], value, true)
  end
  
  def update_unsigned_int(index, value)
    @dlg.set_item_int(App::Edit[index], value, false)
  end
  
  private
  def ivar_get(ivar)
    if(ivar.is_a?(Symbol))
      @object.instance_variable_get(ivar)
    else
      public_send(ivar.fetch(:getter))
    end
  end
  
  def ivar_set(ivar, value)
    if(ivar.is_a?(Symbol))
      @object.instance_variable_set(ivar, value)
    else
      public_send(ivar.fetch(:setter), value)
    end
  end
  
  def normalize_value(value, field)
    min = field.fetch(:min)
    value = min if value < min
    max = field.fetch(:max)
    value = max if value > max
    return value
  end
  
  def load_image(dlg, id, field)
    filename = public_send(field.fetch(:loader))
    if(File.exist?(filename))
      bmp = DialogInterface::LoadImage(filename)
      if(bmp)
        dlg.set_image(id, bmp, field.fetch(:current_bitmap))
        field[:current_bitmap] = bmp
      else
        DialogInterface::MessageBox(0,"Impossible de charger l'image. Vérifiez les permissions.","DialogHost#load_image",DialogInterface::Constants::MB_ICONERROR)
      end
    end
  end
end