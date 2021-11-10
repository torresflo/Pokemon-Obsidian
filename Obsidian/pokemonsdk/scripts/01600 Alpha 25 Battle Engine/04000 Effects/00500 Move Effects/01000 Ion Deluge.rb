module Battle
  module Effects
    # IonDeluge Effect
    class IonDeluge < EffectBase
      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic)
        super
        self.counter = 1
      end

      # Function called when we try to get the definitive type of a move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      # @param type [Integer] current type of the move (potentially after effects)
      # @return [Integer, nil] new type of the move
      def on_move_type_change(user, target, move, type)
        return GameData::Types::ELECTRIC if type == GameData::Types::NORMAL

        return nil
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :ion_deluge
      end
    end
  end
end
