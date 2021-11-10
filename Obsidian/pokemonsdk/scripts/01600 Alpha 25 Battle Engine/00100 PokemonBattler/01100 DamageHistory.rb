module PFM
  class PokemonBattler
    # Class defining an history of damages took
    class DamageHistory
      # Get the turn when it was used
      # @return [Integer]
      attr_reader :turn
      # Get the amount of damage took
      # @return [Integer]
      attr_reader :damage
      # Get the launcher that cause the damages
      # @return [PFM::PokemonBattler, nil]
      attr_reader :launcher
      # Get the move that cause the damages
      # @return [Battle::Move, nil]
      attr_reader :move
      # Get if the Pokemon was knocked out
      # @return [Boolean]
      attr_reader :ko

      # Create a new Damage History
      # @param damage [Integer]
      # @param launcher [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @param ko [Boolean]
      def initialize(damage, launcher, move, ko)
        @turn = $game_temp.battle_turn
        @damage = damage
        @launcher = launcher
        @move = move
        @ko = ko
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
    end
  end
end
