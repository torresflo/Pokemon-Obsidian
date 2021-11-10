#encoding: utf-8

#noyard
class Scene_Battle_Server < Scene_Battle_Online
  #===
  #>Fonction principale
  #===
  def main
    #Graphics.wndp_lock = true
    ip_infos = Online::OpenNatService.decode(code = Scene_Battle_Online.code, Scene_Battle_Online::CodeBase)
    @_Server = TCPServer.new("0.0.0.0", ip_infos.last)
    @_Server.listen(20)
    until(@_Server.accepting?)
      Graphics.update
      Yuki.set_clipboard(code) if text = Input.get_text and text.getbyte(0) == 3
      if Input.trigger?(:B)
        #Graphics.wndp_lock = false
        return battle_end(1)
      end
    end
    @_Client = @_Server.accept
    super()
    @_Server.close
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
    @seed = 0
    @enemy_actions+=get_enemy_actions
    send_data(Marshal.dump([@actors,@actor_actions,seed = rand(0xFFFFFF)]))
    @seed += seed
    @magneto.push_seed(@seed)
    @magneto.push_actions(@actor_actions, 1)
    @magneto.push_actions(@enemy_actions, 2)
    pc "New seed : #{@seed}"
    srand(@seed)
    #>Sécurité
    BattleEngine::set_actors(@actors)
    BattleEngine::set_enemies(@enemies)
    @actions = BattleEngine::_make_action_order(@actor_actions, @enemy_actions, @actors, @enemies)
    @phase4_step = 0
    launch_phase_event(4,true)
  rescue Exception
    puts $!.message
    battle_end(1)
  end
end
