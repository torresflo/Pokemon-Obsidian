#encoding: utf-8

#noyard
module BattleEngine
	module_function
	#===
	#>_message_stack_push
	# Methode permettant d'ajouter un message dans le stack de messages
	#---
	#E : msg : Array   message formaté de la manière suivante : [:msg_type, args...]
	#===
  MSG_Fail = [:msg_fail]
  def _message_stack_push(msg)
    @message_stack.insert(0, msg)
    PFM::IA.process_message(msg) if @IA_flag
  end
  alias _mp _message_stack_push
  module_function :_mp
  #===
	#>_message_stack_push_back
	# Methode permettant d'ajouter un message dans le stack de messages (Il sera évalué avant les autres)
	#---
	#E : msg : Array   message formaté de la manière suivante : [:msg_type, args...]
	#===
  def _message_stack_push_back(msg)
    @message_stack.push(msg)
  end
  #===
	#>_message_stack_pop
	# Méthode permettant d'extraire le message à évaluer
	#===
  def _message_stack_pop
    return @message_stack.pop
  end
  #===
	#>_message_stack_last_pop
	# Méthode permettant d'extraire le dernier message à évaluer
	#===
  def _message_stack_last_pop
    return @message_stack.shift
  end
  #===
	#>_message_stack_size
	# Méthode retournant la taille du stack de messages
	#===
  def _message_stack_size
    return @message_stack.size
  end
  #===
  #>_message_check
  # Vérifie si le dernier message est d'un certain type
  #===
  def _message_check(*types)
    return false if @message_stack.size == 0
    actual_type = @message_stack[-1][0]
    types.each do |type|
      return _message_stack_pop if(actual_type == type)
    end
    return false  
  end
  #===
  #>_message_get_all
  # Retourne le stack
  #===
  def _message_get_all
    return @message_stack
  end
  #===
  #>_message_set_all
  # Modification brutale du stack
  #===
  def _message_set_all(messages)
    @message_stack = messages
  end
  #===
  #>_msgp
  # Push d'un message textuel dans le stack
  #===
  def _msgp(file, id, pkmn = nil, additionnal_var = nil)
    _mp([:msg, parse_text_with_pokemon(file, id, pkmn, additionnal_var)])
  end
end
