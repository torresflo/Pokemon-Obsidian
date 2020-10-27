module GamePlay
  class PokemonTradeStorage < PokemonStorage
    # Message shown to tell to choose a Pokemon
    CHOOSE_POKEMON_MESSAGE = 'Choose a Pokemon to trade'
    # List of option when pressing A
    TRADE_OPTIONS = [
      [:ext_text, 9000, 90], # Trade
      [:text_get, 33, 41], # Summary
      [:text_get, 33, 82] # Cancel
    ]
    # Get the selected Pokemon index (1~30) = current box, (31~36) = party
    # @return [Integer, nil]
    attr_reader :return_data

    private

    def create_graphics
      super
      show_pokemon_choice
    end

    def show_pokemon_choice
      @base_ui.show_win_text(get_text(CHOOSE_POKEMON_MESSAGE))
    end

    alias action_x play_buzzer_se
    alias action_a_detailed play_buzzer_se
    alias action_a_fast play_buzzer_se
    alias action_a_fast_swap play_buzzer_se
    alias action_a_grouped play_buzzer_se
    alias action_l play_buzzer_se
    alias action_r play_buzzer_se
    alias action_r2 play_buzzer_se
    alias action_l2 play_buzzer_se

    def action_a
      return play_buzzer_se if @cursor.mode == :box_choice

      @selection.select
      refresh
      @current_pokemon = @selection.all_selected_pokemon.first
      choice_trade
      @selection.clear
      refresh
    end

    def action_b
      c = @utils.display_message(ext_text(9000, 87), 2, text_get(33, 83), text_get(33, 84))
      @return_data = nil
      @running = false if c == 0
    end

    def choice_trade
      return play_buzzer_se if @current_pokemon.nil?

      play_decision_se
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(get_text(TRADE_OPTIONS[0]), on_validate: method(:trade_pokemon))
        .register_choice(get_text(TRADE_OPTIONS[1]), on_validate: method(:show_pokemon_summary))
        .register_choice(get_text(TRADE_OPTIONS[2]))

      @base_ui.show_win_text(format(get_text(SINGLE_POKEMON_MESSAGE), name: @current_pokemon.given_name))
      @base_ui.mode = 7
      choice = choices.display_choice(@viewport, *choice_coordinates(choices), nil, on_update: method(:update_graphics), align_right: true)
      show_pokemon_choice if choice != 0
    end

    def trade_pokemon
      if (index = @party.index(@current_pokemon))
        @return_data = 31 + index
      else
        @return_data = 1 + @cursor.index
      end
      @running = false
    end
  end
end
