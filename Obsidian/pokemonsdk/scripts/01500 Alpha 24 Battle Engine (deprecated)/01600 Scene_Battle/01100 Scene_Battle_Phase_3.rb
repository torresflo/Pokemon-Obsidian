    #encoding: utf-8

#noyard
# Description: Définition de la phase de choix de l'attaque à réaliser
class Scene_Battle
  # Retrieve the Struggle move
  # @return [PFM::Skill]
  def phase3_struggle_move
    Scene_Battle.const_set(:StruggleSkill, PFM::Skill.new(165)) unless Scene_Battle.const_defined?(:StruggleSkill)
    return StruggleSkill
  end
  #===
  #>start_phase3
  #Initialisation des graphismes de choix de l'attaque
  #===
  def start_phase3
    @phase = 3
    actor=@actors[@actor_actions.size]
    #>Test du forçage de lutte
    if(BattleEngine::forced_to_use_struggle?(actor))
      @actor_actions.push([0,nil,util_targetselection_automatic(actor, phase3_struggle_move),actor])
      update_phase2_next_act
      return
    elsif(actor.battle_effect.has_encore_effect?)
      @actor_actions.push([0,actor.skills_set.index(actor.battle_effect.encore_skill).to_i,
      util_targetselection_automatic(actor, actor.battle_effect.encore_skill),actor])
    end
    @mega_evolve_window.show if BattleEngine.can_pokemon_mega_evolve?(actor, $bag)

    #>Récupération de l'index d'une attaque "valide"
    @atk_index = 0
    if USE_ALPHA_25_UI
      @skill_choice_ui.reset(@actors[@actor_actions.size])
      @skill_choice_ui.visible = true
      @message_window.visible = false
    else
      4.times do |i|
        skill=actor.skills_set[i]
        @atk_index=i if skill and skill.id==actor.last_skill.to_i.abs
      end
      @skill_selector.update_text(@atk_index, @actors[@actor_actions.size])
      @skill_selector.visible = true
    end
    #@message_window.visible = false
    0 while get_action

    launch_phase_event(3, true)
  end
  #===
  #>update_phase3
  #Mise à jour de la phase 3 : Choix de l'attaque à réaliser
  #===
  def update_phase3
    return update_phase3_alpha25 if USE_ALPHA_25_UI
    forced_action = get_action

    if(!forced_action and Mouse.trigger?(:left))
      if(atk_index = @skill_selector.mouse_action)
        @atk_index = atk_index
        forced_action = :A
      end
    end

    # Update MegaEvolve
    update_phase3_mega

    #@skill_selector.update
    if Input.repeat?(:LEFT) and !forced_action or forced_action==:LEFT
      @atk_index-=1
      @atk_index+=4 if @atk_index<0
      @skill_selector.update_text(@atk_index,@actors[@actor_actions.size])
    elsif Input.repeat?(:RIGHT) and !forced_action or forced_action==:RIGHT
      @atk_index+=1
      @atk_index-=4 if @atk_index>3
      @skill_selector.update_text(@atk_index,@actors[@actor_actions.size])
    elsif Input.repeat?(:UP) and !forced_action or forced_action==:UP
      @atk_index-=2
      @atk_index+=4 if @atk_index<0
      @skill_selector.update_text(@atk_index,@actors[@actor_actions.size])
    elsif Input.repeat?(:DOWN) and !forced_action or forced_action==:DOWN
      @atk_index+=2
      @atk_index-=4 if @atk_index>3
      @skill_selector.update_text(@atk_index,@actors[@actor_actions.size])
    #Validation
    elsif Input.trigger?(:A) and !forced_action or forced_action==:A
      ss=@actors[@actor_actions.size].skills_set
      #Faire une méthode de vérification avec les effets particuliers !!!
      skill=ss[@atk_index]
      be=@actors[@actor_actions.size].battle_effect
      if(skill and skill.id != 0)
        if(BattleEngine::_skill_blocked?(@actors[@actor_actions.size], skill))
          $game_system.se_play($data_system.buzzer_se)
          phase4_message_display()
          return
        end
      else
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @mega_evolve_window.hide
      @skill_selector.visible=false
      @message_window.visible=true
      $game_system.se_play($data_system.decision_se)
      ennemies = update_phase3_enemy_select
      return start_phase2(@actor_actions.size) if(ennemies == -1)
      @actor_actions.push([0, @atk_index, ennemies, @actors[@actor_actions.size]])
      update_phase2_next_act
    #Annulation
    elsif Input.trigger?(:B) and !forced_action or forced_action==:B
      @mega_evolve_window.hide
      $game_system.se_play($data_system.cancel_se)
      @skill_selector.visible=false
      @message_window.visible=true
      start_phase2(@actor_actions.size)
    end
  end

  def update_phase3_mega
    if @mega_evolve_window.visible && Input.trigger?(:X)
      if BattleEngine.can_pokemon_mega_evolve?(@actors[@actor_actions.size], $bag) # Not already registered to mega evolve
        BattleEngine.prepare_mega_evolve(@actors[@actor_actions.size], $bag)
        @mega_evolve_window.show(true)
      else
        BattleEngine.unprepare_mega_evolve(@actors[@actor_actions.size])
        @mega_evolve_window.show(false)
      end
    end
  end

  def update_phase3_alpha25
    update_phase3_mega
    @skill_choice_ui.update
    if @skill_choice_ui.validated?
      @mega_evolve_window.hide
      @skill_choice_ui.visible = false
      @message_window.visible = true
      return start_phase2(@actor_actions.size) if @skill_choice_ui.result == :cancel
      @atk_index = @actors[@actor_actions.size].moveset.index(@skill_choice_ui.result)
      if(BattleEngine::_skill_blocked?(@actors[@actor_actions.size], @skill_choice_ui.result))
        $game_system.se_play($data_system.buzzer_se)
        phase4_message_display()
        return start_phase2(@actor_actions.size)
      end
      ennemies = update_phase3_enemy_select
      return start_phase2(@actor_actions.size) if ennemies == -1
      @actor_actions.push([0, @atk_index, ennemies, @actors[@actor_actions.size]])
      update_phase2_next_act
    end
  end
end
