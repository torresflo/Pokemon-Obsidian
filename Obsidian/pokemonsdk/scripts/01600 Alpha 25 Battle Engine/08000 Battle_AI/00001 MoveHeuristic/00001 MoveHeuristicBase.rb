module Battle
  module AI
    # Class responsive of handling the heuristics of moves
    class MoveHeuristicBase
      # @type [Hash{ Symbol => Array }]
      @move_heuristics = {}

      # Create a new MoveHeusristicBase
      # @param ignore_effectiveness [Boolean] if this heuristic ignore effectiveness (wants to compute it themself)
      # @param ignore_power [Boolean] if this heuristic ignore power (wants to compute it themself)
      # @param overwrite_move_kind_flag [Boolean] if the effect overwrite (to true) the can see move kind flag
      def initialize(ignore_effectiveness = false, ignore_power = false, overwrite_move_kind_flag = false)
        @ignore_effectiveness = ignore_effectiveness
        @ignore_power = ignore_power
        @overwrite_move_kind_flag = overwrite_move_kind_flag
      end

      # Is this heuristic ignoring effectiveness
      # @return [Boolean]
      def ignore_effectiveness?
        return @ignore_effectiveness
      end

      # Is this heuristic ignoring power
      # @return [Boolean]
      def ignore_power?
        return @ignore_power
      end

      # Is this heuristic ignoring power
      # @return [Boolean]
      def overwrite_move_kind_flag?
        return @overwrite_move_kind_flag
      end

      # Compute the heuristic
      # @param move [Battle::Move]
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @param ai [Battle::AI::Base]
      # @return [Float]
      def compute(move, user, target, ai)
        return 1.0 if move.status?

        return Math.sqrt(move.special? ? user.ats_basis / target.dfs_basis.to_f : user.atk_basis / target.dfe_basis.to_f)
      end

      class << self
        # Register a new move heuristic
        # @param db_symbol [Symbol] db_symbol of the move
        # @param klass [Class<MoveHeuristicBase>, nil] klass holding the logic for this heuristic
        # @param min_level [Integer] minimum level when the heuristic acts
        # @note If there's several min_level, the highest condition matching with current AI level is choosen.
        def register(db_symbol, klass, min_level = 0)
          @move_heuristics[db_symbol] ||= []
          @move_heuristics[db_symbol].delete_if { |entry| entry[:min_level] == min_level }
          @move_heuristics[db_symbol] << { min_level: min_level, klass: klass } if klass
          @move_heuristics[db_symbol].sort_by! { |entry| -entry[:min_level] } # This will help to fetch the first min level matching with .find
        end

        # Get a MoveHeuristic by db_symbol and level
        # @param db_symbol [Symbol] db_symbol of the move
        # @param level [Integer] level of the current AI
        # @return [MoveHeuristicBase]
        def new(db_symbol, level)
          klass = @move_heuristics[db_symbol]&.find { |entry| entry[:min_level] <= level }
          klass = klass ? klass[:klass] : self
          heuristic = klass.allocate
          heuristic.send(:initialize)
          return heuristic
        end
      end
    end
  end
end
