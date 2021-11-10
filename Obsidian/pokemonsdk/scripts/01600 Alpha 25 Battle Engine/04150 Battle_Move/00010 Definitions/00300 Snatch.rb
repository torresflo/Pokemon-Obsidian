module Battle
  class Move
    # Snatch moves first and steals the effects of the next status move used by the opponent(s) in that turn.
    # @see https://pokemondb.net/move/snatch
    # @see https://bulbapedia.bulbagarden.net/wiki/Snatch_(move)
    # @see https://www.pokepedia.fr/Saisie
    class Snatch < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if targets.all? { |pkm| pkm.effects.has?(effect_name) }

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if target.effects.has?(effect_name)

          target.effects.add(create_effect(user, target))
          scene.display_message_and_wait(deal_message(user, target))
        end
      end

      # Name of the effect
      # @return [Symbol]
      def effect_name
        :snatch
      end

      # Create the effect
      # @return [Battle::Effects::EffectBase]
      def create_effect(user, target)
        return Effects::Snatch.new(logic, target)
      end

      # Message displayed when the move succeed
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler]
      # @return [String]
      def deal_message(user, target)
        parse_text_with_pokemon(19, 751, target)
      end
    end
    Move.register(:s_snatch, Snatch)
  end
end
