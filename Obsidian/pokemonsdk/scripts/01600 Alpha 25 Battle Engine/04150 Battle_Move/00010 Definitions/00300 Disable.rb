module Battle
  class Move
    # Disable move
    class Disable < Move
      # Ability preventing the move from working
      BLOCKING_ABILITY = %i[aroma_veil]
      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        ally = @logic.allies_of(target).find { |a| BLOCKING_ABILITY.include?(a.battle_ability_db_symbol) }
        if user.can_be_lowered_or_canceled?(BLOCKING_ABILITY.include?(target.battle_ability_db_symbol))
          @scene.visual.show_ability(target)
          return true
        elsif user.can_be_lowered_or_canceled? && ally
          @scene.visual.show_ability(ally)
          return true
        end

        return super
      end

      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return true if super
        return failure_message unless (move = target.move_history.last)
        return failure_message if move.turn != $game_temp.battle_turn

        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          move = target.move_history.last.original_move
          message = parse_text_with_pokemon(19, 592, target, PFM::Text::MOVE[1] => move.name)
          target.effects.add(Effects::Disable.new(@logic, target, move))
          @scene.display_message_and_wait(message)
        end
      end

      private

      # Display failure message
      # @return [Boolean] true for blocking
      def failure_message
        @logic.scene.display_message_and_wait(parse_text(18, 74))
        return true
      end
    end
    Move.register(:s_disable, Disable)
  end
end
