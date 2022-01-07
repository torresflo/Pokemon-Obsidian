module Battle
  class Move
    # Future Sight deals damage, but does not hit until two turns after the move is used. 
    # If the opponent switched Pokémon in the meantime, the new Pokémon gets hit, 
    # with their type and stats taken into account.
    # @see https://pokemondb.net/move/future-sight
    # @see https://bulbapedia.bulbagarden.net/wiki/Future_Sight_(move)
    # @see https://www.pokepedia.fr/Prescience
    class FutureSight < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if targets.all? { |t| @logic.position_effects[t.bank][t.position].has?(effect_name) }

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        log_data("FutureSight targets : #{actual_targets}")
        actual_targets.each do |target|
          next if @logic.position_effects[target.bank][target.position].has?(effect_name)

          @logic.add_position_effect(create_effect(user, target))
          @scene.display_message_and_wait(deal_message(user, target))
        end
      end

      # Name of the effect dealt by the move
      # @return [Symbol]
      def effect_name
        :future_sight
      end

      # Hash containing the countdown for each "Future Sight"-like move
      # @return [Hash]
      COUNTDOWN = {
        futuresight: 3
      }

      # Return the right countdown depending on the move, or a static one
      # @return [Integer]
      def countdown
        return COUNTDOWN[db_symbol] || 3
      end

      # Create the effect
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @return [Effects::PositionTiedEffectBase]
      def create_effect(user, target)
        Effects::FutureSight.new(@logic, target.bank, target.position, countdown, damages(user, target))
      end

      # Message displayed when the effect is dealt
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      def deal_message(user, target)
        parse_text_with_pokemon(19, 1080, user)
      end
    end
    Move.register(:s_future_sight, FutureSight)
  end
end
