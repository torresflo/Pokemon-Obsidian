module Battle
  module Effects
    # Implement the Powder effect
    class Powder < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      def initialize(logic, pokemon)
        super
        self.counter = 1
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if user != @pokemon
        return unless move.type_fire?

        move.send(:usage_message, user)
        # TODO: show explosion animation
        @logic.scene.display_message_and_wait(parse_text(18, 259, PFM::Text::MOVE[0] => move.name))
        @logic.damage_handler.damage_change((user.max_hp / 4).clamp(1, Float::INFINITY), user)

        return :prevent
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :powder
      end
    end
  end
end
