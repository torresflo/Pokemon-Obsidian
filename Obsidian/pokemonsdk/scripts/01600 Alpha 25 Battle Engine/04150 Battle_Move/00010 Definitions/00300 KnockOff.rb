module Battle
  class Move
    # Move that inflict Knock Off to the ennemy
    class KnockOff < BasicWithSuccessfulEffect
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return @logic.item_change_handler.can_lose_item?(target, user) ? super * 1.5 : super
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return if user.dead?
        return unless @logic.battle_info.trainer_battle? || user.from_party?

        actual_targets.each do |target|
          next unless @logic.item_change_handler.can_lose_item?(target, user)

          additionnal_variables = {
            PFM::Text::ITEM2[2] => target.item_name,
            PFM::Text::PKNICK[1] => target.given_name
          }
          @scene.display_message_and_wait(parse_text_with_pokemon(19, 1056, user, additionnal_variables))
          if target.from_party?
            target.item_stolen = true
          else
            @logic.item_change_handler.change_item(:none, true, target)
          end
        end
      end
    end

    Move.register(:s_knock_off, KnockOff)
  end
end
