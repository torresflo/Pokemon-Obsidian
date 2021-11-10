module Battle
  class Visual
    # Method that shows the trainer choice
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    # @return [Symbol, Array(Symbol, Hash), nil] :attack, :bag, :pokemon, :flee, :cancel, :try_next
    def show_player_choice(pokemon_index)
      if (pokemon = @scene.logic.battler(0, pokemon_index)).effects.has?(&:force_next_move?)
        # @type [Effects::ForceNextMove]
        effect = pokemon.effects.get(&:force_next_move?)
        return :action, effect.make_action
      end

      # return :try_next if spc_cannot_use_this_pokemon?(pokemon_index)
      show_player_choice_begin(pokemon_index)
      show_player_choice_loop
      show_player_choice_end(pokemon_index)
      return @player_choice_ui.result, @player_choice_ui.action
    end

    # Show the message "What will X do"
    # @param pokemon_index [Integer]
    def spc_show_message(pokemon_index)
      # pokemon = @scene.logic.battler(0, pokemon_index)
      @scene.message_window.wait_input = false
      # text_to_show = parse_text(18, 71, '[VAR 010C(0000)]' => pokemon.given_name)
      # @scene.display_message(text_to_show) if @scene.message_window.last_text != text_to_show
    end

    private

    # Begining of the show_player_choice
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    def show_player_choice_begin(pokemon_index)
      pokemon = @scene.logic.battler(0, pokemon_index)
      @locking = true
      @player_choice_ui.reset(@scene.logic.switch_handler.can_switch?(pokemon))
      if @player_choice_ui.out?
        @player_choice_ui.go_in
        @animations << @player_choice_ui
        wait_for_animation
      end
      spc_show_message(pokemon_index)
      spc_start_bouncing_animation(pokemon_index)
    end

    # Loop process of the player choice
    def show_player_choice_loop
      loop do
        @scene.update
        @player_choice_ui.update
        Graphics.update
        break if @player_choice_ui.validated?
      end
    end

    # End of the show_player_choice
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    def show_player_choice_end(pokemon_index)
      @player_choice_ui.go_out
      @animations << @player_choice_ui
      if @player_choice_ui.result != :attack
        spc_stop_bouncing_animation(pokemon_index)
        wait_for_animation
      end
      @locking = false
    end

    # Start the IdlePokemonAnimation (bouncing)
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    def spc_start_bouncing_animation(pokemon_index)
      return if @parallel_animations[IdlePokemonAnimation]
      sprite = battler_sprite(0, pokemon_index)
      bar = @info_bars.dig(0, pokemon_index)
      @parallel_animations[IdlePokemonAnimation] = IdlePokemonAnimation.new(self, sprite, bar)
    end

    # Stop the IdlePokemonAnimation (bouncing)
    # @param _pokemon_index [Integer] Index of the Pokemon in the party
    def spc_stop_bouncing_animation(_pokemon_index)
      @parallel_animations[IdlePokemonAnimation]&.remove
    end
  end
end
