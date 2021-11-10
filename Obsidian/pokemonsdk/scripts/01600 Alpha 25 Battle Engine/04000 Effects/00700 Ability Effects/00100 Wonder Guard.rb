module Battle
  module Effects
    class Ability
      class WonderGuard < Ability
        # Function called when we try to check if the effect changes the definitive priority of the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Boolean] if the target is immune to the move
        def on_move_ability_immunity(user, target, move)
          return false if target != @target

          check = move.type_modifier(user, target) <= 1 && move.real_base_power(user, target) != 0 && user.can_be_lowered_or_canceled?
          @logic.scene.visual.show_ability(@target) if check
          return check
        end
      end
      register(:wonder_guard, WonderGuard)
    end
  end
end
