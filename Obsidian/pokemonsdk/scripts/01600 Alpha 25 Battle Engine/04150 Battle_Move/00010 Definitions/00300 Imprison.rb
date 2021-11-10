module Battle
  class Move
    # Opponent is unable to use moves that the user also knows.
    # @see https://pokemondb.net/move/imprison
    # @see https://bulbapedia.bulbagarden.net/wiki/Imprison_(move)
    # @see https://www.pokepedia.fr/Possessif
    class Imprison < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if targets.all? { |target| user.effects.get(:imprison)&.targetted?(target) }

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next if user.effects.has?(:imprison)

          user.effects.add(Effects::Imprison.new(logic, target))
          scene.display_message_and_wait(deal_message(user, target))
        end
      end

      # Message displayed when the effect is dealt
      # @param user [PFM::PokemonBattler]
      # @param actual_targets [Array<PFM::PokemonBattler>]
      # @return [String]
      def deal_message(user, actual_targets)
        parse_text_with_pokemon(19, 586, user)
      end
    end
    Move.register(:s_imprison, Imprison)
  end
end
