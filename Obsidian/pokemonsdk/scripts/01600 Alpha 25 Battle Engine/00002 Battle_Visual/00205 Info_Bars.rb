module Battle
  class Visual
    # Hide all the bars
    # @param no_animation [Boolean] skip the going out animation
    # @param bank [Integer, nil] bank where the info bar should be hidden
    def hide_info_bars(no_animation = false, bank: nil)
      enum = bank ? [@info_bars[bank]].each : @info_bars.each_value

      enum.each do |info_bars|
        if no_animation
          info_bars.each { |bar| bar.visible = false }
        else
          info_bars.each { |bar| bar.go_out unless bar.out? }
        end
      end
    end

    # Show all the bars
    # @param bank [Integer, nil] bank where the info bar should be hidden
    def show_info_bars(bank: nil)
      enum = bank ? [@info_bars[bank]].each : @info_bars.each_value
      enum.each do |info_bars|
        info_bars.each do |bar|
          bar.pokemon = bar.pokemon
          next unless bar.pokemon&.alive?

          bar.go_in unless bar.in?
        end
      end
    end

    # Show a specific bar
    # @param pokemon [PFM::PokemonBattler] the pokemon that should be shown by the bar
    def show_info_bar(pokemon)
      # @type [BattleUI::InfoBar]
      bar = @info_bars.dig(pokemon.bank, pokemon.position)
      return log_error("No battle bar at position #{pokemon.bank}, #{pokemon.position}") unless bar
      bar.pokemon = pokemon
      return if pokemon.dead?

      bar.go_in unless bar.in?
    end

    # Show a specific bar
    # @param pokemon [PFM::PokemonBattler] the pokemon that was shown by the bar
    def hide_info_bar(pokemon)
      # @type [BattleUI::InfoBar]
      bar = @info_bars.dig(pokemon.bank, pokemon.position)
      return log_error("No battle bar at position #{pokemon.bank}, #{pokemon.position}") unless bar
      bar.go_out unless bar.out?
    end

    # Refresh a specific bar (when Pokemon loses HP or change state)
    # @param pokemon [PFM::PokemonBattler] the pokemon that was shown by the bar
    def refresh_info_bar(pokemon)
      # @type [BattleUI::InfoBar]
      bar = @info_bars.dig(pokemon.bank, pokemon.position)
      @team_info[pokemon.bank]&.refresh
      return log_error("No battle bar at position #{pokemon.bank}, #{pokemon.position}") unless bar
      bar.refresh
    end

    # Set the state info
    # @param state [Symbol] kind of state (:choice, :move, :move_animation)
    # @param pokemon [Array<PFM::PokemonBattler>] optional list of Pokemon to show (move)
    def set_info_state(state, pokemon = nil)
      if state == :choice
        show_info_bars(bank: 1)
        hide_info_bars(bank: 0)
        show_team_info
      elsif state == :move
        hide_info_bars
        pokemon&.each { |target| show_info_bar(target) }
      elsif state == :move_animation
        hide_info_bars
        hide_team_info
      end
    end

    # Show team info
    def show_team_info
      @team_info.each_value do |info|
        info.refresh
        info.go_in unless info.in?
      end
    end

    # Hide team info
    def hide_team_info
      @team_info.each_value { |info| info.go_out unless info.out? }
    end
  end
end
