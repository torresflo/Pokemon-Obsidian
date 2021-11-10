module Battle
  module Effects
    # Implement the flinch effect
    class Flinch < PokemonTiedEffectBase
      # Create a new Pokemon Attract effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      def initialize(logic, target)
        super(logic, target)
        self.counter = 1
      end

      # Function called when we try to use a move as the user (returns :prevent if user fails)
      # @param user [PFM::PokemonBattler]
      # @param targets [Array<PFM::PokemonBattler>]
      # @param move [Battle::Move]
      # @return [:prevent, nil] :prevent if the move cannot continue
      def on_move_prevention_user(user, targets, move)
        return if user != @pokemon

        move.scene.visual.show_rmxp_animation(user, 476)
        move.scene.display_message_and_wait(parse_text_with_pokemon(19, 363, user))
        return :prevent
      end

      # Function called when a status_prevention is checked
      # @param handler [Battle::Logic::StatusChangeHandler]
      # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
      # @param target [PFM::PokemonBattler]
      # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
      # @param skill [Battle::Move, nil] Potential move used
      # @return [:prevent, nil] :prevent if the status cannot be applied
      def on_status_prevention(handler, status, target, launcher, skill)
        return if status != :flinch || dead? || target != @pokemon

        return :prevent
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :flinch
      end
    end
  end
end
