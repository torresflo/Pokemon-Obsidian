module Battle
  module Effects
    # Implement the Foresight effect
    # Foresight - Odor Sleuth
    class Disable < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move] move that is disabled
      def initialize(logic, pokemon, move)
        super(logic, pokemon)
        @move = move
        self.counter = 4
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        message = parse_text_with_pokemon(19, 598, @pokemon, PFM::Text::MOVE[1] => @move.name)
        @logic.scene.display_message_and_wait(message)
      end

      # Function called when we try to check if the user cannot use a move
      # @param user [PFM::PokemonBattler]
      # @param move [Battle::Move]
      # @return [Proc, nil]
      def on_move_disabled_check(user, move)
        return if user != @pokemon || move != @move

        return proc {
          @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 595, user, PFM::Text::MOVE[1] => move.name))
        }
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :disable
      end
    end
  end
end
