module Battle
  class Move
    # class managing Lock-On and Mind Reader moves
    class LockOn < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if user.effects.get(:lock_on)&.target == target

        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if user.effects.get(:lock_on)&.target == target

          user.effects.add(Effects::LockOn.new(@logic, user, target))
          text = parse_text_with_pokemon(19, target.bank == 0 ? 656 : 651, user,
                                         PFM::Text::PKNICK[0] => user.given_name,
                                         PFM::Text::PKNICK[1] => target.given_name)
          @scene.display_message_and_wait(text)
        end
      end
    end

    Move.register(:s_lock_on, LockOn)
    Move.register(:s_mind_reader, LockOn)
  end
end
