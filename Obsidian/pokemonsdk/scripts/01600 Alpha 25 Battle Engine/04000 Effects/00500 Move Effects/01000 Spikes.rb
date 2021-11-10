module Battle
  module Effects
    class Spikes < PositionTiedEffectBase
      # Get the Spike power
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
        return :spikes
      end

      # Tell if the spikes are at max power
      # @return [Boolean]
      def max_power?
        return @power >= 3
      end

      # Increase the spike power
      def empower
        @power += 1 unless max_power?
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, @bank == 0 ? 156 : 157))
      end

      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        return unless with.grounded?
        return if with.has_ability?(:magic_guard)

        factor = 10 - power * 2 # 8 -> 6 -> 4
        hp = (with.max_hp / factor).clamp(1, Float::INFINITY)
        handler.logic.damage_handler.damage_change(hp, with)
        handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 854, with))
      end
    end
  end
end
