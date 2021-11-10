module Battle
  module Effects
    module Mechanics
      # Neutralize Type Effect
      #
      # **Includer requirements**
      # - call neutralize_type_initialize
      # - def neutralyzed_type
      module NeutralizeType
        # Create a new effect
        # @param target [PFM::PokemonBattler]
        # @param turn_count [Integer]
        def neutralize_type_initialize(target, turn_count)
          @target = target
          target.ignore_types(*neutralyzed_types)
          self.counter = turn_count
        end

        # Show the message when the effect gets deleted
        def on_delete
          @target.restore_types
        end
        alias neutralize_type_on_delete on_delete

        private

        # Get the neutralized types
        # @return [Array<Integer>]
        def neutralyzed_types
          log_error("#{__method__} should be overwritten by #{self.class}")
          return [0]
        end
      end
    end
  end
end
