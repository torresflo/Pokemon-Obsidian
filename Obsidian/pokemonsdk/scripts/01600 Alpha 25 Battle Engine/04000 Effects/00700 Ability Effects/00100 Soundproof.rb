module Battle
  module Effects
    class Ability
      class Soundproof < Ability
        # Function called when we try to check if the effect changes the definitive priority of the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Boolean] if the target is immune to the move
        def on_move_ability_immunity(user, target, move)
          return false if target != @target

          return move.sound_attack? && user.can_be_lowered_or_canceled?
        end
      end
      register(:soundproof, Soundproof)
    end
  end
end
