module Battle
  class Move
    # Move that makes possible to hit Ghost type Pokemon with Normal or Fighting type moves
    class Foresight < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return false
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Effects::Foresight.new(@logic, target))
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 369, target))
        end
      end
    end

    Move.register(:s_foresight, Foresight)
  end
end
