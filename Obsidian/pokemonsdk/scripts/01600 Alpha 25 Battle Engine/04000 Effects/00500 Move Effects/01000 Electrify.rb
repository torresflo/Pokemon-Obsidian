module Battle
  module Effects
    # Implement the change type effect (Electrify)
    class Electrify < PokemonTiedEffectBase
      # Get the type ID that replace the moves
      # @return [Integer]
      attr_reader :type
      # Create a new Electrify effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      # @param type [Integer]
      def initialize(logic, target, type = GameData::Types::ELECTRIC)
        super(logic, target)
        @type = type
        self.counter = 1
      end

      # Function called when we try to get the definitive type of a move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      # @param type [Integer] current type of the move (potentially after effects)
      # @return [Integer, nil] new type of the move
      def on_move_type_change(user, target, move, type)
        return user == @pokemon ? @type : nil
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :change_type
      end
    end
  end
end
