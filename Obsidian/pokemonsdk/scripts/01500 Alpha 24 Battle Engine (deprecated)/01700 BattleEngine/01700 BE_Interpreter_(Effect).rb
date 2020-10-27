#encoding: utf-8

#noyard
module BattleEngine
  module BE_Interpreter
    module_function
    #===
    #>Appliquer l'amour (attraction) (j'ai mis 5 tours mais aucune idée '^')
    #===
    def attract_effect(launcher, target, nb_turn = 5)
      return if @ignore or target.hp<=0
      be = target.battle_effect
      if(be.has_attract_effect? and nb_turn > 0)
        msg_fail
      elsif(nb_turn > 0 and BattleEngine._has_item(target, 219))
        msg_fail
        set_item(target, 0, true)
      #> Benêt
      elsif(((target.gender * launcher.gender) == 2 and !Abilities.has_ability_usable(target, 39)) or nb_turn == 0)
        #m * m = 1, f * f = 4, m * f = 2, i * m = 0, i * f = 0, i * i = 0
        be.apply_attract(launcher, nb_turn)
        #> Nœud Destin
        if nb_turn > 0 and BattleEngine._has_item(target, 280)
          launcher.battle_effect.apply_attract(target, nb_turn)
        end
      else
        msg_fail
      end
    end
    #===
    #>Appliquer la peur
    #===
    def effect_afraid(target)
      return if @ignore or target.hp<=0
      #> Attention
      if(Abilities.has_ability_usable(target, 19))
        ability_display(target)
        return
      #> Impassible
      elsif(Abilities.has_ability_usable(target, 86))
        _mp([:ability_display, target])
        _mp([:change_spd, target, 1])
      end
      target.battle_effect.apply_afraid
    end
    #===
    #>Appliquer powder
    #===
    def powder_effect(target)
      return if @ignore or target.hp<=0
      be = target.battle_effect
      be.apply_powder
      msg(parse_text_with_pokemon(19, 1210, target))
    end
    #===
    #> Force skill during n turns
    #===
    def force_attack(launcher, target, skill, nb_turn)
      launcher.battle_effect.apply_forced_attack(skill.id, nb_turn, target)
    end
    #===
    #>set_reload_state
    #===
    def set_reload_state(target)
      return if @ignore or target.hp<=0
      target.battle_effect.set_reload_state(true)
    end
    #===
    #>roar (Fin de combat)
    #===
    def roar(target)
      @scene.battle_end(1) #>Fuite, à améliorer
    end
    #===
    #>Réquiem
    #===
    def perish_song(target)
      return if @ignore or target.hp<=0
      target.battle_effect.apply_perish_song unless target.battle_effect.has_perish_song_effect?
    end
    #===
    #>Jackpot
    #===
    def jackpot(launcher)
      return if @ignore || launcher.hp<=0
      n = 5
      #>Piece rune / Encens Veine
      n *= 2 if BattleEngine._has_item(launcher, 223) || BattleEngine._has_item(launcher, 319)
      @scene.money += launcher.level*n
      msg(parse_text(18, 128))
    end
    #===
    #> Happy Hour (Etrennes)
    #===
    def happy_hour(target)
      return if @ignore or target.hp<=0
      if(target.position > 0)
        _mp([:set_state, :happy_hour, true])
        msg(parse_text(18, 255))
      end
    end
    #===
    #>Etreinte
    #===
    def bind(target, nb_turn, skill, launcher)
      return if @ignore or target.hp<=0
      unless target.battle_effect.has_bind_effect?
        target.battle_effect.apply_bind(nb_turn, skill.name, launcher)
      end
    end
    #===
    #>Vampigraine
    #===
    def leech_seed(target, launcher)
      return if @ignore or target.hp<=0
	# Herbivore
	  if BattleEngine::Abilities.has_ability_usable(target, 156)
		_mp([:ability_display, target])
		_mp([:change_atk, target, 1])
		#_msgp(19, something_not_written,target)
		return
	  end
      msg(parse_text_with_pokemon(19, 607, target))
      target.battle_effect.apply_leech_seed(launcher)
    end
    #===
    #>Prescience / Carnareket
    #===
    def future_skill(target, hp, nb_turn, skill_id)
      be = target.battle_effect
=begin
      if @ignore or target.hp<=0 or be.is_locked_by_future_skill? or @launcher.battle_effect.has_future_skill?
        msg_fail
        return
      end
=end
      target.battle_effect.set_future_skill(hp, nb_turn, skill_id)
      @launcher.battle_effect.set_future_wait(nb_turn)
    end
    #===
    #> Appliquer un effet qui n'a pas d'argument
    #===
    def apply_effect(target, effect, *args)
      target.battle_effect.send(effect, *args)
    end
    #===
    #> stat_reset_neg : Supprimer les stat négatives
    #===
    def stat_reset_neg(target)
      bs = target.battle_stage
      bs.each_index do |i|
        bs[i] = 0 if bs[i] < 0
      end
    end
    #===
    #> stat_reset(target) : Remise à zero des stat
    #===
    def stat_reset(target)
      bs = target.battle_stage
      bs.each_index do |i|
        bs[i] = 0
      end
    end
    #===
    #> stat_set(target, index, value) : modification d'une stat
    #===
    def stat_set(target, index, value)
      target.battle_stage[index] = value
    end
    #===
    #> modifie le type 3
    #===
    def set_type(target, type, index)
      case index
      when 1
        target.type1 = type
      when 2
        target.type2 = type
      when 3
        target.type3 = type
      end
    end
    #===
    #> Set Ability
    #===
    def set_ability(target, ability)
      target.ability_current = ability
    end
    #===
    #> Modifier une valeur du battle effect
    #===
    def set_be_value(target, variable, value)
      return if @ignore or target.hp<=0
      target.battle_effect.send(variable, value)
    end
    #===
    #> Switch d'un Pokémon
    #===
    def switch_pokemon(target, to)
      return if @ignore or target.hp<=0 or @target.hp<=0
      #> Swich choisi
      unless to
        if (target.position < 0 ? @scene.enemy_party : $pokemon_party).pokemon_alive > $game_temp.vs_type
          @scene.switch_pokemon(target, to)
        end
      #> Switch non choisi
      else
        @scene.switch_pokemon(target, to)
      end
    end
    #===
    #>Effet de gribouille
    #===
    def sketch(launcher, skill, id)
      return if @ignore or @target.hp<=0
      skill.switch(id, 0, true)
    end
    #===
    #>Effet de copie
    #===
    def mimic(launcher, target, skill, id)
      return if @ignore or target.hp<=0
      skill.switch(id)
      target.battle_effect.apply_mimic(launcher, skill)
    end
    #===
    #>Perte de PP
    #===
    def pp_down(target, skill, pp)
      return if @ignore or target.hp<=0
      skill.pp -= pp
    end
    #===
    #> Modification brutale de PP (Objets)
    #===
    def set_pp(skill, pp)
      skill.pp = pp
    end
    #===
    #>Changement d'objet
    #===
    def set_item(target, id, nokeep = false)
      return if @ignore or target.hp<=0
      target.battle_item = id
      target.item_holding = id if nokeep
      if(id == 0 and Abilities.has_ability_usable(target, 114)) #> Délestage
        _mp([:change_spd, target, 1])
      end
      if(id == 278)
        if target.battle_effect.has_telekinesis_effect?
          _msgp(19, 1149, target)
          _mp([:apply_effect, target, :apply_telekinesis, 0])
        end
      end
    end
    #===
    #>Changement des status de BattleEngine
    #===
    def set_state(state, value)
      BattleEngine.state[state] = value
    end
    #===
    #>Envoie d'une commande au state
    #===
    def send_state(state, cmd, *args)
      BattleEngine.state[state].send(cmd, *args)
    end
    #===
    #>Suppression des entry hazards
    #===
    def entry_hazards_remove(target)
      if target.position < 0
        BattleEngine._State_remove(:enn_spikes, 157)
        BattleEngine._State_remove(:enn_toxic_spikes, 161)
        BattleEngine._State_remove(:enn_stealth_rock, 165)
        BattleEngine._State_remove(:enn_sticky_web, 217)
      else
        BattleEngine._State_remove(:act_spikes, 156)
        BattleEngine._State_remove(:act_toxic_spikes, 160)
        BattleEngine._State_remove(:act_stealth_rock, 164)
        BattleEngine._State_remove(:act_sticky_web, 216)
      end
    end
    #===
    #>Morphing
    #===
    def morph(launcher, target)
      launcher.morph(target)
    end

    #===
    #>Devenir hors de porté
    #===
    def apply_out_of_reach(target, type)
      apply_effect(target, :apply_out_of_reach, type)
      #>Rendre la cible invisible
    end
    #===
    #>Modification brutale des HP (Réservé aux objets utilisés explicitement !)
    #===
    def set_hp(target, hp)
      target.hp = hp
    end
    #===
    #> berry_use : Utilise la baie (animation + marquage)
    #===
    def berry_use(target, remove = false)
      #>Animation
      imisc = GameData::Item[target.battle_item].misc_data
      if(imisc and berry = imisc.berry)
        target.edit_bonus(berry[:bonus])
      end
      if(remove)
        target.item_holding = target.battle_item = 0
      else
        target.battle_item_data << :berry
      end
    end
    #===
    #> berry_pluck : Utilise la baie via Picore (animation + marquage)
    #===
    def berry_pluck(launcher, target)
      #>Animation
      imisc = GameData::Item[target.battle_item].misc_data
      if(imisc and berry = imisc.berry)
        launcher.edit_bonus(berry[:bonus])
      end
      target.item_holding = target.battle_item = 0
    end
    #===
    #> berry_cure : Soin par baie
    #===
    def berry_cure(target, iname)
      return if @ignore || target.hp<=0
      if(target.status==0)
        return
      end
      if(target.poisoned? || target.toxic?)
        id = 923
      elsif(target.burn?)
        id = 935
      elsif(target.frozen?)
        id = 932
      elsif(target.paralyzed?)
        id = 926
      else #asleep
        id = 929
      end
      target.cure
      @scene.status_bar_update(target)
      _msgp(19, id, target, ITEM2[1] => iname)
    end
    #===
    #>confuse_cure : sortir de la confusion
    #===
    def confuse_cure(target, iname)
      return if @ignore || target.hp<=0
      return unless target.confused?
      target.confuse = false
      _msgp(19, 938, target, ITEM2[1] => iname)
    end
    #===
    #> Annulation d'une attaque
    #===
    def cancel_attack(target)
      i = nil
      @scene.actions.each do |i|
        if i[0] == 0 && i[3] == target
          i[0] = -1
        end
      end
    end
    #===
    #> Fait attaquer une cible juste après
    #===
    def after_you(target)
      i = nil
      actions = @scene.actions
      action = actions.find { |i| (i[0] == 0 && i[3] == target) }
      if(action)
        actions.delete(action)
        actions.insert(@scene.phase4_step + 1, action)
      end
    end
    #===
    #> Fait attaquer une cible en dernier
    #===
    def quash(target)
      i = nil
      actions = @scene.actions
      action = actions.find { |i| (i[0] == 0 && i[3] == target) }
      if(action)
        actions.delete(action)
        actions.push(action)
      end
    end
  end
end
