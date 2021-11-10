module Battle
  module Effects
    class Ability
      class GaleWings < Ability
        # Function called when we try to check if the effect changes the definitive priority of the move
        # @param user [PFM::PokemonBattler]
        # @param priority [Integer]
        # @param move [Battle::Move]
        # @return [Proc, nil]
        def on_move_priority_change(user, priority, move)
          return nil if user != @target
          return nil unless move.type_fly? && user.hp == user.max_hp

          return priority + 1
        end
      end
      register(:gale_wings, GaleWings)
    end
  end
end
