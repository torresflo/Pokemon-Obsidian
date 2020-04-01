#encoding: utf-8

#noyard
# Description: Affichage / Interpretation des messages du BattleEngine
class Scene_Battle
  #===
  #>phase4_message_display
  #Boucle interpretant les messages du battle engine
  #===
  def phase4_message_display
    BattleEngine::BE_Interpreter.initialize(self)
    @_EXP_GIVE.clear #Distribution de l'expérience remise à 0
    while(message=BattleEngine::_message_stack_pop)
#£DEBUG_START
      cc 2
      pc "#{message[0]}"
      cc 7
      pc message[1,message.size].join(" | ")
#£DEBUG_END
      #>Vérification de l'existance d'une fonction d'interpretation du message
      if(BattleEngine::BE_Interpreter.private_method_defined?(message[0]))
        BattleEngine::BE_Interpreter.send(*message)
      else
        BattleEngine::BE_Interpreter.stat_mod_or_unk(message)
      end
    end
    #Don de l'exp aux pokémons qui peuvent en recevoir
    return if !$game_temp.trainer_battle && judge #> Pour que les combats de sauvages se fassent bien
    @_EXP_GIVE.each do |i|
      phase4_distribute_exp(i)
      #envoie d'un nouveau Pokemon
      @_SWITCH.push(i)
    end
  end
end
