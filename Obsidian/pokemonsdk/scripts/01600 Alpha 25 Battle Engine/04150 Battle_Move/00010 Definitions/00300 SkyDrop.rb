module Battle
  class Move
    # Sky Drop takes the target into the air on the first turn, then drops them on the second turn, wherein they receive damage.
    # @see https://pokemondb.net/move/sky-drop
    # @see https://bulbapedia.bulbagarden.net/wiki/Sky_Drop_(move)
    # @see https://www.pokepedia.fr/Chute_Libre
    class SkyDrop < Basic
      include Mechanics::TwoTurn

      private

      # Return the list of the moves that can reach the pokemon event in out_of_reach, nil if all attack reach the user
      # @return [Array<Symbol>]
      CAN_HIT_MOVES = %i[gust hurricane sky_uppercut smack_down thunder twister]

      # Return the list of the moves that can reach the pokemon event in out_of_reach, nil if all attack reach the user
      # @return [Array<Symbol>]
      def can_hit_moves
        CAN_HIT_MOVES
      end

      # @param super_result [Boolean] the result of original method
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_userturn1(super_result, user, targets)
        return show_usage_failuer(user) && false if @logic.terrain_effects.has?(:gravity)

        return two_turn_move_usable_by_userturn1(super_result, user, targets)
      end

      # Display the message and the animation of the turn
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def proceed_message_turn1(user, targets)
        targets.each do |target|
          @scene.display_message_and_wait(parse_text_with_2pokemon(19, 1124, user, target))
        end
      end

      # Add the effects to the pokemons (first turn)
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      def deal_effects_turn1(user, targets)
        two_turn_deal_effects_turn1(user, targets)
        # TODO: check if that's allright but to me effect from move the should prevent a target from moving should be applied to targets
        targets.each do |target|
          target.effects.add(Effects::PreventTargetsMove.new(@logic, target, targets, 1))
        end
      end
    end
    Move.register(:s_sky_drop, SkyDrop)
  end
end
