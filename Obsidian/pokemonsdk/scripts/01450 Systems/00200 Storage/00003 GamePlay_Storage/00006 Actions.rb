module GamePlay
  class PokemonStorage
    include Util::GiveTakeItem
    # Message shown when we want to rename a box
    BOX_NAME_MESSAGE = [:ext_text, 9007, 4]
    # Message shown when choosing the theme
    BOX_THEME_CHOICE_MESSAGE = [:ext_text, 9007, 5]
    # Message shown when we want to give a name to the new box
    BOX_NEW_NAME_MESSAGE = [:ext_text, 9007, 6]
    # New box name
    BOX_NEW_DEFAULT_NAME = [:ext_text, 9007, 7]
    # Message shown to confirm if we want to remove the box
    REMOVE_BOX_MESSAGE = [:ext_text, 9007, 8]
    # Choice option for remove box confirmation
    REMOVE_BOX_CHOICES = [
      [:text_get, 33, 84], # No
      [:text_get, 33, 83] # Yes
    ]
    # Message shown when we want to move a Pokemon
    MOVE_POKEMON_MESSAGE = [:ext_text, 9007, 9]
    # Message shown when we want to move several Pokemon
    MOVE_SELECTED_POKEMON_MESSAGE = [:ext_text, 9007, 10]
    # Message shown when we try to release a Pokemon
    RELEASE_POKEMON_MESSAGE1 = [:ext_text, 9007, 11]
    # Choice option for release pokemon confirmation
    RELEASE_POKEMON_CHOICES = [
      [:text_get, 33, 84], # No
      [:text_get, 33, 83] # Yes
    ]
    # Message shown when we try to release several Pokemon
    RELEASE_SELECTED_POKEMON_MESSAGE = [:ext_text, 9007, 12]

    private

    # Change the current box name
    def change_box_name
      box = @storage.current_box_object.name
      GamePlay.open_box_name_input(box) { |scene| @storage.set_box_name(@storage.current_box, scene.return_name) }
    end

    # Change the current box theme
    def change_box_theme
      # TODO: Use a specific scene for that
      original_theme = @storage.current_box_object.theme
      max_index = max_theme_index
      @box_theme_index = original_theme
      @base_ui.show_win_text(format(send(*BOX_THEME_CHOICE_MESSAGE), box: @storage.current_box_object.name))
      loop do
        update_graphics
        Graphics.update
        if index_changed(:@box_theme_index, :LEFT, :RIGHT, max_index, 1)
          @storage.set_box_theme(@storage.current_box, @box_theme_index)
          refresh
          play_cursor_se
        elsif Input.trigger?(:B)
          @storage.set_box_theme(@storage.current_box, original_theme)
          refresh
          play_cancel_se
          break
        elsif Input.trigger?(:A)
          play_decision_se
          break
        end
      end
      @base_ui.hide_win_text
    end

    # Get the number of themes
    def max_theme_index
      16
    end

    # Add a new box
    def add_new_box
      box = format(send(*BOX_NEW_DEFAULT_NAME), id: @storage.max_box + 1)
      GamePlay.open_box_name_input(box) { |scene| @storage.add_box(scene.return_name) }
      @storage.current_box = @storage.max_box - 1
    end

    # Remove the box
    def remove_box
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 0)
      choices
        .register_choice(send(*REMOVE_BOX_CHOICES[0]))
        .register_choice(send(*REMOVE_BOX_CHOICES[1]))
      @base_ui.show_win_text(format(send(*REMOVE_BOX_MESSAGE), box: @storage.current_box_object.name))
      choice = choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      @base_ui.hide_win_text
      @storage.delete_box(@storage.current_box) if choice == 1
      @storage.current_box = @storage.current_box
    end

    # Move the selected Pokemon
    def move_pokemon
      @moving_pokemon = true
      @base_ui.show_win_text(format(send(*MOVE_POKEMON_MESSAGE), name: @current_pokemon.given_name))
    end

    # Show the summary of a Pokemon
    def show_pokemon_summary
      if @cursor.mode == :box
        party = @storage.current_box_object.content
      elsif @mode_handler.mode == :battle
        party = @storage.battle_boxes[@storage.current_battle_box].content
      else
        party = @party
      end

      GamePlay.open_summary(@current_pokemon, party.compact)
    end

    # Give an item to a Pokemon
    def give_item_to_pokemon
      givetake_give_item(@current_pokemon) { refresh }
    end

    # Take item from Pokemon
    def take_item_from_pokemon
      givetake_take_item(@current_pokemon)
    end

    # Release a Pokemon
    def release_pokemon
      return display_message(text_get(33, 108)) if @current_pokemon.db_symbol == :kyurem && @current_pokemon.absofusionned?

      name = @current_pokemon.given_name
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 0)
      choices
        .register_choice(send(*RELEASE_POKEMON_CHOICES[0]))
        .register_choice(send(*RELEASE_POKEMON_CHOICES[1]))
      @base_ui.show_win_text(format(send(*RELEASE_POKEMON_MESSAGE1), name: name))
      choice = choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      @base_ui.hide_win_text
      if choice == 1
        display_message(parse_text_with_pokemon(33, 102, @current_pokemon))
        @selection.release_selected_pokemon
        refresh
        display_message_and_wait(parse_text_with_pokemon(33, 103, @current_pokemon))
      end
    end

    # Move all selected Pokemon
    def move_selected_pokemon
      @moving_pokemon = true
      @base_ui.show_win_text(format(send(*MOVE_SELECTED_POKEMON_MESSAGE), count: @current_pokemons.size))
    end

    # Show the summary of the selected Pokemon
    def show_selected_pokemon_summary
      GamePlay.open_summary(@current_pokemons.compact.first, @current_pokemons)
    end

    # Release the selected Pokemon
    def release_selected_pokemon
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 0)
      choices
        .register_choice(send(*RELEASE_POKEMON_CHOICES[0]))
        .register_choice(send(*RELEASE_POKEMON_CHOICES[1]))
      @base_ui.show_win_text(format(send(*RELEASE_SELECTED_POKEMON_MESSAGE), count: @current_pokemons.size))
      choice = choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      @base_ui.hide_win_text
      if choice == 1
        @selection.release_selected_pokemon
        refresh
      end
    end
  end
end
