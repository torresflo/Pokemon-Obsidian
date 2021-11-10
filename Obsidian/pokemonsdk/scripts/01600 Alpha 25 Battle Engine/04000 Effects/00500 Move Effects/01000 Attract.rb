module Battle
  module Effects
    # Implement the attract effect
    class Attract < PokemonTiedEffectBase
      # Get the Pokemon who's this Pokemon is attracted to
      # @return [PFM::PokemonBattler]
      attr_reader :attracted_to
      # Create a new Pokemon Attract effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      # @param attracted_to [PFM::PokemonBattler]
      def initialize(logic, target, attracted_to)
        super(logic, target)
        @attracted_to = attracted_to
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if user != @pokemon
        return unless targets.include?(@attracted_to)

        move.scene.display_message_and_wait(parse_text_with_pokemon(19, 333, user, PFM::Text::PKNICK[1] => @attracted_to.given_name))
        if bchance?(0.5)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 336, user))
          return :prevent
        end
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :attract
      end
    end
  end
end
