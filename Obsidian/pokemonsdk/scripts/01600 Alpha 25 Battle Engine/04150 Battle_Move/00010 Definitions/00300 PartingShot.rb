module Battle
  class Move
    # Parting Shot lowers the opponent's Attack and Special Attack by one stage each, then the user switches out of battle.
    # @see https://pokemondb.net/move/parting-shot
    # @see https://bulbapedia.bulbagarden.net/wiki/Parting_Shot_(move)
    # @see https://www.pokepedia.fr/Dernier_Mot
    class PartingShot < Move
      # Tell if the move is a move that switch the user if that hit
      def self_user_switch?
        return true
      end

      private

      # Function that deals the stat to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_stats(user, actual_targets)
        actual_targets.each do |target|
          stat_to_change.each do |(stat, pow)|
            logic.stat_change_handler.stat_change_with_process(stat, pow, target, user, self)
          end
        end
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        return false unless @logic.switch_handler.can_switch?(user, self)

        @logic.switch_request << { who: user }
      end

      # List of the stats to change and the change power
      # @return [Array<Symbol, Integer>] [[stat, power]]
      def stat_to_change
        STATS_TO_CHANGE
      end

      STATS_TO_CHANGE = [
        [:atk, -1],
        [:ats, -1]
      ]
    end

    Move.register(:s_parting_shot, PartingShot)
  end
end
