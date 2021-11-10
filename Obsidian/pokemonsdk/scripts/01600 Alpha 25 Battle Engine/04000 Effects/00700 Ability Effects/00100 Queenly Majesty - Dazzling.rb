module Battle
  module Effects
    class Ability
      class QueenlyMajesty < Ability
        # Function called when we try to check if the target evades the move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @return [Boolean] if the target is evading the move
        def on_move_prevention_target(user, target, move)
          return false if target.bank != @target.bank
          return false unless move.relative_priority >= 1 && move.blocable?
          return false unless user.can_be_lowered_or_canceled?

          move.scene.visual.show_ability(@target)
          move.scene.display_message_and_wait(parse_text_with_pokemon(19, 911, user, '[VAR MOVE(0001)]' => move.name))
          return true
        end
      end
      register(:queenly_majesty, QueenlyMajesty)
      register(:dazzling, QueenlyMajesty)
    end
  end
end
