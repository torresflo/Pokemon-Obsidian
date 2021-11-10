module Battle
  class Move
    class FinalGambit < Move
      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        hp_dealt = user.hp
        scene.visual.show_hp_animations([user], [-hp_dealt])
        actual_targets.each do |target|
          scene.logic.damage_handler.damage_change_with_process(hp_dealt, target, user, self)
        end
      end
    end
    Move.register(:s_final_gambit, FinalGambit)
  end
end
