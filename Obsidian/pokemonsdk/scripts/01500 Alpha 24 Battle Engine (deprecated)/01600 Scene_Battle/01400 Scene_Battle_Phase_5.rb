#encoding: utf-8

#noyard
# Description: Définition de la phase de fin du combat
class Scene_Battle
  #===
  #>Initialisation de la phase de fin
  #Lance l'interface de fin qui est gérée par évent
  #===
  def start_phase5
    return if @phase == 5
    @to_start = nil
    @phase = 5
    if !$pokemon_party.alive? or $actors.size == 0
      $game_switches[Yuki::Sw::BT_Defeat]=true
    else
      $game_switches[Yuki::Sw::BT_Defeat]=false
    end
    $game_switches[Yuki::Sw::BT_Victory] = !$game_switches[Yuki::Sw::BT_Defeat]
    $game_player.leave_cycling_state if $game_switches[Yuki::Sw::BT_Defeat] == true
    launch_phase_event(5,false)
    @message_window.blocking = true
    if($game_temp.trainer_battle)
      phase5_trainer_end
    else
      phase5_pokemon_end
    end
    phase5_ramassage
    phase5_object_actions
    phase5_evolve_check
    $game_switches[Yuki::Sw::BT_NoEscape] = false
    return
  end
  #===
  #>update_phase5
  #Lance simplement le passage du combat à la MAP
  #===
  HomeMaps = []
  def update_phase5
    #> Si aucun évent de défaite on fait retourner au centre
    if($game_switches[Yuki::Sw::BT_Defeat])
      unless $game_temp.battle_can_lose
        $wild_battle.reset
        $game_temp.player_transferring = true
        $game_map.setup($game_temp.player_new_map_id = $game_variables[::Yuki::Var::E_Return_ID])
        $game_temp.player_new_x = $game_variables[::Yuki::Var::E_Return_X] + ::Yuki::MapLinker.get_OffsetX
        $game_temp.player_new_y = $game_variables[::Yuki::Var::E_Return_Y] + ::Yuki::MapLinker.get_OffsetY
        $game_temp.player_new_direction = 8
        $game_switches[Yuki::Sw::FM_NoReset] = true
        $game_temp.common_event_id = 3 unless HomeMaps.include?($game_temp.player_new_map_id)
      end
    end
    return battle_end($game_switches[Yuki::Sw::BT_Defeat] ? 2 : 0)
  end
  #===
  #>phase5_evolve_check
  # Vérification de l'évolution de chacun des Pokémon
  #===
  def phase5_evolve_check
    @_Evolve.each do |i|
      id, form = i.evolve_check(:level_up)
      if(id)
        @message_window.visible = false
        GamePlay::Evolve.new(i, id, form).main unless i.dead?
      end
    end
  end
  #===
  #>phase5_trainer_end 
  # Fin du combat de dresseur, affichage des dresseurs + phrase
  #===
  def phase5_trainer_end
    tmp_sprite = ::Sprite.new(nil)
    if $game_variables[Yuki::Var::TrainerTransitionType] == 0
      tmp_sprite.bitmap = ::RPG::Cache.battler($game_temp.enemy_battler[0] + "_sma")
    else
      tmp_sprite.bitmap = ::RPG::Cache.battler($game_temp.enemy_battler[0])
    end
    width = tmp_sprite.bitmap.width
    tmp_sprite.x = 160 + width
    tmp_sprite.z = 1000
    tmp_sprite.ox = tmp_sprite.bitmap.width/2
    tmp_sprite.opacity = 0
    Graphics.sort_z
    tone = @viewport.tone
    20.times do |i|
      color = -i*4
      tone.set(color, color, color, i)
      tmp_sprite.opacity = 255*i/20
      tmp_sprite.x = 160 + width*(20-i-1)/20
      Graphics.update
    end
    display_message($game_switches[Yuki::Sw::BT_Defeat] ? @victory_phrase : @defeat_phrase)
    if $game_switches[Yuki::Sw::BT_Victory]
      v = add_money(GameData::Trainer.get(@trainer_class).base_money * @enemy_party.actors.last.level)
      display_message(parse_text(18, 60, TRNAME[0] => $trainer.name, NUMXR => v.to_s))
    end
    @to_dispose << tmp_sprite
  end
  #===
  #>phase5_pokemon_end 
  # Fin du combat de pokémon, affichage des gains éventuels + évents spécifiques
  #===
  def phase5_pokemon_end
    if $game_switches[Yuki::Sw::BT_Catch]
      pkmn = @enemies[@enemies[0].dead? ? 1 : 0]
      if (pkmn.sub_id != nil)
        pkmn.id = pkmn.sub_id
        pkmn.code = pkmn.sub_code
        pkmn.form = pkmn.sub_form
      end
      $quests.catch_pokemon(pkmn)
      $wild_battle.remove_roaming_pokemon(pkmn)
      display_message(parse_text(18, 67, PKNAME[0] => pkmn.name))
      unless $pokedex.pokemon_caught?(pkmn.id)
        $pokedex.mark_captured(pkmn.id)
        if $game_switches[::Yuki::Sw::Pokedex]
          display_message(parse_text(18, 68, PKNAME[0] => pkmn.name))
          Graphics.freeze
          GamePlay::Dex.new(pkmn).main
          Graphics.transition
        end
      end
      $pokedex.pokemon_captured_inc(pkmn.id)
      $game_system.battle_interpreter.add_pokemon(pkmn)
      #>Renommer
      if(display_message(parse_text(30, 0, PKNAME[0] => pkmn.name), true, 1, 
        text_get(25,20), text_get(25,21)) == 0)
        scene = GamePlay::NameInput.new(pkmn.name, 12, pkmn)
        scene.main
        pkmn.given_name = scene.return_name
        Graphics.transition
      end
      #>Stocké
      if($game_switches[Yuki::Sw::SYS_Stored])
        display_message(parse_text(30, 1, PKNICK[0] => pkmn.given_name, 
        '[VAR BOX(0001)]' => $storage.get_box_name($storage.current_box)))
      end
    end
    if @money > 0
      v = add_money(0)
      display_message(parse_text(18, 61, TRNAME[0] => $trainer.name, '[VAR NUM6(0001,E07F)]' => v.to_s))
    end
    @_EXP_GIVE.each do |i| # déplacé
      phase4_distribute_exp(i)
    end
  end
  #===
  #>phase5_object_actions // Vérifier si le Pokémon a combattu ou alors si le Multi-Exp l'a affecté
  #===
  def phase5_object_actions
    @actors.each do |pkmn|
      #>Bandeau Pouvoir
      if(pkmn.item_hold==292)
        pkmn.add_ev_dfs(4,pkmn.total_ev)
      #>Ceinture Pouvoir
      elsif(pkmn.item_hold==290)
        pkmn.add_ev_dfe(4,pkmn.total_ev)
      #>Chaîne pouvoir
      elsif(pkmn.item_hold==293)
        pkmn.add_ev_spd(4,pkmn.total_ev)
      #>Lentille Pouvoir
      elsif(pkmn.item_hold==291)
        pkmn.add_ev_ats(4,pkmn.total_ev)
      #>Poids Pouvoir
      elsif(pkmn.item_hold==294)
        pkmn.add_ev_hp(4,pkmn.total_ev)
      #>Poignée Pouvoir
      elsif(pkmn.item_hold==289)
        pkmn.add_ev_atk(4,pkmn.total_ev)
      end
    end
  end
  #===
  #>phase5_ramassage
  #Vérifie si un Pokémon a la capacité spéciale ramassage et lui fait ramasser un objet
  #===
  def phase5_ramassage
    @actors.each do |pkmn|
      next unless pkmn
      next if pkmn.egg?
      case pkmn.ability
      when 25 # Ramassage
        phase5_ramassage_take_object(pkmn) if rand(100) < 10 && pkmn.item_holding == 0
      when 111 # Cherche Miel
        pkmn.item_holding = 94 if rand(100) < (pkmn.level / 2) && pkmn.item_holding == 0
      when 56 # Médic Nature
        pkmn.cure
      end
    end
  end
  #===
  #>phase5_ramassage_take_object : récupère l'objet selon les conditions
  #===
  def phase5_ramassage_take_object(pkmn)
    off = (((pkmn.level - 1.0) / GameData::MAX_LEVEL) * 10).to_i # Offset should always depends on the final max level
    ind = phase5_ramassage_get_index(rand(100))
    env = $env
    if(env.tall_grass? or env.grass?)
      pkmn.item_holding=GameData::GrassItem[off][ind]
    elsif(env.cave? or env.mount?)
      pkmn.item_holding=GameData::CaveItem[off][ind]
    elsif(env.sea? or env.pond?)
      pkmn.item_holding=GameData::WaterItem[off][ind]
    else
      pkmn.item_holding=GameData::CommonItem[off][ind]
    end

  end
  #===
  #>phase5_ramassage_get_index(nb) : récupère le bon index dans le tableau
  #===
  def phase5_ramassage_get_index(nb)
    if(nb<30)   #30%
      return 0
    elsif(nb<80)#10%
      return (1+(nb-30)/10)
    elsif(nb<88)#8%
      return 6
    elsif(nb<94)#6%
      return 7
    elsif(nb<99)#5%
      return 8
    end
    return 9#1%
  end
end
