module BattleUI
  # Abstraction helping to design skill choice a way that complies to what Visual expect to handle
  module SkillChoiceAbstraction
    # @!parse
    #   include GenericChoice
    # The selected move
    # @return [Battle::Move, :cancel]
    attr_reader :result
    # The pokemon the player choosed a move
    # @return [PFM::PokemonBattler]
    attr_reader :pokemon
    # Tell if the mega evolution is enabled
    # @return [Boolean]
    attr_accessor :mega_enabled
    # Get the index
    # @return [Integer]
    attr_reader :index

    # Reset the Skill choice
    # @param pokemon [PFM::PokemonBattler]
    def reset(pokemon)
      @pokemon = pokemon
      @mega_enabled = false
      self.data = pokemon if respond_to?(:data=, true)
      @index = @last_indexes[pokemon].to_i.clamp(0, max_index)
      update_button_opacity
      super() if @super_reset
    end

    # If the player made a choice
    # @return [Boolean]
    def validated?
      !@result.nil? && (respond_to?(:done?, true) ? done? : true)
    end

    private

    # Give the max index of the choice
    # @return [Integer]
    def max_index
      return 4
    end

    # Set the choice as wanting to cancel the choice
    # @return [Boolean] if the operation was a success
    def choice_cancel
      @result = :cancel
      return true
    end

    # Set the choice of the move to use
    # @param index [Integer]
    # @return [Boolean]
    def choice_move(index = @index)
      move = @pokemon.moveset[index]
      unless move.disable_reason(@pokemon)
        @result = move
        return true
      end

      return false
    end

    # Show the move choice failure
    # @param index [Integer]
    def show_move_choice_failure(index = @index)
      move = @pokemon.moveset[@index]
      move.disable_reason(@pokemon)&.call
    end
  end
end
