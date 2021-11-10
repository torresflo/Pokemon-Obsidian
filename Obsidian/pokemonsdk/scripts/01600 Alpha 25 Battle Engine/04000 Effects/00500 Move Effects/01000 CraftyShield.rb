module Battle
  module Effects
    # Implement Crafty Shield effect that protects Pokemon from status moves
    class CraftyShield < PokemonTiedEffectBase
      # Function called when we try to check if the target evades the move
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler] expected target
      # @param move [Battle::Move]
      # @return [Boolean] if the target is evading the move
      def on_move_prevention_target(user, target, move)
        return false unless @pokemon == target && move.status? && user != target && move.db_symbol != :curse

        move.scene.display_message_and_wait(parse_text_with_pokemon(19, 803, target))
        return true
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :crafty_shield
      end
    end
  end
end
