module Battle
  class Move
    # Move that binds the target to the field
    class CantSwitch < Basic
      private

      # Test if the effect is working
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Boolean]
      def effect_working?(user, actual_targets)
        return actual_targets.all? { |target| !target.effects.has?(:cantswitch) }
      end
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(:cantswitch)

          target.effects.add(Effects::CantSwitch.new(logic, target, user, self))
          scene.display_message_and_wait(message(target))
        end
      end

      # Get the message text
      # @return [String]
      def message(target)
        return parse_text_with_pokemon(19, 875, target)
      end
    end

    Move.register(:s_cantflee, CantSwitch)
  end
end
