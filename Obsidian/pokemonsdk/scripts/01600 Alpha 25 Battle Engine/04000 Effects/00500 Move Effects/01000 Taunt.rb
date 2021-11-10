module Battle
  module Effects
    # Implement the Taunt effect
    class Taunt < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      def initialize(logic, pokemon)
        super(logic, pokemon)
        self.counter = 3
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        message = parse_text_with_pokemon(19, 574, @pokemon)
        @logic.scene.display_message_and_wait(message)
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if user != @pokemon || user.has_ability?(:oblivious)

        if move.status?
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 571, user, PFM::Text::MOVE[1] => move.name))
          return :prevent
        end
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :taunt
      end
    end
  end
end
