module GamePlay
  # Module defining the IO of the evolve scene so user know what to expect
  module EvolveMixin
    # Tell if the Pokemon evolved
    # @return [Boolean]
    attr_accessor :evolved
  end
end

GamePlay.evolve_mixin = GamePlay::EvolveMixin
