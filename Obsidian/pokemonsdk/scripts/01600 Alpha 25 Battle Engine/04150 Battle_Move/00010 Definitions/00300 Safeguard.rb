module Battle
  class Move
    # The user's party is protected from status conditions.
    # @see https://pokemondb.net/move/safeguard
    # @see https://bulbapedia.bulbagarden.net/wiki/Safeguard
    # @see https://www.pokepedia.fr/Rune_Protect
    class Safeguard < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if logic.bank_effects[user.bank].has?(effect_name)

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if logic.bank_effects[target.bank].has?(effect_name)

          logic.bank_effects[target.bank].add(create_effect(user, target))
          scene.display_message_and_wait(deal_message(user, target))
        end
      end

      # Duration of the effect including the current turn
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def create_effect(user, target)
        Effects::Safeguard.new(logic, target.bank, 0, 5)
      end

      # Id of the message after the animation
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def deal_message(user, target)
        parse_text_with_pokemon(18, 138, target)
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :safeguard
      end
    end
    Move.register(:s_safe_guard, Safeguard)
  end
end
