module Battle
  class Move
    # Move that copies the last move of the choosen target
    class Mimic < Move
      NO_MIMIC_MOVES = %i[chatter metronome sketch struggle mimic]
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.empty? || targets.first.move_history.empty? || NO_MIMIC_MOVES.include?(targets.first.move_history.last.move.db_symbol)
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        mimic_move_index = user.moveset.index(self)
        return unless mimic_move_index

        user.mimic_move = [self, mimic_move_index]
        move = actual_targets.first.move_history.last.move
        user.moveset[mimic_move_index] = Move[move.be_method].new(move.id, 5, 5, scene)
        scene.display_message_and_wait(parse_text_with_pokemon(19, 688, user, PFM::Text::MOVE[1] => move.name))
      end
    end

    Move.register(:s_mimic, Mimic)
  end
end
