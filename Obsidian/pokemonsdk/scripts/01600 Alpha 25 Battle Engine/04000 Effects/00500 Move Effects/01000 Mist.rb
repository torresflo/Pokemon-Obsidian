module Battle
  module Effects
    class Mist < PositionTiedEffectBase
      # Create a new Mist effect
      # @param logic [Battle::Logic]
      # @param bank [Integer] bank where the effect acts
      def initialize(logic, bank)
        super(logic, bank, 0)
        self.counter = 5
      end

      # Get the effect name
      # @return [Symbol]
      def name
        return :mist
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @logic.scene.display_message_and_wait(parse_text(18, @bank == 0 ? 144 : 145))
      end

      # Function called when a stat_decrease_prevention is checked
      # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
      # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the stat decrease cannot apply
      def on_stat_decrease_prevention(handler, stat, target, launcher, skill)
        return if target.bank != @bank
        return if launcher&.bank == @bank

        return handler.prevent_change do
          @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 845, target))
        end
      end
    end
  end
end
