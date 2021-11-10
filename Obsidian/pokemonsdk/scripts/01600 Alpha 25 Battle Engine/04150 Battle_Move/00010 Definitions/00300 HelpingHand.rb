module Battle
  class Move
    # In Double Battles, boosts the power of the partner's move.
    # @see https://pokemondb.net/move/helping-hand
    # @see https://bulbapedia.bulbagarden.net/wiki/Helping_Hand_(move)
    # @see https://www.pokepedia.fr/Coup_d%27Main
    class HelpingHand < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if targets.reject { |t| t == user }.empty?

        return true
      end

      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if target.effects.has?(:helping_hand_mark)

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          user.effects.add(create_effect(user, target))
          scene.display_message_and_wait(deal_message(user, target))
        end
      end

      # Create the effect given to the target
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] targets that will be affected by the move
      # @return [Effects::EffectBase]
      def create_effect(user, target)
        Effects::HelpingHand.new(logic, user, target, 1)
      end

      # Message displayed when the effect is dealt to the target
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [String]
      def deal_message(user, target)
        parse_text_with_2pokemon(19, 1050, user, target)
      end
    end
    Move.register(:s_helping_hand, HelpingHand)
  end
end
