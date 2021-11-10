#encoding: utf-8

#noyard
module BattleEngine
  ID_Struggle = 165
  ID_Pursuit = 228
  ID_Switch = 2
  DeltaPrio = 100000 #Ecart entre deux priorités d'attaque
  BattlePrio = 13 * DeltaPrio
  PursuitPrio = 14 * DeltaPrio
  SpecialPriorities = [BattlePrio + 1, BattlePrio + 1000, BattlePrio + 2000, BattlePrio + 999]
  ParalysisSpeedMalus = 4 # 4 up to Gen 6; 2 from Gen 7
  
  module_function

  # Return the priority of the Struggle move
  # @return [Integer]
  def struggle_priority
    GameData::Skill[ID_Struggle].priority * DeltaPrio
  end
  #===
  #>_make_action_order
  # Génère le tableau des actions dans le bon ordre pour le système de combat
  #---
  #E : actor_actions : Array : actions des pokémon alliés
  #    enemy_actions : Array : actions des Pokémon de l'ennemi
  #    actors : Array : Tableau des Pokémon alliés
  #    enemies : Array : Tableau des Pokémon ennemis
  #S : act : Array : Actions ordonnées
  #===
  def _make_action_order(actor_actions, enemy_actions, actors, enemies)
    #>Info du switch lors du tours (pour poursuite)
    switch = false
    #>Distortion
    trick_room = @_State[:trick_room] > 0 ? -1 : 1
    #>Tri
    @_Actions = act = actor_actions + enemy_actions
    i = nil
    pkmn = nil
    quick_claw_triggered = false
    #>Détection d'un switch
    act.each do |i|
      if(i[0] & ID_Switch == ID_Switch) #>Pour prendre en compte 2 et 3
        switch = true
        break
      elsif(i[0] == 0 and i[1])
        if(i[3].ss(i[1]).symbol == :s_u_turn) #>Demi-tour / change éclair
          switch = true
          break
        end
      end
    end
    act_tailwind = @_State[:act_tailwind] > 0
    enn_tailwind = @_State[:enn_tailwind] > 0
    focus_punch_act = []
    #> Priority & Speed calculation
    act.each do |i|
      #---
      #> Actions prototyping
      #---
      def i.priority
        return @priority
      end
      def i.priority=(v)
        @priority = v
      end
      def i.spd
        return @spd
      end
      def i.spd=(v)
        @spd = v
      end
      #---
      #> Actions definition
      #---
      if i[0] == 0 #> Is a skill?
        pkmn = i[3]
        #> Skill check
        if i[1] #> Not Struggle
          skill = pkmn.ss(i[1])
          if switch && skill.id == ID_Pursuit #> Pursuit
            i.priority = PursuitPrio
          else
            i.priority = (skill.priority + pkmn.battle_effect.priority) * DeltaPrio
          end
        else
          skill = PFM::Skill.new(ID_Struggle)
          i.priority = struggle_priority
        end
        i.spd = pkmn.spd
        #> Abilities check
        if !pkmn.battle_effect.has_no_ability_effect?
          if pkmn.ability == 60 #> Glissade
            i.spd *= 2 if $env.rain?
          elsif pkmn.ability == 20 #> Chlorophylle
            i.spd *= 2 if $env.sunny?
          elsif pkmn.ability == 145 #> Baigne Sable
            i.spd *= 2 if $env.sandstorm?
          end
        end
        #> Tail Wind
        if (pkmn.position < 0 ? enn_tailwind : act_tailwind)
          i.spd *= 2
        end
        #> Items & abilities check (with priority)
        if _has_items(pkmn, 316, 279) #>Encens Plein, Ralentiqueue
          i.priority -= DeltaPrio/2
        elsif _has_item(pkmn, 217) && rand(100) < 20 #> Vive Griffe #>Utiliser chance 20 ou rand(100)<20 ?
          i.priority += DeltaPrio #> Attaque avant
          i.spd = -i.spd #> Mais ne parasite pas
          quick_claw_triggered = true
        elsif _has_items(pkmn, 215, 278, 289, 290, 291, 292, 293, 294) #>Bracelet Macho, Iron Ball, truc Pouvoir,
          i.spd /= 2
        elsif pkmn.id == 132 && _has_item(pkmn, 274) #>Poudre Vite / Métamorph
          i.spd *= 2
        elsif _has_item(pkmn, 287) #>Mouchoir Choix
          i.spd *= 3/2
        elsif pkmn.ability == 94 #>Frein
          if !pkmn.battle_effect.has_no_ability_effect?
            i.priority -= (DeltaPrio/4) #>Lent mais pas plus que Enscens plein et Ralentiqueue
          end
        elsif pkmn.battle_item_data.include?(:attack_first)
          i.priority = BattlePrio
          pkmn.battle_item_data.delete(:attack_first)
        end
        #> Swamp
        if @_State[pkmn.position < 0 ? :enn_swamp : :act_swamp] > 0
          i.spd /= ParalysisSpeedMalus
        end
        i.spd /= ParalysisSpeedMalus if pkmn.paralyzed?
        i.spd *= trick_room
        #>Mitra-Poing
        if skill.id == 264
          i = i.clone
          i.priority = 13 * DeltaPrio
          focus_punch_act<<i
        end
      else
        #>Tout autre type d'action
        if i[0] == 3 && i[2] == :roaming
          i.priority = struggle_priority
          i.spd = i[1].spd
        else
          i.priority = SpecialPriorities[i[0]] #BattlePrio + 1000 * i[0]
          i.spd = 0
        end
      end
    end
    act = focus_punch_act + act
    #> Actions order
    a = b = prio = nil
    act.sort! do |a,b|
      prio = b.priority <=> a.priority
      next(b.spd <=> a.spd) if(prio == 0)
      next(prio)
    end
    # Update of the Pokémon's positions
    enemies.each_index do |i|
      next unless enemies[i]
      enemies[i].position=-i-1
      enemies[i].attack_order=255
      enemies[i]&.prepared_skill=0
    end
    actors.each_index do |i|
      next unless actors[i]
      actors[i].position=i
      actors[i].attack_order=255
      actors[i]&.prepared_skill=0
    end
    #>Update of the Pokémon's moves informations
    act_ind = 0
    atk_first = nil
    atk_last = nil
    act.each do |i|
      if(i[0]==0)
        next unless pkmn = i[3] # (i[2]<0 ? actors[-i[2]-1] : enemies[i[2]])
        pkmn.attack_order=act_ind
        atk_first = act_ind unless atk_first
        atk_last = act_ind
        act_ind+=1
        if(i[1])
          pkmn&.prepared_skill = pkmn.ss(i[1]).id
        else
          pkmn&.prepared_skill = ID_Struggle
        end
        _msgp(19, 1031, pkmn, '[VAR ITEM2(0001)]' => pkmn.item_name, '[VAR PKNICK(0000)]' => pkmn.given_name) if quick_claw_triggered && _has_item(pkmn, 217)
        quick_claw_triggered = false
      elsif(i[0]==ID_Switch)
        next unless pkmn = (i[1]<0 ? enemies[i[2]] : actors[i[2]])
        pkmn.attack_order = act_ind
        act_ind+=1
      end
    end
    @_AttackFirst = atk_first ? atk_first : 0
    @_AttackLast = atk_last ? atk_last : 1
    return act
  end
  #===
  #>_attacking_first?
  # Tell if the Pokémon's attacking first
  #===
  def _attacking_first?(pokemon)
    if @IA_flag
      spd = get_battlers.collect { |pkmn| pkmn.dead? ? nil : pkmn.spd }
      spd.compact!
      spd.sort!
      return spd[-1] == pokemon.spd
    end
    return pokemon.attack_order == @_AttackFirst
  end
  #===
  #>_attacking_last?
  # Tell if the Pokémon's attacking last
  #===
  def _attacking_last?(pokemon)
    if @IA_flag
      spd = get_battlers.collect { |pkmn| pkmn.dead? ? nil : pkmn.spd }
      spd.compact!
      spd.sort!
      return spd[0] == pokemon.spd
    end
    return pokemon.attack_order == @_AttackLast
  end
  #===
  #>_attacking_before?(launcher, target)
  # Tell if the launcher's attacking before target
  #===
  def _attacking_before?(launcher, target)
    if @IA_flag
      return launcher.spd > target.spd
    end
    lo = launcher.attack_order
    lt = target.attack_order
    return true if lo == 255
    return lo < lt
  end
end
