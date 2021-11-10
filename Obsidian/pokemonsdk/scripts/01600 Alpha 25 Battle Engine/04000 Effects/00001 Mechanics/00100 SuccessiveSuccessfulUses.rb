module Battle
  module Effects
    module Mechanics
      module SuccessiveSuccessfulUses
        # Return the number of successive succesful use of the move.
        # @return [Integer]
        def successive_uses
          return @successive_uses if @pokemon.move_history.last&.last_turn? && @pokemon.last_successfull_move_is?(@move_db_symbol)
          if @pokemon.move_history.last&.last_turn? && accepted_moves.any? { |move_sym| @pokemon.last_successfull_move_is?(move_sym) }
            return @successive_uses
          end

          return @successive_uses = 0
        end

        # Increase the successive uses by one
        def increase
          @successive_uses += 1
        end

        private

        # Init the successive uses module
        # @param pokemon [PFM::PokemonBattler]
        # @param move [Battle::Move]
        def init_successive_successful_uses(pokemon, move)
          @pokemon = pokemon
          @successive_uses = 0
          @move_db_symbol = move.db_symbol
        end

        # List of the moves that don't break the continuity and don't increment
        ACCEPTED_MOVES = %i[mirror_move]

        # List of the moves that don't break the continuity and don't increment
        # @return [Array[Symbol]]
        def accepted_moves
          ACCEPTED_MOVES
        end
      end
    end
  end
end
