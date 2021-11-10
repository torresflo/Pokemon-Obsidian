#encoding: utf-8

#noyard
class Scene_Battle_Client < Scene_Battle_Online
  #===
  #>Fonction principale
  #===
  def main
    #Graphics.wndp_lock = true
    code = Scene_Battle_Online.code
    ip_infos = Online::OpenNatService.decode(code, Scene_Battle_Online::CodeBase)
    begin
      @_Client = TCPSocket.new(*ip_infos)
    rescue Exception
=begin
      @message_window = Window_Message.new
      Graphics.transition
      display_message("Votre partenaire est injoignable...")
      #Graphics.wndp_lock = false
      @message_window.dispose
=end
      return battle_end(1)
    end
    super()
    @_Client.close
    #Graphics.wndp_lock = false
  end
  #===
  #>start_phase4
  #Lancement de la phase 4, Récpération des actions du joueur
  #===
  def start_phase4
    @a_remaining_pk.visible = false
    @e_remaining_pk.visible = false if $game_temp.trainer_battle
    @phase = 4
    $game_temp.battle_turn += 1
    for index in 0...$data_troops[@troop_id].pages.size
      page = $data_troops[@troop_id].pages[index]
      if page.span == 1
        $game_temp.battle_event_flags[index] = false
      end
    end
    @enemy_actions.clear #Vidage des actions de l'ennemi
    #Test IA
    send_data(Marshal.dump([@actors,@actor_actions,@seed = rand(0xFFFFFF)]))
    @enemy_actions+=get_enemy_actions
    pc "New seed : #{@seed}"
    srand(@seed)
    @magneto.push_seed(@seed)
    @magneto.push_actions(@enemy_actions, 2)
    @magneto.push_actions(@actor_actions, 1)
    #>Sécurité (Inversée pour éviter les incohérences dues à l'ordre
    BattleEngine::set_actors(@enemies)
    BattleEngine::set_enemies(@actors)
    @actions = BattleEngine::_make_action_order(@enemy_actions, @actor_actions, @actors, @enemies)
    @phase4_step = 0
    launch_phase_event(4,true)
  rescue Exception
    puts $!.message
    battle_end(1)
  end
end
