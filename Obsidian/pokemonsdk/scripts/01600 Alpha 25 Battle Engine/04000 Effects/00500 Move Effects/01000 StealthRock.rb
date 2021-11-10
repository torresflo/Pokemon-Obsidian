module Battle
  module Effects
    class StealthRock < PositionTiedEffectBase
      DMG_FACTOR = {
        0.25 => 3.125,
        0.5 => 6.25,
        1 => 12.5,
        2 => 25,
        4 => 50
      }
      # Create a new Sticky Web effect
      # @param logic [Battle::Logic]
      # @param bank [Integer] bank where the effect acts
      # @param move [Battle::Move::StealthRock]
      def initialize(logic, bank, move)
        super(logic, bank, 0)
        @move = move
      end

      # Function that tells if the move is affected by Rapid Spin
      # @return [Boolean]
      def rapid_spin_affected?
        return true
      end

      # Get the effect name
      # @return [Symbol]
      def name
        return :stealth_rock
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, @bank == 0 ? 164 : 165))
      end

      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        return if with.has_ability?(:magic_guard)

        calc_factor = @move.calc_factor(with) >= 1 ? @move.calc_factor(with).floor : @move.calc_factor(with)
        log_data("DMG_FACTOR: #{DMG_FACTOR[calc_factor]}")
        hp = (with.max_hp * DMG_FACTOR[calc_factor] / 100).floor.clamp(1, Float::INFINITY)
        handler.logic.damage_handler.damage_change(hp, with)
        handler.scene.display_message_and_wait(damage_message(with))
      end

      private

      # Get the message text
      # @param pokemon [PFM::PokemonBattler]
      # @return [String]
      def message(pokemon)
        return parse_text_with_pokemon(19, 1222, pokemon)
      end

      # Get the damage message text
      # @param pokemon [PFM::PokemonBattler]
      # @return [String]
      def damage_message(pokemon)
        return parse_text_with_pokemon(19, 857, pokemon)
      end
    end
  end
end
