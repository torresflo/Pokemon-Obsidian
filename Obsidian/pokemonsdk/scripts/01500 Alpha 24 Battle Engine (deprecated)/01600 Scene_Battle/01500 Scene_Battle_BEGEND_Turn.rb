#encoding: utf-8

#noyard
# Description: Définition de la phase de début et fin de tour
class Scene_Battle
  def end_turn_actions
    #>Ordre à respecter !!!
    #[Requiem], [Dégats météo], [Prescience], [Baîllement, Voeu, Soins (soins talents, soins items), Vampigraine], [dégats statuts / cauchemar / harcèlement], [Talents (ex : Turbo, Récolte, etc), baie].
    @_launcher=nil
    arr=Array.new
    battlers=BattleEngine.get_battlers
    BattleEngine::_State_sub_update
    #===
    #>Gestion de REQUIEM (OK !)
    #===
    arr.clear
    battlers.each do |i|
      arr<<i if i and i.hp>0 and i.battle_effect.has_perish_song_effect?
    end
    arr.each do |i|
      eff=i.battle_effect
      eff.dec_perish_song_counter
      BattleEngine::_msgp(19, 863, i, NUMB[2] => eff.get_perish_song_counter.to_s)
      if(eff.get_perish_song_counter==0)
        BattleEngine::_message_stack_push([:hp_down, i, i.hp])
      end
    end
    if(BattleEngine::_message_stack_size>0)
      #display_message("Les Pokémon succombent sous l'effet du Requiem.") #???
      phase4_message_display()
    end
    #===
    #>Météo
    #===
    #> Attention, le message apparait à tous les tours une fois calmé !!! (A corriger)
    weather=$env.current_weather
    stop=$env.decrease_weather_duration
    BattleEngine::_message_stack_push([:weather_display, weather, stop]) if weather !=0
    if(stop)
      case weather
      when 1 #Pluie
        BattleEngine::_msgp(18, 93, nil)
      when 2 #Zenith
        BattleEngine::_msgp(18, 92, nil)
      when 3 #Tempête de sable
        BattleEngine::_msgp(18, 94, nil)
      when 4 #Grêle
        BattleEngine::_msgp(18, 95, nil)
      when 5 #Brouillard
        BattleEngine::_msgp(18, 96, nil)
      end
    else
      case weather
      when 1 #Pluie
        BattleEngine::_mp([:global_animation, 493])
      when 2 #Zenith
        BattleEngine::_mp([:global_animation, 492])
      when 3 #Tempête de sable
        BattleEngine::_msgp(18, 98, nil)
        BattleEngine::_mp([:global_animation, 494])
        battlers.each do |i|
          if(i and i.hp>0)
            unless(i.type_rock? or i.type_ground? or i.type_steel?)
              #> Garde Magik / Voile Sable / Baigne Sable / Force Sable / Envelocappe
              unless(!i.battle_effect.has_no_ability_effect? and [17, 13, 145, 158, 141].include?(i.ability)) 
                BattleEngine::_message_stack_push([:hp_down, i, i.max_hp/16])
              end
            end
          end
        end
      when 4 #Grêle
        BattleEngine::_msgp(18, 99, nil)
        BattleEngine::_mp([:global_animation, 495])
        battlers.each do |i|
          if(i and i.hp>0)
            unless(i.type_ice?)
              #>Garde magik / Corps Gel / Rideau Neige / Envelocape
              unless(!i.battle_effect.has_no_ability_effect? and [17, 106, 83, 141].include?(i.ability)) 
                BattleEngine::_message_stack_push([:hp_down, i, i.max_hp/16])
              end
            end
          end
        end
      end
    end
    BattleEngine::Abilities.on_weather_change
    phase4_message_display() if(BattleEngine::_message_stack_size>0)
    #===
    #>Gestion de prescience et carnareket (OK !)
    #===
    battlers.each do |i|
      if(i and i.hp>0 and i.battle_effect.is_locked_by_future_skill?)
        if(i.battle_effect.get_future_skill_counter==1)
          dmg=i.battle_effect.get_future_damage
          skill_name = GameData::Skill[i.battle_effect.get_future_skill_id].name
          BattleEngine::_message_stack_push([:msgf, parse_text_with_pokemon(19, 1086, i, MOVE[1] => skill_name)])
          if(dmg <= 0)
            BattleEngine::_message_stack_push([:msg_fail])
          else
            BattleEngine::_message_stack_push([:hp_down, i, dmg])
          end
          i.battle_effect.set_future_skill(nil, -1, nil)
          phase4_message_display()
        end
      end
    end
    #===
    #>Bâillement
    #===
    battlers.each do |i|
      if(i and !i.dead? and i.battle_effect.fell_asleep_from_yawning?)
        #> Garde Magik
        if i.battle_effect.has_no_ability_effect? or i.ability != 17
          _mp([:status_sleep, i, nil, 306, true]) #>Message ?
        end
      end
    end
    #===
    #>Gestion de voeux (OK !)
    #===
    battlers.each do |i|
      if(i and !i.dead? and i.battle_effect.has_wish_effect?)
        BattleEngine::_mp([:msg, parse_text_with_pokemon(19, 700, i.battle_effect.get_wisher)])
        BattleEngine::_message_stack_push([:hp_up, i, i.max_hp / 2])
      end
    end
    #===
    #>Gestion de Racines (OK !)
    #===
    battlers.each do |i|
      if(i and !i.dead? and i.battle_effect.has_ingrain_effect?)
        BattleEngine::_mp([:msg, parse_text_with_pokemon(19, 739, i)])
        BattleEngine::_message_stack_push([:hp_up, i, i.max_hp / 16])
      end
    end
    #===
    #>Gestion de Anneau Hydro (OK !)
    #===
    battlers.each do |i|
      if(i and !i.dead? and i.battle_effect.has_aqua_ring_effect?)
        BattleEngine::_mp([:msg, parse_text_with_pokemon(19, 604, i)])
        BattleEngine::_message_stack_push([:hp_up, i, i.max_hp / 16])
      end
    end
    #===
    #>Gestion des capacités spéciales heal
    #===
    BattleEngine::Abilities.on_end_turn_heal_abilities
    phase4_message_display() if(BattleEngine::_message_stack_size>0)
    #===
    #>Effet des objets (OK ?)
    #===
    battlers.each do |i|
      #> Garde Magik
      if i.battle_effect.has_no_ability_effect? or i.ability != 17
        #>Boue Noire
        if(BattleEngine::_has_item(i, 281))
          if(i.type_poison?)
            BattleEngine::_message_stack_push([:hp_up, i, i.max_hp/16])
          else
            BattleEngine::_message_stack_push([:hp_down, i, i.max_hp/8])
          end
        #>Orbe Flamme
        elsif(BattleEngine::_has_item(i, 273))
          BattleEngine::_message_stack_push([:status_burn, i, true]) if i.battle_effect.nb_of_turn_here == 1
        #>Orbe Toxique
        elsif(BattleEngine::_has_item(i, 272))
          BattleEngine::_message_stack_push([:status_toxic, i, true])  if i.battle_effect.nb_of_turn_here == 1
        #>Orbe Vie
        elsif(BattleEngine::_has_item(i, 270) && i.prepared_skill != 0)
          BattleEngine::_message_stack_push([:hp_down, i, i.max_hp/10])
        #>Piquants
        elsif(BattleEngine::_has_item(i, 288))
          BattleEngine::_message_stack_push([:hp_down, i, i.max_hp/8])
        end
      end
      #>Restes
      if(BattleEngine::_has_item(i, 234))
        BattleEngine::_message_stack_push([:hp_up, i, i.max_hp/16])
      end
    end
    #===
    #>Gestion de vampigraine (OK !)
    #===
    battlers.each do |i|
      if(i and i.hp>0 and i.battle_effect.has_leech_seed_effect?)
        #> Garde Magik
        next if !i.battle_effect.has_no_ability_effect? and i.ability == 17
        BattleEngine::_message_stack_push([:msgf, parse_text_with_pokemon(19, 610, i)])
        hp=(i.max_hp<8 ? 1 : i.max_hp/8)
        BattleEngine::_message_stack_push([:hp_down, i, hp, true])
        receiver=i.battle_effect.get_leech_seed_receiver
        if(receiver.battle_effect.has_heal_block_effect?)
          BattleEngine::_message_stack_push([:msg, parse_text_with_pokemon(19,890, receiver)])
          next
        end
        #>Grosse Racine
        hp = hp*130 / 100 if(BattleEngine::_has_item(receiver, 296))
        BattleEngine::_message_stack_push([:hp_up, receiver, hp])
        phase4_message_display()
      end
    end
    #===
    #>Modifications des status (OK !)
    #===
    battlers.each do |i|
      #> Garde Magik
      if i.battle_effect.has_no_ability_effect? or i.ability != 17
        _phase4_status_check(i)
      end
    end
    phase4_message_display() if(BattleEngine::_message_stack_size>0)
    #===
    #>Gestione de l'effet d'Etreinte (OK !)
    #===
    battlers.each do |i|
      if(i and i.hp>0 and i.battle_effect.has_bind_effect?)
        #> Garde Magik
        next if !i.battle_effect.has_no_ability_effect? and i.ability == 17
        hp = i.battle_effect.get_bind_power(i)
        BattleEngine::_message_stack_push([:msgf, parse_text_with_pokemon(19, 1086, i, MOVE[1] => i.battle_effect.get_bind_skill_name)])
        BattleEngine::_message_stack_push([:hp_down, i, hp, true])
        phase4_message_display()
      end
    end
    #===
    #>Cauchemard (OK !)
    #===
    battlers.each do |i|
      if(i and i.hp>0 and i.battle_effect.has_nightmare_effect?)
        #> Garde Magik
        next if !i.battle_effect.has_no_ability_effect? and i.ability == 17
        if(i.asleep?)
          hp=i.max_hp/4
          BattleEngine::_message_stack_push([:msgf, parse_text_with_pokemon(19, 324, i)])
          BattleEngine::_message_stack_push([:hp_down, i, hp, true])
          phase4_message_display()
        else
          i.battle_effect.apply_nightmare(false)
        end
      end
    end
    #===
    #>Malédication (OK !)
    #===
    battlers.each do |i|
      if(i and i.hp>0 and i.battle_effect.has_curse_effect?)
        #> Garde Magik
        next if !i.battle_effect.has_no_ability_effect? and i.ability == 17
        hp=i.max_hp/4
        BattleEngine::_message_stack_push([:msgf, parse_text_with_pokemon(19, 1077, i)])
        BattleEngine::_message_stack_push([:hp_down, i, hp, true])
        phase4_message_display()
      end
    end
    #===
    #> Mer de feu (aire de feu + aire d'herbe)
    #===
    if BattleEngine.state[:enn_firesea] > 0
      BattleEngine._msgp(18, 175, nil)
      @enemies[0, $game_temp.vs_type].each do |i|
        next if i.type_fire? or i.dead?
        BattleEngine::_message_stack_push([:hp_down, i, i.max_hp / 8, true])
      end
      phase4_message_display()
    end
    if BattleEngine.state[:act_firesea] > 0
      BattleEngine._msgp(18, 174, nil)
      @actors[0, $game_temp.vs_type].each do |i|
        next if i.type_fire? or i.dead?
        BattleEngine::_message_stack_push([:hp_down, i, i.max_hp / 8, true])
      end
      phase4_message_display()
    end
    #===
    #>Gestion des capacités spéciales en fin de tours
    #===
    BattleEngine::Abilities.on_end_turn_abilities
    phase4_message_display() if(BattleEngine::_message_stack_size>0)
    #===
    #>Baies
    #===
    battlers.each do |i|
      if(i and i.hp>0 and BattleEngine._has_item(i, i.battle_item))
        item_id = i.battle_item
        if(item_id >= 149 and item_id <= 157)
          if(heal_data = GameData::Item[item_id].heal_data and 
              heal_data.states and heal_data.states.include?(i.status))
            BattleEngine::_mp([:berry_use, i, true])
            BattleEngine::_mp([:berry_cure, i, i.item_name])
            phase4_message_display()
          elsif(i.confused? and heal_data = GameData::Item[item_id].heal_data and 
              heal_data.states and heal_data.states.include?(5))
            BattleEngine::_mp([:berry_use, i, true])
            BattleEngine::_mp([:confuse_cure, i, i.item_name])
            phase4_message_display()

          end
        end

      end
    end
    #>END

    
    BattleEngine::_State_update
    phase4_message_display() if(BattleEngine::_message_stack_size>0)
    BattleEngine.get_actors.each { |pokemon| pokemon&.battle_turns = 0 } if @exp_distributed
  end

  
  def begin_turn_actions
    BattleEngine.get_battlers.each do |i|

    end
    #>END
  end

  def switch_turn_actions(actors, enemies, old_pokemon, current_pokemon)
    $game_temp.vs_type.times do |i|
      next unless enemies[i]
      be=enemies[i].battle_effect
      #===
      #>Vampigraine (OK !)
      # On attribue le gain au Pokémon Switché
      #===
      if(be.has_leech_seed_effect? and be.get_leech_seed_receiver==actors[old_pokemon])
        if(actors[current_pokemon].type_plante?)
          be.apply_leech_seed(actors[current_pokemon])
        else
          be.apply_leech_seed(false)
        end
      end
      #>Possessif
      if(be.has_imprison_effect? and be.get_imprison_launcher==actors[old_pokemon])
        be.apply_imprison_effect(nil, nil)
      end
    end
    #>Médic Nature
    if(BattleEngine::Abilities.has_ability_usable(actors[old_pokemon], 56))
      actors[old_pokemon].cure
    end

    #>Danse-Lune / Vœu Soin
    if(actors[old_pokemon].last_skill==461 or actors[old_pokemon].last_skill==361)
      BattleEngine::_message_stack_push([:hp_up, actors[current_pokemon], actors[current_pokemon].max_hp])
      BattleEngine::_message_stack_push([:status_cure, actors[current_pokemon]])
      BattleEngine::_message_stack_push([:msgf, parse_text_with_pokemon(19, actors[old_pokemon].last_skill==361 ? 697 : 694, actors[current_pokemon])])
    end
    #>Effet lors des switchs
    be=actors[old_pokemon].battle_effect
    be2=actors[current_pokemon].battle_effect
    #>Voeu
    if(be.has_wish_effect?)
      be2.apply_wish(be.get_wisher, 1)
    end
    #>Préscience and co
    if(be.is_locked_by_future_skill?)
      be2.set_future_skill(be.get_future_damage, be.get_future_skill_counter-1, be.get_future_skill_id)
    end
    #>Copie
    be.get_mimic.each do |pokemon, skill|
      skill.reset
    end
    be.get_mimic.clear
    #>Brûme
    if(be.has_mist_effect?)
      be2.apply_mist(be.get_mist_counter)
    end
    #> Partie Entry Hazard
    switch_turn_entry_hasard(actors[current_pokemon])
    #>Relais
    if(actors[old_pokemon].last_skill == 226)
      if(be.has_leech_seed_effect?) #> Vampigraine <- Relais
        be2.apply_leech_seed(be.get_leech_seed_receiver) unless actors[current_pokemon].type_grass?
      end
      if(be.has_bind_effect?) #> Bind <- Relais
        be.transmit_bind(be2)
      end
      if(actors[old_pokemon].confused?) #> Confusion <- Relais
        actors[current_pokemon].status_confuse
      end
      if(be.has_aqua_ring_effect?) #> Anneau Hydro <- Relais
        be2.apply_aqua_ring_effect
      end
      if(be.has_substitute_effect?) #> Clonage <- Relais
        be.transmit_substitute(be2)
      end
      if(::GameData::Flag_4G and be.has_cant_flee_effect?) #> Regard Noir <- Relais
        be.transmit_cant_flee(be2)
      end
    end
    actors[current_pokemon].attack_order=255
    BattleEngine::Abilities.on_launch_ability(actors[current_pokemon], true)
    phase4_message_display() if(BattleEngine::_message_stack_size>0)
  end

  def switch_turn_entry_hasard(pokemon)
    return unless pokemon and !pokemon.dead?
    #>> Vérifier garde magique pour picot, piege de rock et pics toxiques !
    _state = ::BattleEngine.state
    _is_enemy = pokemon.position < 0
    #>Picot
    if((value = _state[_is_enemy ? :enn_spikes : :act_spikes]) > 0 and ::BattleEngine._is_grounded(pokemon))
      hp = pokemon.max_hp * (2 + value - 1) / 16
      if(hp > 0)
        BattleEngine::_message_stack_push([:hp_down, pokemon, hp, true])
        BattleEngine::_msgp(19, 854, pokemon)
        phase4_message_display
      end
    end
    #>Piege de rock
    if(_state[_is_enemy ? :enn_stealth_rock : :act_stealth_rock])
      hp = pokemon.battle_effect.get_stealth_rock_dammages(pokemon)
      if(hp > 0)
        BattleEngine::_message_stack_push([:hp_down, pokemon, hp, true])
        BattleEngine::_msgp(19, 857, pokemon)
        phase4_message_display
      end
    end
    #>Pics Toxic
    if((value = _state[_is_enemy ? :enn_toxic_spikes : :act_toxic_spikes]) > 0 and ::BattleEngine._is_grounded(pokemon))
      if(pokemon.type_poison?)
        _state[_is_enemy ? :enn_toxic_spikes : :act_toxic_spikes] = 0
        BattleEngine::_msgp(18, _is_enemy ? 161 : 160)
      elsif(pokemon.can_be_poisoned?)
        #BattleEngine::_msgp(19, 854, pokemon)
        BattleEngine::_message_stack_push([value == 1 ? :status_poison : :status_toxic, pokemon])
      end
      phase4_message_display
    end
    #>Toile gluante
    if((value = _state[_is_enemy ? :enn_sticky_web : :act_sticky_web]) and ::BattleEngine._is_grounded(pokemon))
      BattleEngine::_message_stack_push([:apply_effect, pokemon, :sticky_web])
      BattleEngine::_msgp(19, 1222, pokemon)
      phase4_message_display
    end
    if BattleEngine._has_item(pokemon, 541) #> Ballon
      BattleEngine._msgp(19, 408, pokemon)
    end
  end
end
