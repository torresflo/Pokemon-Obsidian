#encoding: utf-8

#noyard
module GamePlay
  class StorageUtils
    Background = "box_f"
    Selector = "h_1"
    Party_f = "pkmn_party_f"
    Gender = ["battlebar_a", "battlebar_m", "battlebar_f"]
    Box = ["Renommer", "Thème", "Retour"]
    include UI
    def initialize
      @viewport = Viewport.create(:main, 10000)
      super()
      @background = Sprite.new(@viewport).set_bitmap(Background, :pc)
      init_pokemon_box
      init_box_title
      @party_back = Array.new(6) do |i|
        if(i > 2)
          stack = SpriteStack.new(@viewport, 21 + 50 * (i - 3), 201, default_cache: :pc)
        else
          stack = SpriteStack.new(@viewport, 21 + 50 * i, 174, default_cache: :pc)
        end
        stack.push(0, 6, Party_f)
        stack.push(1, -2, nil).mirror = true
        next(stack)
      end
      init_pokemon_info
      init_selector
      @message_window = Window_Message.new(@viewport)
      draw_init
    end

    def update
      @message_window.update
    end

    def init_box_title
      @box_title = SpriteStack.new(@viewport, 30, 10)
      @box_title.push(0, 0, nil)
      @box_title.add_text(0, 4, 116, 16, nil.to_s, 1, color: 8)
    end

    def change_box
      id_theme = $storage.get_box_theme($storage.current_box)
      (stack = @box_title.stack).first.set_bitmap("title_#{id_theme}", :pc)
      stack.last.text = $storage.get_box_name($storage.current_box)
      draw_pokemon_box
    end

    def display_message(str, start=1, *choices)
      $game_temp.message_text = str
      b = true
      $game_temp.message_proc = Proc.new{b = false}
      c = nil
      if(choices.size > 0)
        $game_temp.choice_max = choices.size
        $game_temp.choice_cancel_type = choices.size
        $game_temp.choice_proc = Proc.new{|i|c = i}
        $game_temp.choice_start = start
        $game_temp.choices = choices
      end
      while b
        Graphics.update
        @message_window.update
      end
      Graphics.update
      return c
    end

    def _party_window(*args)
      window=Window_Choice.new(105,args)
      window.z=@viewport.z+1
      window.x=213
      window.y=238-window.height
      disabled=[]
      args.each_index do |i|
        cmd=args[i]
      end
      loop do
        Graphics.update
        window.update
        if window.validated?
          if(disabled.include?(window.index))
            $game_system.se_play($data_system.buzzer_se)
          else
            $game_system.se_play($data_system.decision_se)
            break
          end
        elsif(Input.trigger?(:B))
          window.index=args.size
          break
        end
      end
      index=window.index
      window.dispose
      return index
    end

    def gestion_boite
      ind = _party_window(*Box)
      box_id = $storage.current_box
      if (ind == 0) # Renommer
        name = GamePlay::NameInput.new($storage.get_box_name(box_id), 10, 'pc_psdk').main.return_name
        $storage.set_box_name(box_id, name)
        Graphics.transition
        change_box
      elsif (ind == 1) # Changement thème
        display_message(ext_text(9000, 88), 1)
        old_theme = $storage.get_box_theme($storage.current_box)
        new_theme = old_theme
        b = true
        while(b)
          Graphics.update
          update
          if (Input.trigger?(:LEFT))
            new_theme == 1 ? new_theme = PFM::Storage::NB_THEMES : new_theme -= 1
            $storage.set_box_theme($storage.current_box, new_theme)
            change_box
          end
          if (Input.trigger?(:RIGHT))
            new_theme == PFM::Storage::NB_THEMES ? new_theme = 1 : new_theme += 1
            $storage.set_box_theme($storage.current_box, new_theme)
            change_box
          end
          if (Input.trigger?(:B))
            $storage.set_box_theme($storage.current_box, old_theme)
            change_box
            b = false
          end
          if (Input.trigger?(:A))
            display_message(ext_text(9000, 89), 1)
            b = false
          end
        end
      end
    end

    def deplacement_boite(index, mode = :move, pokemon_move = nil)
      if (Input.trigger?(:UP))
        (index <= 6) ? index = 0 : index -= 6
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:LEFT))
        index -= 1
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:RIGHT))
        index += 1 if index < 30
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:DOWN))
        if (index < 25)
          index += 6
        elsif (mode == :move)
          index = 31
        end
        draw_selector(index, pokemon_move)
      end
      return index
    end

    def changer_boite(index, pokemon_move = nil)
      if (Input.trigger?(:RIGHT))
        if ($storage.current_box < ($storage.max_box - 1))
          $storage.current_box += 1
        else
          $storage.current_box = 0
        end
        change_box
      end
      if (Input.trigger?(:LEFT))
        if ($storage.current_box < 1)
          $storage.current_box = $storage.max_box - 1
        else
          $storage.current_box -= 1
        end
        change_box
      end
      if (Input.trigger?(:DOWN))
        index = 1
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:A))
        gestion_boite
      end
      return index
    end

    def deplacement_equipe(index, mode = :move, pokemon_move = nil)
      if (Input.trigger?(:LEFT))
        index -= 1 if (index > 31)
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:RIGHT))
        index += 1 if (index < 36)
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:UP))
        if (index >= 34)
          index -= 3
        elsif (mode == :move)
          arr = $storage.get_box($storage.current_box)
          i = 29
          while(i > 0)
            break if (arr[i] != nil)
            i -= 1
          end
          index = i + 1
        end
        draw_selector(index, pokemon_move)
      end
      if (Input.trigger?(:DOWN))
        index += 3 if (index < 34)
        draw_selector(index, pokemon_move)
      end
      return index
    end

    def sumary_pokemon(index)
      if (index >= 31) # Pokémon de l'équipe
        pkmn = $actors[index - 31]
        scene = GamePlay::Summary.new(pkmn, :view, $actors)
      else # Pokémon de la boite
        pkmn = $storage.info(index - 1)
        pbox = $storage.get_box($storage.current_box).clone
        scene = GamePlay::Summary.new(pkmn, :view, pbox.compact)
      end
      @viewport.visible = false
      scene.main
      @viewport.visible = true
      Graphics.transition
    end

    def release_pokemon(index)
      c = display_message(text_get(33, 101), 1, text_get(33, 83), text_get(33, 84))
      return if (c == 1)
      if (index >= 31) # Pokémon de l'équipe
        pkmn = $actors[index - 31]
        $actors[index - 31] = nil
        unless check
          return $actors[index - 31] = pkmn
        end
        $actors.compact!
        draw_pokemon_team
      else # Pokémon de la boite
        pkmn = $storage.remove_pokemon_at(index - 1)
        draw_pokemon_box
      end
      display_message(parse_text(33, 102, PFM::Text::PKNICK[0] => pkmn.given_name), 1) # "#{pkmn.given_name} a été relâché.", 1)
      display_message(parse_text(33, 103, PFM::Text::PKNICK[0] => pkmn.given_name), 1) # "Bye-bye, #{pkmn.given_name} !", 1)
      draw_info_pokemon(index)
    end

    def check
      if ($pokemon_party.pokemon_alive == 0)
        display_message(text_get(33, 88), 1)
        return false
      end
      return true
    end

    def init_pokemon_box
      @box = SpriteStack.new(@viewport, 7, 35)
      # Fond de la boîte
      @box.push(0, 0, nil)
      # Pokémon de la boîte
      c, l = 0, -1
      30.times do |i|
        l += 1
        if (i % 6 == 0 and i != 0)
          c += 1
          l = 0
        end
        @box.push(26 * l - 2, 23 * c - 4, nil).mirror = true
      end
    end

    def draw_pokemon_box
      # Fond de la boîte
      id_theme = $storage.get_box_theme($storage.current_box)
      (stack = @box.stack).first.set_bitmap("f_#{id_theme}", :pc)
      # Pokémon de la boîte
      poke_box = $storage.get_box($storage.current_box)
      30.times do |i|
        next(stack[i + 1].bitmap = nil) unless poke_box[i]
        (sp = stack[i + 1]).bitmap = poke_box[i].icon
        sp.src_rect.width = sp.src_rect.height
      end
    end

    def init_selector
      @selector = SpriteStack.new(@viewport, 0, 0, default_cache: :pc)
      @selector.push(0, -1, nil).mirror = true # Pokémon
      @selector.push(10, 0, Selector)
    end

    def draw_selector(index, pokemon = nil)
      (sp = @selector.stack.first).bitmap = (pokemon ? pokemon.icon : nil)
      sp.src_rect.width = sp.src_rect.height if pokemon
      # Coordonnées
      if (index == 0) # Boîte
        @selector.set_position(70, 4)
      elsif (index > 0 and index <= 30) # Pokémon de la boîte
        @selector.set_position(5 + ((index - 1) % 6) * 26, 30 + ((index - 1) / 6) * 24)
      elsif (index >= 31) # Pokémon de l'équipe
        if (index > 33)
          @selector.set_position(22 + 50*(index - 34), 199)
        else
          @selector.set_position(22 + 50*(index - 31), 169)
        end
      end
      draw_info_pokemon(index)
    end

    def draw_pokemon_team
      6.times do |i|
        pokemon = $actors[i]
        (sp = @party_back[i].stack.last).bitmap = (pokemon ? pokemon.icon : nil)
        sp.src_rect.width = sp.src_rect.height if pokemon
      end
    end

    def init_pokemon_info
      stack = @info_pokemon = SpriteStack.new(@viewport, 186, 8)
      stack.push(87 + 16, 0 + 16, nil, type: PokemonIconSprite).mirror = true
      stack.push(74, 5, nil, type: GenderSprite)
      stack.add_text(0, 3, 100, 16, :given_name, type: SymText)
      stack.add_text(0, 19, 50, 16, :id_text2, type: SymText)
      stack.add_text(46, 19, 50, 16, :level_text2, type: SymText)
      stack.add_text(0, 35, 50, 16, text_get(33, 24))
      stack.add_text(0, 51, 60, 16, :nature_text, type: SymText)
      stack.add_text(62, 35, 50, 16, text_get(33, 134))
      stack.push(61, 52, nil, type: Type1Sprite)
      stack.add_text(96, 35, 50, 16, text_get(33, 136))
      stack.push(95, 52, nil, type: Type2Sprite)
      stack.add_text(0, 67, 50, 16, text_get(33, 28))
      stack.add_text(0, 83, 95, 16, :item_name, type: SymText)
      stack.add_text(0, 99, 50, 16, text_get(33, 30))
      @info_pokemon_skills = Array.new(4) do |i|
        stack.add_text(0, 117 + 16 * i, 100, 16, nil.to_s)
      end
    end

    def draw_info_pokemon(index)
      return @info_pokemon.visible = false if index == 0
      if (index >= 31) # Pokémon de l'équipe
        pokemon = $pokemon_party.actors[index - 31]
      else # Pokémon de la boîte
        pokemon = $storage.info(index - 1)
      end

      return @info_pokemon.visible = false if pokemon == nil

      @info_pokemon.data = pokemon
      if pokemon.egg?
        hide_info_pokemon_egg # Masque les informations non-visibles pour les oeufs
      else
        show_info_pokemon # Réaffiche les informations masqués (au cas où le précédent était un oeuf)
        skills = pokemon.skills_set
        @info_pokemon_skills.each_with_index do |text, i|
          text.text = (skills[i] ? skills[i].name : nil.to_s)
        end
      end
    end

    def hide_info_pokemon_egg
      @info_pokemon.stack.each_with_index do |stack, i|
        stack.visible = false unless (i == 0 or i == 2)
      end
    end

    def show_info_pokemon
      @info_pokemon.stack.each do |stack|
        stack.visible = true
      end
    end

    def draw_init
      change_box
      draw_pokemon_team
    end

    def dispose
      @message_window.dispose
      @viewport.dispose
    end
  end
end
