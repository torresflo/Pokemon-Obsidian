module Battle
  module Effects
    module Mechanics
      # Store targets informations
      #
      # **Requirement**
      # - Call initialize_with_targets
      module WithTargets
        # Init the mechanic
        # @param targets [Array<PFM::PokemonBattler>, PFM::PokemonBattler] battler targetted by the effect
        def initialize_with_targets(targets)
          @wt_targets = [targets].flatten
        end

        # Tell if the given battler is targetted by the effect
        # @param battler [PFM::PokemonBattler]
        # @return [Boolean]
        def targetted?(battler)
          return @wt_targets.include?(battler)
        end
        alias with_targets_targetted? targetted?
      end
    end
  end
end
