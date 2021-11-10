module Battle
  module Effects
    class Ability
      class Scrappy < Ability
        # Function called when we try to get the definitive type of a move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @param type [Integer] current type of the move (potentially after effects)
        # @return [Integer, nil] new type of the move
        def on_move_type_change(user, target, move, type)
          return if user != @target
          return unless target.type_ghost?

          return move.type_normal? || move.type_fighting? ? 0 : nil
        end
      end
      register(:scrappy, Scrappy)
    end
  end
end
