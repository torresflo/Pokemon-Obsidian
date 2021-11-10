#encoding: utf-8
class DialogHost
  public
  def get_file_name(filename)
    App::get_file_name(filename)
  end
  
  def open_file_dialog(ext_descr, ext_name, force_dir = nil)
    image_file = DialogInterface::OpenFileDialog(sprintf(OpenFileDialog_Descr, ext_descr, ext_name), @hwnd)
    if(image_file)
      image_file.force_encoding(UTF_8)
	  image_file.downcase!
      if(!force_dir or image_file.gsub!(get_file_name(force_dir).downcase, Empty_String))
        image_file.strip!
        image_file.gsub!(ext_name, Empty_String)
        return image_file
      else
        #> Alerter ou non le fait que le repertoire n'est pas le bon
      end
    end
    return nil
  end
  
  def msgbox(text, title, flag = DialogInterface::Constants::MB_ICONASTERISK)
    DialogInterface::MessageBox(@hwnd, text, title, flag)
  end
  
  def confirm(text, title)
    msgbox(text, title, 
      DialogInterface::Constants::MB_YESNO | 
      DialogInterface::Constants::MB_DEFBUTTON2 |
      DialogInterface::Constants::MB_ICONASTERISK ) == DialogInterface::Constants::IDYES
  end
  
  def check_update_data
    current_time = (Time.new - BASE_TIME).to_i
    if(current_time - @last_time > 2)
      update_data
    end
    @last_time = current_time
  end
  
  def check_text_before_adding(max, lang_id, *texts)
    texts.each do |text_id|
      return false if GameData::Text.get_text_file(lang_id, text_id).size <= max
    end
    return true
  end
  
  def get_edit_value(index, type = :text)
    id = App::Edit[index]
    case type
    when :text
      field = @fields.fetch(id, nil)
      return @dlg.get_item_text(id, field ? 1024 : field.fetch(:text_size)).strip
    when :signed
      return @dlg.get_item_int(id, true)
    when :unsigned
      return @dlg.get_item_int(id, false)
    end
    return 0
  end
end