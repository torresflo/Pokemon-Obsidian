#encoding: utf-8

#noyard
module GamePlay
  class Option_Element
    Element_base_x = 13
    Element_base_y = 47
    Surface_Size = [296, 16]
    Option_Name_Surface = [4 + Element_base_x, 0, 136, 16]
    Option_Name_Align_Color = [0, 8]
    Option_Value_Surface = [187 + Element_base_x, 0, 63, 16]
    Option_Value_Align_Color = [1, 0]
    Element_delta_y_line = 19
    Button_Surface = [0, 1, 8, 13]
    Button1_xmax = Option_Value_Surface[0] + Button_Surface[0]
    Button1_xmin = Button1_xmax - Button_Surface[2]
    Button1_ymin = Element_base_y + Button_Surface[1]
    Button1_ymax = Button1_ymin + Button_Surface[3]
    Button2_xmax = Button1_xmax + Option_Value_Surface[2] + Button_Surface[2]
    Button2_xmin = Button1_xmin + Option_Value_Surface[2] + Button_Surface[2]
    Button2_ymin = Button1_ymin
    Button2_ymax = Button1_ymax
    include Text::Util
    #> Explication du contenu de Text Data :
    #  Si le contenu vaut un tableau, c'est une combinaison [file_id, text_id]
    #  Sinon, ça doit être une chaine (options non traduite)
    TextData = 
      {
        message_speed: [42, 3],
        speed_slow: [42, 4],
        speed_medium: [42, 5],
        speed_fast: [42, 6],
        message_speed_descr: [42, 7],
        battle_animation: [42, 8],
        battle_ani_with: [42, 9],
        battle_ani_without: [42, 10],
        battle_ani_descr: [42, 11],
        battle_style: [42, 12],
        battle_style_free: [42, 13],
        battle_style_locked: [42, 14],
        battle_style_descr: [42, 15],
        screen_size: [9000, 27], # "Screen Size",
        screen_size_1: "320x240",
        screen_size_2: "640x480",
        screen_size_descr: [9000, 28], # "Change the game screen resolution.",
        volume: [9000, 29], # "Volume",
        volume_0: "0%",
        volume_25: "25%",
        volume_50: "50%",
        volume_75: "75%",
        volume_100: "100%",
        volume_descr: [9000, 30], # "Change the sound volume."
        message_frame: 'Message Frame',
        message_frame_descr: 'Change the message frame',
        mf_0: 'X/Y',
        mf_1: 'Gold',
        mf_2: 'Silver',
        mf_3: 'Red',
        mf_4: 'Blue',
        mf_5: 'Green',
        mf_6: 'Orange',
        mf_7: 'Purple',
        mf_8: 'Heart Gold',
        mf_9: 'Soul Silver',
        mf_10: 'Rocket',
        mf_11: 'Blue Indus',
        mf_12: 'Red Indus',
        mf_13: 'Swamp',
        mf_14: 'Safari',
        mf_15: 'Brick',
        mf_16: 'Sea',
        mf_17: 'River',
        mf_18: 'B/W'
      }
    TextError = "Text not found"

    attr_reader :description, :value

    def initialize(viewport, value, option_data)
      #super(viewport)
      init_text(0, viewport)
      @values = option_data.fetch(:values)
      @value_index = @values.index(value).to_i
      @value = value
      @values_text = option_data.fetch(:values_text)
      @description = fetch_text(option_data.fetch(:description))
      @value_changed = true
      @name_text = add_text(*Option_Name_Surface, fetch_text(option_data.fetch(:name)), 
        Option_Name_Align_Color.first).load_color(Option_Name_Align_Color.last)
      @value_text = add_text(*Option_Value_Surface, fetch_text(option_data.fetch(:name)),
        Option_Value_Align_Color.first).load_color(Option_Value_Align_Color.last)
    end

    def update(offset_index, is_keyboard_active)
      if offset_index < 0 || offset_index >= Options::Num_Option_Displayed
        self.visible = false
        return false
      end
      update_interactions(is_keyboard_active, offset_index)
      update_surface(offset_index)
      return is_keyboard_active
    end

    def update_interactions(is_keyboard_active, line)
      if is_keyboard_active
        increment_value if Input.trigger?(:RIGHT)
        decrement_value if Input.trigger?(:LEFT)
      end
      if Mouse.trigger?(:left)
        update_mouse_interaction(Mouse.x, 
          Mouse.y - line*Element_delta_y_line)
      end
    end

    def update_mouse_interaction(mx, my)
      if my >= Button1_ymin && my < Button1_ymax
        if mx >= Button1_xmin
          if mx < Button1_xmax
            decrement_value
          elsif mx >= Button2_xmin && mx < Button2_xmax
            increment_value
          end
        end
      end
    end

    def update_surface(line)
      self.visible = true
      @texts.each { |text| text.y = Element_base_y + line*Element_delta_y_line - Text::Util::FOY }
      @value_text.text = fetch_text(@values_text.fetch(@value_index)) if @value_changed
    end

    def visible=(v)
      @texts.each { |text| text.visible = v }
    end

    def dispose
      text_dispose
    end

    def increment_value
      @value_index += 1
      @value_index %= @values.size
      @value = @values.fetch(@value_index)
      @value_changed = true
    end

    def decrement_value
      @value_index -= 1
      @value_index %= @values.size
      @value = @values.fetch(@value_index)
      @value_changed = true
    end

    def fetch_text(id)
      text = TextData.fetch(id, TextError)
      if text.class == Array
        return ext_text(9000, text.last) if text.first == 9000
        return GameData::Text.get(*text)
      end
      text
    end
  end
end
