module Battle
  module Effects
    # Implement the Miracle Eye effect
    class MiracleEye < PokemonTiedEffectBase
      # Function that computes an overwrite of the type multiplier
      # @param target [PFM::PokemonBattler]
      # @param target_type [Integer] one of the type of the target
      # @param type [Integer] one of the type of the move
      # @param move [Battle::Move]
      # @return [Float, nil] overwriten type multiplier
      def on_single_type_multiplier_overwrite(target, target_type, type, move)
        return if target != @pokemon || target_type != GameData::Types::DARK

        return 1 if type == GameData::Types::PSYCHIC

        return nil
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :miracle_eye
      end
    end
  end
end
