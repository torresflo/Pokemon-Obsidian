module GamePlay
  class PokemonStorage
    # List of options shown when choosing the box option
    CHOICE_BOX_OPTIONS = [
      'Change name',
      'Change theme',
      'Add box after',
      'Remove'
    ]
    # Message shown when choosing the box option
    MESSAGE_BOX_OPTIONS = 'What to do with %<box>s ?'
    # List of options shown when choosing something for a single pokemon
    SINGLE_POKEMON_CHOICE = [
      'Move',
      'Summary',
      'Give',
      'Take',
      'Mark',
      'Release'
    ]
    # Message shown when manipulating a single Pokemon
    SINGLE_POKEMON_MESSAGE = 'What to do with %<name>s ?'
    # Message shown when we manipulate various Pokemon
    SELECTED_POKEMON_MESSAGE = 'What to do with %<count>d Pokemon ?'

    private

    # Choice shown when we want to change box option
    def choice_box_option
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(get_text(CHOICE_BOX_OPTIONS[0]), on_validate: method(:change_box_name))
        .register_choice(get_text(CHOICE_BOX_OPTIONS[1]), on_validate: method(:change_box_theme))
        .register_choice(get_text(CHOICE_BOX_OPTIONS[2]), on_validate: method(:add_new_box))
        .register_choice(get_text(CHOICE_BOX_OPTIONS[3]), on_validate: method(:remove_box), disable_detect: method(:current_box_non_empty?))

      @base_ui.show_win_text(format(get_text(MESSAGE_BOX_OPTIONS), box: @storage.current_box_object.name))
      choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      @base_ui.hide_win_text
      refresh
    end

    # Get the choice coordinates
    # @param choices [PFM::Choice_Helper]
    # @return [Array(Integer, Integer)]
    def choice_coordinates(choices)
      height = choices.size * 16 + 6
      return 318, 216 - height
    end

    # Choice shown when we didn't selected any pokemon
    def choice_single_pokemon
      @selection.clear
      @selection.select
      @current_pokemon = @selection.all_selected_pokemon.first
      return play_buzzer_se if @current_pokemon.nil?

      play_decision_se
      can_item_be_taken = proc { @current_pokemon.item_holding == 0 }
      not_releasable = proc { !pokemon_can_be_released? }
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[0]), on_validate: method(:move_pokemon))
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[1]), on_validate: method(:show_pokemon_summary))
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[2]), on_validate: method(:give_item_to_pokemon))
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[3]), on_validate: method(:take_item_from_pokemon), disable_detect: can_item_be_taken)
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[5]), on_validate: method(:release_pokemon), disable_detect: not_releasable)

      @base_ui.show_win_text(format(get_text(SINGLE_POKEMON_MESSAGE), name: @current_pokemon.given_name))
      refresh # <= Update the selection display
      @base_ui.mode = 7
      choice = choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      if choice != 0
        @base_ui.hide_win_text
        @selection.clear
        refresh
      else
        update_mode
      end
    end

    # Choice shown when we selected various pokemon
    def choice_selected_pokemon
      @current_pokemons = @selection.all_selected_pokemon
      return play_buzzer_se if @current_pokemons.empty?

      play_decision_se
      not_releasable = proc { !pokemon_can_be_released? }
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[0]), on_validate: method(:move_selected_pokemon))
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[1]), on_validate: method(:show_selected_pokemon_summary))
        .register_choice(get_text(SINGLE_POKEMON_CHOICE[5]), on_validate: method(:release_selected_pokemon), disable_detect: not_releasable)

      @base_ui.show_win_text(format(get_text(SELECTED_POKEMON_MESSAGE), count: @current_pokemons.size))
      @base_ui.mode = 7
      choice = choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      if choice != 0
        @base_ui.hide_win_text
        refresh
      else
        update_mode
      end
    end
  end
end
