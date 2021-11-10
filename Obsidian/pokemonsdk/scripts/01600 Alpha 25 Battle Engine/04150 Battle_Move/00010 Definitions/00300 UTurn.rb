module Battle
  class Move
    # Class managing moves that allow a Pokemon to hit and switch
    class UTurn < Move
      # Tell if the move is a move that switch the user if that hit
      def self_user_switch?
        return true
      end

      private

      # Function that deals the damage to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_damage(user, actual_targets)
        # Status move does not deal damages
        return true if status?
        raise 'Badly configured move, it should have positive power' if power < 0

        actual_targets.each do |target|
          hp = damages(user, target)
          @logic.damage_handler.damage_change_with_process(hp, target, user, self) do
            if critical_hit?
              scene.display_message_and_wait(actual_targets.size == 1 ? parse_text(18, 84) : parse_text_with_pokemon(19, 384, target))
            elsif hp > 0
              efficent_message(effectiveness, target)
            end
          end
          recoil(hp, user) if recoil?
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return false unless @logic.switch_handler.can_switch?(user, self)
        return false if user.item_effect.is_a?(Effects::Item::RedCard)
        return false if actual_targets.any? { |target| target.item_effect.is_a?(Effects::Item::EjectButton) }

        @logic.switch_request << { who: user }
      end
    end

    Move.register(:s_u_turn, UTurn)
  end
end
