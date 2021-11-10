module Battle
  class Move
    # class managing HappyHour move
    class HappyHour < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false if logic.terrain_effects.has?(:happy_hour)

        return true
      end

      # Function that deals the effect to the pokemon
      # @param _user [PFM::PokemonBattler] user of the move
      # @param _actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(_user, _actual_targets)
        logic.terrain_effects.add(Effects::HappyHour.new(logic))
        scene.display_message_and_wait(parse_text(18, 255))
      end
    end

    Move.register(:s_happy_hour, HappyHour)
  end
end
