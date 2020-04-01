module Battle
  class Visual
    # Hide all the bars
    # @param no_animation [Boolean] skip the going out animation
    def hide_info_bars(no_animation = false)
      @info_bars.each_value do |info_bars|
        if no_animation
          info_bars.each { |bar| bar.visible = false }
        else
          info_bars.each(&:go_out)
        end
      end
    end

    # Show all the bars
    def show_info_bars
      @info_bars.each_value do |info_bars|
        info_bars.each do |bar|
          bar.pokemon = bar.pokemon
          bar.come_back
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
      bar.come_back
    end

    # Show a specific bar
    # @param pokemon [PFM::PokemonBattler] the pokemon that was shown by the bar
    def hide_info_bar(pokemon)
      # @type [BattleUI::InfoBar]
      bar = @info_bars.dig(pokemon.bank, pokemon.position)
      return log_error("No battle bar at position #{pokemon.bank}, #{pokemon.position}") unless bar
      bar.go_out
    end

    # Refresh a specific bar (when Pokemon loses HP or change state)
    # @param pokemon [PFM::PokemonBattler] the pokemon that was shown by the bar
    def refresh_info_bar(pokemon)
      # @type [BattleUI::InfoBar]
      bar = @info_bars.dig(pokemon.bank, pokemon.position)
      return log_error("No battle bar at position #{pokemon.bank}, #{pokemon.position}") unless bar
      bar.refresh
    end
  end
end
