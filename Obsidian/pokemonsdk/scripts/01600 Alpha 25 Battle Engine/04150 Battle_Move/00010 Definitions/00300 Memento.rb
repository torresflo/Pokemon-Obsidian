module Battle
  class Move
    # class managing Memento move
    class Memento < Move
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        hp = user.max_hp
        scene.visual.show_hp_animations([user], [-hp])
      end
    end

    Move.register(:s_memento, Memento)
  end
end
