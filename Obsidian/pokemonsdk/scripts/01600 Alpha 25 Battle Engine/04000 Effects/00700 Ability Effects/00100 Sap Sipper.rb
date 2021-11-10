module Battle
  module Effects
    class Ability
      class SapSipper < Ability
        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false if target != @target
          return false unless move.type_grass? && move.db_symbol != :aromatherapy
          return false unless user.can_be_lowered_or_canceled?

          move.scene.visual.show_ability(target)
          move.logic.stat_change_handler.stat_change_with_process(:atk, 1, target, user, move)
          return true
        end
      end
      register(:sap_sipper, SapSipper)
    end
  end
end
