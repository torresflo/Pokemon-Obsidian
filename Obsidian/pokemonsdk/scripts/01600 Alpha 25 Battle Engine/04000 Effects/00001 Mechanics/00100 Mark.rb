module Battle
  module Effects
    module Mechanics
      # Effect linked to another, if the other die, this one dies too.
      #
      # **Requirement**
      # - Call initialize_mark
      module Mark
        # Get the origin mark
        # @return [EffectBase]
        attr_reader :mark_origin

        # Initialize the mechanic
        # @param origin [EffectBase]
        def initialize_mark(origin)
          @mark_origin = origin
        end

        # Tell if the effect is dead
        # @return [Boolean]
        def dead?
          super || @mark_origin.dead?
        end
        alias mark_dead? dead?
      end
    end
  end
end
