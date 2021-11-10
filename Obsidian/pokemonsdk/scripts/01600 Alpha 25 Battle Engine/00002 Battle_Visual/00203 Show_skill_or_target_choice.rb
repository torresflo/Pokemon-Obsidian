module Battle
  class Visual
    # Method that show the skill choice and store it inside an instance variable
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    # @return [Boolean] if the player has choose a skill
    def show_skill_choice(pokemon_index)
      return :try_next if spc_cannot_use_this_pokemon?(pokemon_index)

      show_skill_choice_begin(pokemon_index)
      show_skill_choice_loop
      show_skill_choice_end(pokemon_index)
      return @skill_choice_ui.result != :cancel
    end

    # Method that show the target choice once the skill was choosen
    # @return [Array<PFM::PokemonBattler, Battle::Move, Integer(bank), Integer(position), Boolean(mega)>, nil]
    def show_target_choice
      return stc_result if stc_cannot_choose_target?

      show_target_choice_begin
      show_target_choice_loop
      show_target_choice_end
      return stc_result(@target_selection_window.result)
    ensure
      @target_selection_window&.dispose
      @target_selection_window = nil
    end

    private

    # Begin of the skill_choice
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    def show_skill_choice_begin(pokemon_index)
      spc_start_bouncing_animation(pokemon_index)
      @locking = true
      wait_for_animation
      @skill_choice_ui.reset(@scene.logic.battler(0, pokemon_index))
      @skill_choice_ui.go_in
      @animations << @skill_choice_ui
      wait_for_animation
    end

    # Loop of the skill_choice
    def show_skill_choice_loop
      loop do
        @scene.update
        @skill_choice_ui.update
        Graphics.update
        break if @skill_choice_ui.validated?
      end
    end

    # End of the skill_choice
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    def show_skill_choice_end(pokemon_index)
      spc_stop_bouncing_animation(pokemon_index)
      @skill_choice_ui.go_out
      @animations << @skill_choice_ui
      wait_for_animation
      @locking = false
    end

    # Show the Target Selection Window
    def show_target_choice_begin
      @locking = true
      # @type [BattleUI::TargetSelection]
      @target_selection_window =
        BattleUI::TargetSelection.new(@viewport_sub, @skill_choice_ui.pokemon, @skill_choice_ui.result, @scene.logic)
      spc_start_bouncing_animation(@skill_choice_ui.pokemon.position)
    end

    # Loop of the target choice
    def show_target_choice_loop
      loop do
        @scene.update
        @target_selection_window.update
        Graphics.update
        break if @target_selection_window.validated?
      end
    end

    # End of the target choice
    def show_target_choice_end
      spc_stop_bouncing_animation(@skill_choice_ui.pokemon.position)
      @locking = false
    end

    # Make the result of show_target_choice method
    # @param result [Array, :auto, :cancel]
    def stc_result(result = :auto)
      return nil if result == :cancel

      arr = [@skill_choice_ui.pokemon, @skill_choice_ui.result]
      if result.is_a?(Array)
        arr.concat(result)
      elsif result == :auto
        targets = @skill_choice_ui.result.battler_targets(@skill_choice_ui.pokemon, @scene.logic)
        if targets.empty?
          arr.concat([1, 0])
        else
          arr << targets.first.bank
          arr << targets.first.position
        end
      else
        return nil
      end
      arr << @skill_choice_ui.mega_enabled
      return arr
    end

    # Tell if the Pokemon can be used or not
    # @return [Boolean] if the Pokemon cannot be used
    def spc_cannot_use_this_pokemon?(pokemon_index)
      return @scene.logic.battler(0, pokemon_index)&.party_id != 0
    end

    # Tell if we can choose a target
    # @return [Boolean]
    def stc_cannot_choose_target?
      return @scene.logic.battle_info.vs_type == 1 ||
             BattleUI::TargetSelection.cannot_show?(@skill_choice_ui.result, @skill_choice_ui.pokemon, @scene.logic)
    end
  end
end
