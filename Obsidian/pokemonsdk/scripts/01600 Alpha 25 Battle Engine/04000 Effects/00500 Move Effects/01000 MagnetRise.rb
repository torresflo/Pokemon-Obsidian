module Battle
  module Effects
    # User becomes immune to Ground-type moves for N turns.
    class MagnetRise < PokemonTiedEffectBase
      include Mechanics::ForceFlying

      # Make to pokemon flying in grounded? test
      Mechanics::ForceFlying.register_force_flying_hook('PSDK flying: Magnet Rise', :magnet_rise)

      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param duration [Integer] (default: 5) duration of the move (including the current turn)
      def initialize(logic, pokemon, duration = 5)
        super(logic, pokemon)
        force_flying_initialize(duration)
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :magnet_rise
      end

      private

      # Message displayed when the effect procs
      # @return [String]
      def on_proc_message
        parse_text_with_pokemon(19, 658, @pokemon)
      end

      # Message displayed when the effect wear off
      # @return [String]
      def on_delete_message
        parse_text_with_pokemon(19, 661, @pokemon)
      end
    end
  end
end