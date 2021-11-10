module Battle
  class Move
    # Class that manage Minimize move
    class Minimize < Move
      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each { |target| target.effects.add(Effects::Minimize.new(@logic, target)) }
      end
    end

    Move.register(:s_minimize, Minimize)
  end
end
