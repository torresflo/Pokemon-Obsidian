module Battle
  class Move
    # Class that manage the Flower Shield move
    # @see https://bulbapedia.bulbagarden.net/wiki/Flower_Shield_(move)
    # @see https://pokemondb.net/move/flower-shield
    # @see https://www.pokepedia.fr/Garde_Florale
    class FlowerShield < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user?(user, targets)
        return false unless super
        return show_usage_failure(user) && false unless targets.any? {|target| target.type_grass? && !target.effects.has?(&:out_of_reach?)}

        return true
      end

      # Function that tests if the targets blocks the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] expected target
      # @note Thing that prevents the move from being used should be defined by :move_prevention_target Hook.
      # @return [Boolean] if the target evade the move (and is not selected)
      def move_blocked_by_target?(user, target)
        return super || !target.type_grass? || target.effects.has?(&:out_of_reach?)
      end

      private

      # Function that deals the stat to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_stats(user, actual_targets)
        actual_targets.each do |target|
          @logic.stat_change_handler.stat_change_with_process(:dfe, 1, target, user, self)
        end
      end
    end
    Move.register(:s_flower_shield, FlowerShield)
  end
end
