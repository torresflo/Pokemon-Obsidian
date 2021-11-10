module Battle
  class Move
    # Sketch move
    class Sketch < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.first.move_history.empty? || !user.moveset.include?(self) || user.transform
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        move_index = user.moveset.index(self)
        target_move = actual_targets.first.move_history.last.move
        new_skill = PFM::Skill.new(target_move.id)
        new_move = Battle::Move[new_skill.symbol].new(new_skill.id, new_skill.pp, new_skill.ppmax, scene)
        user.moveset[move_index] = new_move
        user.original.skills_set[move_index] = new_skill unless scene.battle_info.max_level
        scene.display_message_and_wait(parse_text_with_pokemon(19, 691, user, PFM::Text::MOVE[1] => new_move.name))
      end
    end
    Move.register(:s_sketch, Sketch)
  end
end
