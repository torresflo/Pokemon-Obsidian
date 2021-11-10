module Battle
  module Effects
    class ToxicSpikes < PositionTiedEffectBase
      # Get the Toxic Spikes power
      # @return [Integer]
      attr_reader :power
      # Create a new spike effect
      # @param logic [Battle::Logic]
      # @param bank [Integer] bank where the effect acts
      def initialize(logic, bank)
        super(logic, bank, 0)
        @power = 1
      end

      # Function that tells if the move is affected by Rapid Spin
      # @return [Boolean]
      def rapid_spin_affected?
        return true
      end

      # Get the effect name
      # @return [Symbol]
      def name
        return :toxic_spikes
      end

      # Increase the spike power
      def empower
        @power += 1
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, @bank == 0 ? 160 : 161))
      end

      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        return unless with.grounded?
        return if with.has_ability?(:magic_guard)

        status = @power == 1 ? :poison : :toxic
        handler.logic.status_change_handler.status_change_with_process(status, with)
      end
    end
  end
end
