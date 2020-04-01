#encoding: utf-8

#noyard
module BattleEngine
  module Abilities
    module_function
    #===
    #> Capacités agissant lors de la prise de dégats
    #===
    def on_dammage_ability(launcher,target,skill)
      return false if target==launcher or target.battle_effect.has_no_ability_effect?
      #>Capacités du lanceur
      if(has_ability_usable(launcher, launcher.ability))
        case launcher.ability
        when 44 #> Puanteur
          if(!::GameData::Flag_4G and skill.direct? and rand(10) == 0)
            _mp([:ability_display, launcher, proc {launcher.hp > 0 and target.hp > 0}])
            _mp([:effect_afraid, target])
          end
        end
      end
      cap = target.ability
      #>Direct et 30% de chance d'infliger
      if(skill.direct? and rand(100)<30)
        case cap
        when 12 #>Statik
          if launcher.can_be_paralyzed?
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:status_paralyze, launcher, true])
          end
          return
        when 14 #>Point Poison
          if launcher.can_be_poisoned?
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:status_poison, launcher, true])
          end
          return
        when 65 #>Corps Ardant
          if launcher.can_be_burn?
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:status_burn, launcher, true])
          end
          return
        when 16 #>Joli Sourire
          if(launcher.gender * target.gender == 2)
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            launcher.battle_effect.apply_attract(target,1/0.0)
            _msgp(19, 327, launcher)
          end
          return
        end
      end
      #>Direct et 100%
      if(skill.direct?)
        case cap
        when 21 #>Pose spore
          if(!BattleEngine::_has_item(launcher, 650) and !has_ability_usable(launcher, 141)) #>Lunettes Filtre / Envelocape
            n=rand(100)
            if(n < 9) #>Enpoisonnement
              if launcher.can_be_poisoned?
                _mp([:ability_display, target, proc {launcher.hp > 0}])
                _mp([:status_poison, launcher, true])
              end
            elsif(n < 20) #>Someil
              if launcher.can_be_asleep?
                _mp([:ability_display, target, proc {launcher.hp > 0}])
                _mp([:status_sleep, launcher, nil, 306, true])
              end
            elsif(n < 30) #>Paralysie
              if launcher.can_be_paralyzed?
                _mp([:ability_display, target, proc {launcher.hp > 0}])
                _mp([:status_paralyze, launcher, true])
              end
            end
          end
          return
        when 98 #>Peau dure
          _mp([:ability_display, target, proc {launcher.hp > 0}])
          _mp([:hp_down_proto, launcher, launcher.max_hp/8])
          #_msgp(19, 430, launcher)
          return
        when 115 #>Boom Final
          if(target.dead? and !has_ability_usable(launcher, 28)) #>Moiteur
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:hp_down_proto, launcher,launcher.max_hp/4])
            #_msgp(19, 430, launcher)
          return
          end
        end
      end
      #> Autres cas
      case cap
      when 105 #> Déguisement
        _mp([:set_type, target, skill.type, 1])
      end
    end
    #===
    #> Capacités agissant au lancement du Pokémon
    #===
    UnTracableAbilities = [122, 104, 175]
    def on_launch_ability(pkmn, switched = false)
      enemies = BattleEngine::get_enemies!(pkmn)
      enemy = nil
      if(has_ability_usable(pkmn, pkmn.ability))
        case pkmn.ability
        when 11 #> Intimidation
          if(switched == true) #> Cas où le Pokémon vient d'être lancé (switch)
            _mp([:ability_display, pkmn])
            enemies.each do |enemy|
              _mp([:change_atk, enemy, -1])
            end
          end
        when 69 #> Calque
          unless(enemy_has_ability_usable(pkmn, 69))
            target = BattleEngine::_random_target_selection(pkmn, nil)
            unless UnTracableAbilities.include?(target.ability)
              _mp([:ability_display, pkmn])
              _mp([:set_ability, pkmn, target.ability])
              _msgp(19, 381, target, ::PFM::Text::ABILITY[1] => target.ability_name)
            end
          end
        when 107 #> Crachin
          if(::GameData::Flag_4G)
            nb_turn = 1/0.0
          else
            #> Roche Humide
            nb_turn = BattleEngine::_has_item(pkmn, 285) ? 8 : 5
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :rain, nb_turn])
          _mp([:global_animation, 493])
        when 108 #> Sécheresse
          if(::GameData::Flag_4G)
            nb_turn = 1/0.0
          else
            #> Roche Chaude
            nb_turn = BattleEngine::_has_item(pkmn, 284) ? 8 : 5
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :sunny, nb_turn])
          _mp([:global_animation, 492])
        when 87 #> Sable Volant
          if(::GameData::Flag_4G)
            nb_turn = 1/0.0
          else
            #> Roche Lisse
            nb_turn = BattleEngine::_has_item(pkmn, 283) ? 8 : 5
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :sandstorm, nb_turn])
          _mp([:global_animation, 494])
        when 118 #> Alerte Neige
          if(::GameData::Flag_4G)
            nb_turn = 1/0.0
          else
            #> Roche Glace
            nb_turn = BattleEngine::_has_item(pkmn, 282) ? 8 : 5
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :hail, nb_turn])
        when 102 #> Anticipation
          skill = nil
          enemies.each do |enemy|
            enemy.skills_set.each do |skill|
              if(BattleEngine._type_modifier_calculation(pkmn, skill) >= 2 or 
                skill.symbol == :s_ohko or 
                skill.symbol == :s_explosion)
                _mp([:ability_display, pkmn])
                _msgp(19, 436, pkmn)
                skill = true
                break
              end
            end
            break if skill == true
          end
        when 50 #> Prédiction
          skill = nil
          _pkmn = enemies[0]
          _skill = _pkmn.skills_set[0]
          enemies.each do |enemy|
            enemy.skills_set.each do |skill|
              if(_skill.power < skill.power)
                _skill = skill
                _pkmn = enemy
              elsif(_skill.power == skill.power and rand(2) == 0)
                _skill = skill
                _pkmn = enemy
              end
            end
          end
          _msgp(19, 433, _pkmn, BattleEngine::MOVE[1] => _skill.name)
        when 85 #> Fouille
          target = BattleEngine::_random_target_selection(pkmn, nil)
          if(target.item_holding != 0)
            _mp([:ability_display, pkmn])
            _msgp(19, 439, pkmn, PKNICK[1] => target.given_name, ::PFM::Text::ITEM2[2] => target.item_name)
          end
        when 70 #> Télécharge
          target = BattleEngine::_random_target_selection(pkmn, nil)
          _mp([:ability_display, pkmn])
          _mp([target.dfe < target.dfs ? :change_atk : :change_ats, pkmn, 1])
        end
      end
      #> Vérification des capacités spéciales ennemies
      enemies.each do |enemy|
        unless enemy.battle_effect.has_no_ability_effect? or enemy.dead? or enemy.battle_effect.nb_of_turn_here > 0
          case enemy.ability
          when 11 #> Intimidation
            _mp([:ability_display, enemy])
            _mp([:change_atk, pkmn, -1])
          end
        end
      end

    end
    STURDY_BLOCK_MOVES = %i[s_multi_hit s_2hits s_explosion]
    #===
    #> Capacités avant la perte des HP
    #  Indique si la perte des HP peut s'effectuer ou non
    #==
    def before_damage_ability(pkmn, skill, hp)
      return true unless skill
      if(has_ability_usable(pkmn, pkmn.ability))
        case pkmn.ability
        when 32 #> Absorb Eau
          if(skill.type_water?)
            _mp([:ability_display, pkmn])
            _mp([:hp_up, pkmn, pkmn.max_hp / 4])
            return false
          end
        when 68 #> Absorb Volt
          if(skill.type_electric?)
            _mp([:ability_display, pkmn])
            _mp([:hp_up, pkmn, pkmn.max_hp / 4])
            return false
          end
        when 37 #> Fermeté
          unless(::GameData::Flag_4G)
            if(pkmn.max_hp == pkmn.hp and hp >= pkmn.hp and !STURDY_BLOCK_MOVES.include?(skill.symbol))
              _mp([:ability_display, pkmn])
              _mp([:hp_down_proto, pkmn, pkmn.hp - 1])
              return false
            end
          end
        when 53 #> Paratonnerre
          unless(::GameData::Flag_4G)
            if(skill.type_electric?)
              _mp([:ability_display, pkmn])
              _mp([:change_ats, pkmn, 1])
              return false
            end
          end
        when 113 #> Lavabo
          unless(::GameData::Flag_4G)
            if(skill.type_water?)
              _mp([:ability_display, pkmn])
              _mp([:change_ats, pkmn, 1])
              return false
            end
          end
		when 156
			if (skill.type_grass?)
			  _mp([:ability_display, pkmn])
			  _mp([:change_atk, pkmn, 1])
			  return false
			end
        when 119 #> Motorisé
          if(skill.type_electric?)
            _mp([:ability_display, pkmn])
            _mp([:change_spd, pkmn, 1])
            return false
          end
        when 18 #> Torche
          if(skill.type_fire? and !pkmn.frozen?)
            pkmn.battle_effect.last_damaging_skill = skill
            _mp([:ability_display, pkmn])
            return false
          end
        when 22 #> Peau Sèche
          if(skill.type_water?)
            _mp([:ability_display, pkmn])
            _mp([:hp_up, pkmn, pkmn.max_hp/4])
            return false
          end
        end
      end
      return true
    end
    #===
    #> Capacités se déclenchant lors d'un changement de météo
    #===
    def on_weather_change
      battlers = ::BattleEngine.get_battlers
      pkmn = nil
      battlers.each do |pkmn|
        if(has_ability_usable(pkmn, pkmn.ability))
          case pkmn.ability
          when 104 #> Météo
            form = pkmn.form
            if($env.rain?)
              pkmn.form = 3
            elsif($env.sunny?)
              pkmn.form = 2
            elsif($env.hail?)
              pkmn.form = 6
            else
              pkmn.form = 0
            end
            if form != pkmn.form
              _mp([:switch_form, pkmn])
            end
          end

        end
      end
    end
    #===
    #>Capacités qui soignent en fin de tour
    #===
    def on_end_turn_heal_abilities
      battlers = ::BattleEngine.get_battlers
      pkmn = nil
      battlers.each do |pkmn|
        if(has_ability_usable(pkmn, pkmn.ability))
          case pkmn.ability
          when 88 #> Cuvette
            if $env.rain?
              _mp([:ability_display, pkmn])
              _mp([:hp_up, pkmn, pkmn.max_hp / 16])
            end
          when 4 #> Mue
            if pkmn.status != 0 and rand(3) == 0
              _mp([:ability_display, pkmn])
              _mp([:status_cure, pkmn])
            end
          when 43 #> Hydratation
            if pkmn.status != 0 and $env.rain?
              _mp([:ability_display, pkmn])
              _mp([:status_cure, pkmn])
            end
          when 106 #> Corps Gel
            if $env.hail?
              _mp([:ability_display, pkmn])
              _mp([:hp_up, pkmn, pkmn.max_hp / 16])
            end
          when 22 #> Peau Sèche
            if $env.rain?
              _mp([:ability_display, pkmn])
              _mp([:hp_up, pkmn, pkmn.max_hp / 8])
            end
          end
        end
      end
    end
    #===
    #>Capacités en fin de tour
    #===
    def on_end_turn_abilities
      battlers = ::BattleEngine.get_battlers
      pkmn = nil
      enemies = nil
      enemy = nil
      battlers.each do |pkmn|
        if(has_ability_usable(pkmn, pkmn.ability))
          case pkmn.ability
          when 77 #> Turbo
            if(pkmn.spd_stage < 6)
              _mp([:ability_display, pkmn])
              _mp([:change_spd, pkmn, 1])
            end
          when 22 #> Peau Sèche
            if $env.sunny?
              _mp([:ability_display, pkmn])
              _mp([:hp_down, pkmn, pkmn.max_hp / 8])
            end
          when 121 #> Mauvais Rêve
            enemies = ::BattleEngine.get_enemies!(pkmn)
            enemies.each do |enemy|
              if(enemy.asleep?)
                #> Garde Magik
                next if !enemy.battle_effect.has_no_ability_effect? and enemy.ability == 17
                _mp([:hp_down, enemy, enemy.max_hp/8])
                _msgp(19, 324, enemy) #> Pas le bon
              end
            end

          end
        end
      end
    end
    #===
    #> Capacités spéciales attirant l'attaque
    #===
    def target_attrating(launcher, target, skill)
      enemies = BattleEngine::get_enemies!(launcher)
      enemy = nil
      enemies.each do |enemy|
        if(has_ability_usable(enemy, enemy.ability))
          case enemy.ability
          when 53 #> Paratonnerre
            return enemy if skill.type_electric?
          when 113 #> Lavabo
            return enemy if skill.type_water?
          end

        end
      end
      return target
    end

  end
end
