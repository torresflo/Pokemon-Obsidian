module Battle
  # Module responsive of mocking the battle visual so nothing happen on the reality
  #
  # Note: super inside this script might call the original function
  module VisualMock
    class << self
      # Method called when a visual gets mocked (through extend)
      # @param mod [Battle::Visual]
      def extended(mod)
        mod.instance_variable_set(:@screenshot, nil)
        mod.instance_variable_set(:@viewport, nil)
        mod.instance_variable_set(:@viewport_sub, nil)
        mod.instance_variable_set(:@battlers, {})
        mod.instance_variable_set(:@info_bars, {})
        mod.instance_variable_set(:@team_info, {})
        mod.instance_variable_set(:@ability_bars, {})
        mod.instance_variable_set(:@item_bars, {})
        mod.instance_variable_set(:@item_bars, {})
        mod.instance_variable_set(:@animations, [])
        mod.instance_variable_set(:@animatable, [])
        mod.instance_variable_set(:@parallel_animations, {})
        mod.instance_variable_set(:@to_dispose, [])
        mod.instance_variable_set(:@locking, false)
      end
    end

    # Lock the battle scene
    def lock
      if block_given?
        @locking = true
        yield
        return @locking = false
      end
    end

    # Show the ability animation
    # @param target [PFM::PokemonBattler]
    def show_ability(target)
      return
    end

    # Show the exp distribution
    # @param exp_data [Hash{ PFM::PokemonBattler => Integer }] info about experience each pokemon should receive
    def show_exp_distribution(exp_data)
      return
    end

    # Method that show the pokemon choice
    # @param forced [Boolean]
    # @return [PFM::PokemonBattler, nil]
    def show_pokemon_choice(forced = false)
      log_error("show_pokemon_choice was called inside mock by #{caller[0]}")
      return
    end

    # Show a dedicated animation
    # @param target [PFM::PokemonBattler]
    # @param id [Integer]
    def show_rmxp_animation(target, id)
      return
    end

    # Show the item user animation
    # @param target [PFM::PokemonBattler]
    def show_item(target)
      return
    end

    # Refresh a specific bar (when Pokemon loses HP or change state)
    # @param pokemon [PFM::PokemonBattler] the pokemon that was shown by the bar
    def refresh_info_bar(pokemon)
      return
    end

    # Show HP animations
    # @param targets [Array<PFM::PokemonBattler>]
    # @param hps [Array<Integer>]
    # @param effectiveness [Array<Integer, nil>]
    # @param messages [Proc] messages shown right before the post processing
    def show_hp_animations(targets, hps, effectiveness = [], &messages)
      return
    end

    # Show the pokemon switch form animation
    # @param target [PFM::PokemonBattler]
    def show_switch_form_animation(target)
      return
    end

    # Set the state info
    # @param state [Symbol] kind of state (:choice, :move, :move_animation)
    # @param pokemon [Array<PFM::PokemonBattler>] optional list of Pokemon to show (move)
    def set_info_state(state, pokemon = nil)
      return
    end

    # Wait for all animation to end (non parallel one)
    def wait_for_animation
      return
    end

    # Hide team info
    def hide_team_info
      return
    end

    # Make a move animation
    # @param user [PFM::PokemonBattler]
    # @param targets [Array<PFM::PokemonBattler>]
    # @param move [Battle::Move]
    def show_move_animation(user, targets, move)
      return
    end
  end
end
