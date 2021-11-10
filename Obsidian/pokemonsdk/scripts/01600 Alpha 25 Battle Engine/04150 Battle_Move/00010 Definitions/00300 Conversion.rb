module Battle
  class Move
    # Move that sets the type of the Pokemon as type of the first move
    class Conversion < BasicWithSuccessfulEffect
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        target = actual_targets.first
        target.type1 = user.moveset.first&.type || 0
        target.type2 = 0
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 899, target, '[VAR TYPE(0001)]' => GameData::Type[target.type1].name))
      end
    end

    # Move that sets the type of the Pokemon as type of the last move used by target
    class Conversion2 < BasicWithSuccessfulEffect
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.none? { |target| target.move_history.any? }
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
        # @type [PFM::PokemonBattler]
        last_move_user = actual_targets.find { |target| target.move_history.any? }
        user.type1 = last_move_user&.move_history&.last&.move&.type || 0
        user.type2 = 0
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 899, user, '[VAR TYPE(0001)]' => GameData::Type[user.type1].name))
      end
    end

    Move.register(:s_conversion, Conversion)
    Move.register(:s_conversion2, Conversion2)
  end
end
