module PFM
  class PokemonBattler
    # Class defining an history of move use
    class MoveHistory
      # Get the turn when it was used
      # @return [Integer]
      attr_reader :turn
      # Get the move that was used
      # @return [Battle::Move]
      attr_reader :move
      # Get the target that were affected by the move
      # @return [Array<PFM::PokemonBattler>]
      attr_reader :targets
      # Get the actual move object that was used
      # @return [Battle::Move]
      attr_reader :original_move
      # Get the attack order of the Pokemon
      # @return [Integer]
      attr_reader :attack_order

      # Create a new Move History
      # @param move [Battle::Move]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param attack_order [Integer]
      def initialize(move, targets, attack_order)
        @original_move = move
        @move = move.dup
        @turn = $game_temp.battle_turn
        @targets = targets
        @attack_order = attack_order
      end

      # Tell if the move was used during last turn
      # @return [Boolean]
      def last_turn?
        return @turn == $game_temp.battle_turn - 1
      end

      # Tell if the move was used during the current turn
      # @return [Boolean]
      def current_turn?
        return @turn == $game_temp.battle_turn
      end

      # Get the db_symbol of the move
      # @return [Symbol]
      def db_symbol
        return @move.db_symbol
      end
    end
  end
end
