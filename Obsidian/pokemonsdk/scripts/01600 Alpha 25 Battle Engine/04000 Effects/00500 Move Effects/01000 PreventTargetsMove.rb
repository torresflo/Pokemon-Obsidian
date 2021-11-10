module Battle
  module Effects
    class PreventTargetsMove < PokemonTiedEffectBase
      include Mechanics::WithTargets

      # Create a new effect
      # @param logic [Battle::Logic] logic used to get all the handler in order to allow the effect to work
      def initialize(logic, user, targets, duration = 1)
        super(logic, user)
        initialize_with_targets(targets)
        self.counter = duration
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return :prevent if targetted?(user)
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :prevent_targets_move
      end
    end
  end
end
