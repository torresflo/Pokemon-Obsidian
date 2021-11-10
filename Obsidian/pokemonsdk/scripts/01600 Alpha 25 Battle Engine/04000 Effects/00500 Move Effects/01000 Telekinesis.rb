module Battle
  module Effects
    # Telekinesis raises the target into the air for three turns, guaranteeing that all attacks against 
    # the target (except OHKO moves) will hit, regardless of Accuracy or Evasion.
    # @see https://pokemondb.net/move/telekinesis
    # @see https://bulbapedia.bulbagarden.net/wiki/Telekinesis_(move)
    # @see https://www.pokepedia.fr/L%C3%A9vikin%C3%A9sie
    # @see [Move::Telekinesis]
    class Telekinesis < PokemonTiedEffectBase
      include Mechanics::ForceFlying

      # Make to pokemon flying in grounded? test
      Mechanics::ForceFlying.register_force_flying_hook('PSDK flying: Telekinesis', :telekinesis)

      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param duration [Integer] (default: 3) duration of the move (including the current turn)
      def initialize(logic, pokemon, duration = 3)
        super(logic, pokemon)
        force_flying_initialize(duration)
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :telekinesis
      end

      private

      # Message displayed when the effect wear off
      # @return [String]
      def on_delete_message
        parse_text_with_pokemon(19, 1149, @pokemon)
      end
    end
  end
end
