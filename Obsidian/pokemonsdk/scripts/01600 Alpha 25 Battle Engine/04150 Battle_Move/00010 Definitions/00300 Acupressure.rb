module Battle
  class Move
    # Class that manage the Acupressure move
    # @see https://bulbapedia.bulbagarden.net/wiki/Acupressure_(move)
    # @see https://pokemondb.net/move/acupressure
    # @see https://www.pokepedia.fr/Acupression
    class Acupressure < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        select_stage = ->(target) { (Logic::StatChangeHandler::ALL_STATS.select { |s| @logic.stat_change_handler.stat_increasable?(s, target, user, self) }).sample(random: @logic.generic_rng) }
        @stages_ids = targets.map { |target| [target, select_stage.call(target)] }.to_h.compact
        return show_usage_failure(user) && false if @stages_ids.empty?

        return true
      end

      # All the stages that the move can modify
      # @return [Array[Symbol]]
      def stages
        Logic::StatChangeHandler::ALL_STATS
      end

      # Function that deals the stat to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_stats(user, actual_targets)
        actual_targets.each do |target|
          next unless @stages_ids[target]

          @logic.stat_change_handler.stat_change(@stages_ids[target], 2, target, user, self)
        end
      end
    end
    Move.register(:s_acupressure, Acupressure)
  end
end
