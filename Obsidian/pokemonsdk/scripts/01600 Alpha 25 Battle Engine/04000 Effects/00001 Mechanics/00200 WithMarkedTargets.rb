module Battle
  module Effects
    module Mechanics
      # Store targets informations
      #
      # **Requirement**
      # - Call initialize_with_marked_targets
      #
      # **Initialization exemple**
      # ```ruby
      # # Inside EffectBase child class
      # initialize_with_marked_targets(targets) { |target| YourMarkEffect.new(logic, self, user, target) }
      # ```
      module WithMarkedTargets
        include Mechanics::WithTargets

        # Initialize the mechanic
        # @param user [PFM::PokemonBattler, nil]
        # @param targets [Array<PFM::PokemonBattler>]
        # @param block [Proc] block taking one argument (PFM::PokemonBattler) and return an EffectBase
        def initialize_with_marked_targets(user, targets, &block)
          initialize_with_targets(targets)
          @wmt_user = user
          targets.each { |target| target.effects.add(block.call(target)) }
        end

        # The launcher of this effect
        # @return [PFM::PokemonBattler, nil]
        def launcher
          @wmt_user
        end

        # Tell if the effect is dead
        # @return [Boolean]
        def dead?
          super || !@wt_targets.all?(&:position) || @wt_targets.all?(&:dead?)
        end
        alias wmt_dead? dead?
      end
    end
  end
end
