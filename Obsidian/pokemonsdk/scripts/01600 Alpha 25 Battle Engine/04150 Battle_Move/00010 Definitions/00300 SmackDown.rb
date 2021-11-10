module Battle
  class Move
    # Move that deals damage and knocks the target to the ground
    class SmackDown < Basic
      private

      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        return false if actual_targets.all?(&:grounded?)
        return false if actual_targets.all? { |target| target.effects.has?(:substitute) }

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.grounded? || target.effects.has?(:substitute)

          # TODO: Add Sky Drop exception
          target.effects.add(Effects::SmackDown.new(@scene.logic, target))
          scene.display_message_and_wait(parse_text_with_pokemon(19, 1134, target))
        end
      end
    end

    Move.register(:s_smack_down, SmackDown)
  end
end
