module Battle
  module Effects
    # The user's party is protected from status conditions.
    class Safeguard < LightScreen
      # Get the name of the effect
      # @return [Symbol]
      def name
        :safeguard
      end

      # Function called when a status_prevention is checked
      # @param handler [Battle::Logic::StatusChangeHandler]
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the status cannot be applied
      def on_status_prevention(handler, status, target, launcher, skill)
        return if status == :cure
        return @logic.scene.visual.show_ability(launcher) if launcher&.has_ability?(:infiltrator) # Infiltrator bypass safeguard
        return if item_exceptions.include?(target.item_db_symbol) # Status item held
        return if move_exceptions.include?(skill&.db_symbol) # Induced statut from the pokemon's move (Outrage, etc)
        return if skill&.db_symbol == :yawn
        return if status == :sleep && target.effects.has?(:drowsiness)
        # return unless target.item_consumed && target.consumed_item != :__undef__ # Berry consumed @todo

        @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, status_prevention_message_id, target))
        return :prevent
      end

      private

      # Items that procs status even with Safeguard activated
      # @return [Array<Symbol>]
      ITEM_EXCEPTIONS = %i[flame_orb toxic_orb]

      # Items that procs status even with Safeguard activated
      # @return [Array<Symbol>]
      MOVE_EXCEPTIONS = %i[petal_dance outrage thrash]

      # Items that procs status even with Safeguard activated
      # @return [Array<Symbol>]
      def item_exceptions
        ITEM_EXCEPTIONS
      end

      # Items that procs status even with Safeguard activated
      # @return [Array<Symbol>]
      def move_exceptions
        MOVE_EXCEPTIONS
      end

      # ID of the message responsive of telling the end of the effect
      # @return [Integer]
      def message_id
        return 140
      end

      # ID of the message responsive of telling when the effect prevent a status
      def status_prevention_message_id
        return 842
      end
    end
  end
end