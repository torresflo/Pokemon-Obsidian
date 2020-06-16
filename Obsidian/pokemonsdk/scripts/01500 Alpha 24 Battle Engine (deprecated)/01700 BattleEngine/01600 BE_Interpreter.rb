#encoding: utf-8

#noyard
module BattleEngine
  module BE_Interpreter
    module_function
    #===
    #>Initialisation de l'interpreteur
    #===
    def initialize(scene)
      @launcher=nil
      @target=nil
      @no_more_msg=false #Variable indiquant qu'il ne faut plus afficher les messages "Machin fait..."
      @skill=nil #Skill utilisé
      @ignore=false #Si une cible ou un lanceur est KO @ignorer certains messages
      @skip_must_attack_effect=false #Si l'effet must attack doit être sauté
      @no_secondary_effect=false #Si il n'y a pas d'effet secondaires
      @ability_displayed = []
      @scene=scene
    end
    #===
    #>Méthode de paramétrage
    #===
    def parametre(launcher, target, skill)
      @launcher=launcher
      @target=target
      @skill=skill
      @ignore=(launcher.hp<=0 or target.hp<=0) if launcher and target
      if skill and skill.symbol == :s_explosion
        @ignore = false #> Explosion
      end
      @no_secondary_effect = false #> Revoir cette variable
      target.battle_effect.last_attacking = launcher if(skill and target and launcher != target)
    end
    #===
    #>Ajout d'un message dans le stack de BattleEngine
    #===
    def _mp(msg)
      ::BattleEngine._mp(msg)
    end
    #===
    #>Ajout d'un message textuel dans le stack
    #===
    def _msgp(*args)
      ::BattleEngine._msgp(*args)
    end
    #===
    #>Afficher un message de manière non forcée
    #===
    def msg(message)
      @scene.display_message(message, true) unless @no_more_msg
    end
    #===
    #>Affichage forcé d'un message
    #===
    def msgf(message)
      @scene.display_message(message, true)
    end
    def refresh_bar(pokemon)
      @scene.gr_get_pokemon_bar(pokemon).refresh
    end
    #===
    #>Affichage d'un échec
    #===
    def msg_fail(target = nil)
      unless target
        msg(parse_text(18, 74))
      else
        msg(parse_text_with_pokemon(19,24,target))
      end
      BattleEngine.state[:last_skill] = nil
    end
    #===
    #>Signal pour ne plus afficher les message (éviter la répétition)
    #===
    def no_more_msg
      @no_more_msg=true
    end
    #===
    #>Afficher le coup critique
    #===
    def critical_hit
      return if @ignore
      msg(parse_text(18, 84))
    end
    MOVE_REP = '[VAR MOVE(0000)]'
    #===
    #>Affichage de "machin attaque truc"
    #===
    def use_skill_msg(launcher, target, skill)
      return if @ignore or target.hp <= 0
      msg(parse_text_with_pokemon(8999 - GameData::Text::CSV_BASE, 12, launcher,
                                  PKNAME[0] => launcher.given_name,
                                  MOVE_REP => skill.name))
      # msg(parse_text_with_pokemon(21, skill.id*3, launcher, PKNAME[0] => launcher.given_name))#name))
      @scene.animation(launcher, target, skill)
    end

    #===
    #>Affichage des messages indiquant l'efficacité
    #===
    def efficient_msg
      return if @ignore
      msg(parse_text(18, 81))
      if(BattleEngine._has_item(@target, 208)) #> Baie Enigma
        hp_up(@target, 10, 914, ITEM2[1] => @target.item_name)
      end
      if BattleEngine._has_item(@target, 639) #> Vulné assurance
        _mp([:set_item, @target, 0, true])
        _mp([:change_atk, @target, 2])
        _mp([:change_ats, @target, 2])
      end
    end
    def unefficient_msg
      return if @ignore
      msg(parse_text(18, 82))
    end
    def useless_msg(target)
      return if @ignore or target.hp<=0
      msg(parse_text_with_pokemon(19, 210, target))
    end
    def efficiency_sound(mod)
      return if @ignore or mod == 0
      if mod == 1
        Audio.se_play("Audio/SE/hit.wav")
      elsif mod > 1
        Audio.se_play("Audio/SE/hitplus.wav")
      else
        Audio.se_play("Audio/SE/hitlow.wav")
      end
    end
    #===
    #>Messages relatifs à la précision et l'esquive
    #===
    def launcher_fail_msg(launcher, target)
      return if @ignore or target.hp<=0
      msg(parse_text_with_pokemon(19,24,target))
    end
    def target_evasion_msg(launcher, target)
      return if @ignore or target.hp<=0
      msg(parse_text_with_pokemon(19,213,target))
    end
    MULTI_HIT_MOVES = %i[s_multi_hit s_2hits]
    #===
    #>Affichage de la perte de HP
    #===
    def hp_down(target, hp, extra_info=0)
      return if @ignore or target.hp<=0
      @target = target
      
      be = target.battle_effect
      #>Vérification de clonage
      if(@skill and !@skill.sound_attack? and be.has_substitute_effect?)
        sub_hp = be.substitute_hp
        be.substitute_hp -= hp
        hp -= sub_hp
        if(hp > 0)
          msg(parse_text_with_pokemon(19, 794, target))
          switch_form(target)
        else
          msg(parse_text_with_pokemon(19, 791, target))
          be.last_damaging_skill = nil
          return
        end
      end
      #>Vérification de ténacité / Bandeau
      if hp >= target.hp and @skill
        if(be.has_endure_effect? or (BattleEngine._has_item(target, 230) and rand(10)==0))
          hp = target.hp - 1
        elsif(BattleEngine._has_item(target, 275))
          if target.hp == target.max_hp && !MULTI_HIT_MOVES.include?(@skill.symbol)
            hp = target.hp - 1
            set_item(target, 0, true)
          end
        end
      end
      #> Si le Pokémon a des capacités qui l'empêche de perdre des HP
      return unless Abilities.before_damage_ability(target, @skill, hp)

      @scene.phase4_message_remove_hp(target, hp)
      #>Vérifier les baies et Gloutonnerie (50% hp pour déclanchement au lieu de 25%)
      if(BattleEngine._has_item(target, target.battle_item))
        item_id = target.battle_item
        gl_rate = Abilities.has_ability_usable(target, 81) ? 2 : 1 #> Gloutonnerie
        if((target.hp_rate*3) <= 2)
          if item_id == 155 #> Baie Oran
            berry_use(target)
            hp_up(target, 10, 914, ITEM2[1] => target.item_name)
          elsif item_id == 158 #> Baie Citrus
            berry_use(target)
            hp_up(target, target.max_hp/4, 914, ITEM2[1] => target.item_name)
          end
        end
        if((target.hp_rate*4) <= gl_rate) #> Augmentations de stat
          if(item_id == 206) #> Baie Lensa
            berry_use(target)
            target.critical_rate += 1
          elsif(item_id == 207) #> Baie Frista
            berry_use(target)
            _mp([::PFM::ItemDescriptor::Boost[rand(6)], target, 1])
          elsif(item_id == 210) #> Baie Chérim
            berry_use(target)
            target.battle_item_data << :attack_first
          elsif(heal_data = ::GameData::Item[item_id].heal_data and heal_data.battle_boost)
            berry_use(target)
            _mp([::PFM::ItemDescriptor::Boost[heal_data.battle_boost], target, 1])
          end
        elsif((target.hp_rate*8) <= 7) #> Soin de 1/8
          if(item_id <= 163 and item_id >= 159)
            berry_use(target)
            hp_up(target, target.max_hp/8, 920, ITEM2[1] => target.item_name)
            #!!!Confusion !!!
          end
        end
        #> Ballon
        if(item_id == 541 and BattleEngine.state[:gravity] <= 0)
          _msgp(19, 411, target)
          set_item(target, 0, true)
        end
        if(@skill)
          if((@skill.physical? and item_id == 211) or 
            (@skill.special? and item_id == 212)) #> Baie Jaboca / Baie Pommo
            berry_use(target)
            hp_down_proto(@launcher, @launcher.max_hp/8)
            msg(parse_text_with_pokemon(19, 1044, @launcher, ITEM2[1] => target.item_name))
          elsif(@skill.physical? and item_id == 687) #> Baie Éka
            berry_use(target)
            _mp([::PFM::ItemDescriptor::Boost[4], target, 1])
          elsif(@skill.special? and item_id == 688) #> Baie Rangma
            berry_use(target)
            _mp([::PFM::ItemDescriptor::Boost[1], target, 1])
          elsif(@skill.type_water? and item_id == 648) #> Lichen Lumineux
            change_dfs(target, 1)
            set_item(target, 0, true)
          elsif(@skill.type_ice? and item_id == 649) #> Boule neige
            change_atk(target, 1)
            set_item(target, 0, true)
          end
        end
      end
      #>Mise à jour des dégas pris
      if(@skill)
        be.take_damages(hp, @skill.atk_class, @launcher)
        be.last_damaging_skill = @skill
        #>Vérification de destiny bond (Prélèvem. Destin)
        if(target.last_skill == 194 and @launcher and @launcher != target and target.hp <= 0)
          hp_down(@launcher, @launcher.hp, true)
          msg(parse_text_with_pokemon(19, 629, target))
        end
        #>Vérification de Frénésie
        if(be.has_rage_effect?)
          change_atk(target,1)
        end
        #>Rancune
        if(be.has_grudge_effect? and target.dead?)
          pp_down(@launcher, @skill, @skill.pp)
          msg(parse_text_with_pokemon(19, 635, @launcher, MOVE[1] => @skill.name))
        end
        #>Grelot Coque
        if(BattleEngine._has_item(@launcher, 253))
          hp_up(@launcher, hp / 8) if hp > 7
        #>Piquants
        elsif(BattleEngine::_has_item(target, 288))
          hp_down_proto(@launcher, @launcher.max_hp / 8)
          if(@launcher.battle_item == 0)
            set_item(@launcher, 288)
            set_item(target, 0)
          end
        #> Roche Royale
        elsif(@skill.king_rock_utility and BattleEngine::_has_item(target, 221) and rand(10) == 0)
          effect_afraid(@launcher)
        #> Croc Rasoir
        elsif(BattleEngine::_has_item(target, 327) and rand(10) == 0)
          effect_afraid(target)
        end
        Abilities.on_dammage_ability(@launcher, target, @skill)
        if(target.battle_item_data.include?(:berry))
          target.item_holding = 0 if target.battle_item == target.item_holding
          target.battle_item = 0
        end
      end
    end
    #===
    #> Perte de HP sans rien autour
    #===
    def hp_down_proto(target, hp)
      return if @ignore or target.hp<=0
      @scene.phase4_message_remove_hp(target, hp)
    end
    #===
    #>Gain de HP
    #===
    def hp_up(target, hp, msg = nil, *args)
      return if @ignore or target.hp<=0
      msg(parse_text_with_pokemon(19, msg, target, *args)) if msg
      @scene.phase4_message_add_hp(target, hp)
    end
    #===
    #>KO en un coup ou Sacrifice
    #===
    def OHKO(target, sacrifice=false)
      return if @ignore or target.hp<=0
      #> Fermeté
      if(Abilities.has_ability_usable(target, 37))
        _mp([:ability_display, target])
        _mp([:msg_fail])
        return
      end
      @scene.phase4_message_remove_hp(target, target.hp)
      #>Vérification de destiny bond (Prélèvem. Destin)
      if(!sacrifice and target.last_skill == 194 and @launcher and @launcher != target)
        hp_down(@launcher, @launcher.hp, true)
        msg(parse_text_with_pokemon(19, 629, target))
      end
      Abilities.on_dammage_ability(@launcher, target, @skill) if @skill
    end
    #===
    #>Afficher une animation
    #===
    def animation(id)
      #print "Affichage de l'animation #{message[1]}"
    end
    #===
    #>Fuire le combat
    #===
    def end_flee
      $game_system.se_play($data_system.escape_se)
      @scene.battle_end(1)
    end
    #===
    #>Forcer le changement de forme
    #===
    def switch_form(target)
      @scene.gr_switch_form(target)
    end
    #===
    #>Changement de météo
    #===
    def weather_change(meteo_sym, nb_turn=5)
      case meteo_sym
      when :rain
        $env.apply_weather(1, nb_turn)
        _msgp(18, 88, nil)
      when :sunny
        $env.apply_weather(2, nb_turn)
        _msgp(18, 87, nil)
      when :sandstorm
        $env.apply_weather(3, nb_turn)
        _msgp(18, 89, nil)
      when :hail
        $env.apply_weather(4, nb_turn)
        _msgp(18, 90, nil)
      when :fog
        $env.apply_weather(5, nb_turn)
        _msgp(18, 91, nil)
      else
        $env.apply_weather(0, nb_turn)
      end
      #> Indiquer que les effets n'agiront pas
      if($env.current_weather != 0 and BattleEngine.state[:air_lock])
        @scene.ability_display(BattleEngine.state[:air_lock])
        @scene.display_message(parse_text(18,97))#"Les effets de la météo se dissipent.")
      end
      #> Capacité spéciale Météo
      Abilities.on_weather_change
    end
    #===
    #>Afficher la capacité spé d'une cible
    #===
    def ability_display(target, display_condition = nil)
      if(display_condition)
        return unless display_condition.call
      end
      #> Empêcher l'affichage à la suite
      return if @ability_displayed.include?(target) and @ability_displayed[-1] == target
      @scene.ability_display(target)
      @ability_displayed << target
    end
    #===
    #>Mise à jour de la barre de status
    #===
    def status_bar_update(pokemon)
      @scene.status_bar_update(pokemon)
    end
    #===
    #>Symbol inconnu ou stat_mod
    #===
    def stat_mod_or_unk(message)
      pc "Symbole Inconnu : #{message[0]}"
    end
    # Show an animation
    def global_animation(id)
      @scene.global_animation(id)
    end
    # Show an animation on smt
    def animation_on(target, id)
      return if @ignore
      @scene.animation_on(target, id)
    end
    # Show extra skill animation
    def skill_animation(launcher, target, skill)
      return if @ignore
      @scene.animation(launcher, target, skill)
    end
  end
end
