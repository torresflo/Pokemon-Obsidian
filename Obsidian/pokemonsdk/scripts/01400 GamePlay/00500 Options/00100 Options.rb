#encoding: utf-8

#noyard
module GamePlay
  class Options < Base
    Num_Option_Displayed = 5
    Delta_Option = (Num_Option_Displayed / 2.0).round
    Background_Image = 'Options_Background'
    Selector_Image = 'Options_Selector'
    ButtonUpDown_X = 154..166
    ButtonUp_Y = 33..40
    ButtonDown_Y = 147..154
    Options = {}
    include Text::Util
    def initialize
      super
      @viewport = Viewport.create(:main, 10000)
      @background = ::Yuki::Utils.create_background(@viewport, Background_Image)
      @selector = ::Yuki::Utils.create_sprite(@viewport, Selector_Image, 11, 45, 200)
      @options = fetch_options
      @buttons = generate_option_buttons
      @button_validate = Option_Button.new(0, @viewport)
      @button_cancel = Option_Button.new(1, @viewport)
      init_text(0, @viewport)
      add_text(3, 6, 160, 20, GameData::Text.get(42, 0), 1)
      @descr_text = add_text(20, 160, 286, 16, " ")
      @offset_index = 0
      @cursor_index = 0
      @changing_option = true
      @validate = false
      @description = nil
      @running = true
      update_buttons
    end

    def update
      unless update_control_button
        update_cursor(@changing_option)
        update_buttons
      end
    end

    def create_graphics
      # Skipped to prevent glitches
    end

    private
    def update_control_button
      prev_state = @changing_option
      #> Aller retour dans le menu
      update_changing_option(prev_state)
      #> Position sur validation ou non
      unless @changing_option
        prev_state = update_validate(prev_state)
      end
      update_validate_mouse if Mouse.trigger?(:left)
      #> Refraichissement
      if(prev_state != @changing_option)
        @button_validate.draw(prev_state & @validate)
        @button_cancel.draw(prev_state & !@validate)
        @selector.visible = @changing_option
        return true
      end
      return false
    end

    def update_changing_option(prev_state)
      up_state = Input.trigger?(:UP)
      down_state = Input.trigger?(:DOWN)
      if(Input.trigger?(:X) or (!prev_state and
          (up_state or down_state)))
        @changing_option = !@changing_option
      elsif(prev_state)
        if((up_state and @cursor_index == 0) or 
            (down_state and @cursor_index == (@buttons.size - 1)))
          @changing_option = false
        end
      end
    end

    def update_validate(prev_state)
      if Input.trigger?(:LEFT) or 
          Input.trigger?(:RIGHT)
        @validate = !@validate
        return !@changing_option
      elsif Input.trigger?(:B)
        @validate = false
        return !@changing_option
      elsif Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        @running = false
        validate if @validate
      end
      return prev_state
    end

    def update_validate_mouse
      if(@button_validate.simple_mouse_in?)
        $game_system.se_play($data_system.decision_se)
        @running = false
        validate
      elsif(@button_cancel.simple_mouse_in?)
        $game_system.se_play($data_system.decision_se)
        @running = false
      end
    end
#===
#> Explications relatives à update_cursor
#  Le curseur des options doit rester au centre de la liste, sauf pour deux cas
#  1. S'il est au centre, les premières options seraient pas dans la première case
#  2. S'il est au centre, les dernières options (longue liste) sont pas dans la dernière case
#  Lorsque nous descendons si le nombre d'options est supérieur à ce qui peut être affiché
#    nous faisons descendre la liste jusqu'à ce que le dernier arrive en bas
#    et ensuite le curseur descendra jusqu'au dernier
#    /!\ Tant que le curseur n'est pas à la motié de nombre max affichable il descend !
#  Dans le cas où la liste est plus petite, le curseur descend naturellement jusqu'au dernier
#  Lorsque nous montons, si le nombre d'options n'est pas supérieur à ce qui peut être affiché
#    nous descendons bêtement le curseur
#  Dans le cas contraire, si le curseur est en position 1 à max_affichable/2 il descend
#    Tout comme s'il est de (fin-max_affichable/2) à fin
#  Sinon, c'est la liste qui descend
#===
    def update_cursor(changing_option) #Option_Element::Element_delta_y_line
      if(changing_option)
        if(Input.trigger?(:UP))
          update_cursor_up
        elsif(Input.trigger?(:DOWN))
          update_cursor_down
        end
      end
      if(Mouse.trigger?(:left))
        my = Mouse.y
        if(ButtonUpDown_X.include?(Mouse.x))
          if(ButtonUp_Y.include?(my))
            update_cursor_up
          elsif(ButtonDown_Y.include?(my))
            update_cursor_down
          end
        end
      end
    end

    def update_cursor_up
      return if @cursor_index == 0
      if(@buttons.size > Num_Option_Displayed)
        if(@cursor_index < Delta_Option or 
            @cursor_index > (@buttons.size - Delta_Option))
          @selector.y -= Option_Element::Element_delta_y_line
        else
          @offset_index += 1
        end
      else
        @selector.y -= Option_Element::Element_delta_y_line
      end
      @cursor_index -= 1
    end

    def update_cursor_down
      @cursor_index += 1
      return @cursor_index -= 1 if @cursor_index >= @buttons.size
      if(@buttons.size > Num_Option_Displayed)
        if(@cursor_index < Delta_Option or 
            @cursor_index > (@buttons.size - Delta_Option))
          @selector.y += Option_Element::Element_delta_y_line
        else
          @offset_index -= 1
        end
      else
        @selector.y += Option_Element::Element_delta_y_line
      end
    end

    def update_buttons
      offset_index = @offset_index
      cursor_index = @changing_option ? @cursor_index + offset_index : offset_index - 1
      @buttons.each do |button|
        if(button.update(offset_index, offset_index == cursor_index))
          if @description != button.description
            @description = button.description
            refresh
          end
        end
        offset_index += 1
      end
    end

    def refresh
      @descr_text.multiline_text = @description
    end

    def validate
      buttons = @buttons
      @options.each_with_index do |option, index|
        public_send(option.fetch(:set_value), buttons[index].value)
      end
    end

    def fetch_options
      options = []
      Options.each_value {|option| options.push(option) }
      options.sort! {|option1, option2| option1.fetch(:priority) <=> option2.fetch(:priority) }
      options
    end

    def generate_option_buttons
      buttons = []
      @options.each do |option|
        buttons.push(
          Option_Element.new(
            @viewport,
            public_send(option.fetch(:get_value)),
            option
          )
        )
      end
      buttons
    end
    #===
    #> Fonction permettant d'ajouter une nouvelle option
    #  name_sym = Symbole du texte associé à l'option dans les textes d'Option_Element
    #  descr_sym = Symbole de la description associé à l'option
    #  option_values = Tableau des valeurs que peut prendre l'option (interne)
    #  values_name_sym = Tableau des noms des valeurs
    #  handle_info = Hash contenant les informations de gestion de l'option
    #     get_value: symbole de la méthode qui permet de récupérer la valeur de l'option
    #     set_value: symbole de la méthode qui permet de modifier la valeur de l'option
    #     priority: Valeur de la priorité de l'option (plus c'est petit plus c'est prioritaire) / Les options natives PSDK sont espacées de 1000
    #===
    def self.add_option(name_sym, descr_sym, option_values, values_name_sym, handle_info)
      get_value = handle_info.fetch(:get_value)
      set_value = handle_info.fetch(:set_value)
      priority = handle_info.fetch(:priority, (Options.size+1)*1000)
      unless Options.fetch(get_value, false)
        Options[get_value] = 
          {
            name: name_sym,
            values: option_values,
            values_text: values_name_sym,
            description: descr_sym,
            get_value: get_value,
            set_value: set_value,
            priority: priority
          }
      end
    end

    add_option(:message_speed, :message_speed_descr, [1, 2, 3], 
      [:speed_slow, :speed_medium, :speed_fast], 
      get_value: :message_speed_get,
      set_value: :message_speed_set
    )

    add_option(:battle_animation, :battle_ani_descr, [true, false],
      [:battle_ani_with, :battle_ani_without],
      get_value: :battle_animation_get,
      set_value: :battle_animation_set
    )

    add_option(:battle_style, :battle_style_descr, [true, false],
      [:battle_style_free, :battle_style_locked],
      get_value: :battle_style_get,
      set_value: :battle_style_set
    )
    add_option(:volume, :volume_descr, [0, 25, 50, 75, 100],
      [:volume_0, :volume_25, :volume_50, :volume_75, :volume_100],
      get_value: :volume_get,
      set_value: :volume_set
    )
    add_option(
      :message_frame, :message_frame_descr, GameData::Windows::MESSAGE_FRAME,
      Array.new(19) { |i| :"mf_#{i}" },
      get_value: :message_frame_get,
      set_value: :message_frame_set,
      priority: 1001
    )
    #===
    #> Définition des getter et setter
    #===
    public
    def message_speed_get
      $options.message_speed
    end

    def message_speed_set(value)
      $options.message_speed = value
    end

    def battle_animation_get
      $options.show_animation
    end

    def battle_animation_set(value)
      $options.show_animation = value
    end

    def battle_style_get
      $options.battle_mode
    end

    def battle_style_set(value)
      $options.battle_mode = value
    end

    def volume_get
      Audio.music_volume
    end

    def volume_set(value)
      $options.music_volume = value
      $options.sfx_volume = value
    end

    def message_frame_get
      $options.message_frame
    end

    def message_frame_set(value)
      $options.message_frame = value
    end
  end
end
