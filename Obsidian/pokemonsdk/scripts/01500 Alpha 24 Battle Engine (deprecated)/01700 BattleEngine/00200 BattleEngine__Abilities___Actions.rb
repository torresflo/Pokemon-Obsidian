#encoding: utf-8

#noyard
module BattleEngine
  module Abilities
    module_function
    #===
    #> Abilities involved in taking damage
    #===

    UnMummyableAbilities = [151, 196, 175, 208, 212, 122, 160, 209, 224]
    def on_dammage_ability(launcher,target,skill)
      return false if target==launcher or target.battle_effect.has_no_ability_effect?
      #> Launcher 
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
      #> Direct & 30% chance of hit
      if skill.direct? && (rand(100) < 30)
        case cap
        when 12 #> Statik
          if launcher.can_be_paralyzed?
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:status_paralyze, launcher, true])
          end
          return
        when 14 #> Point Poison
          if launcher.can_be_poisoned?
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:status_poison, launcher, true])
          end
          return
        when 65 #> Corps Ardent
          if launcher.can_be_burn?
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:status_burn, launcher, true])
          end
          return
        when 16 #> Joli Sourire
          if(launcher.gender * target.gender == 2)
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            launcher.battle_effect.apply_attract(target,1/0.0)
            _msgp(19, 327, launcher)
          end
          return
        end
      end
      
      #> Direct & 100%
      if(skill.direct?)
        case cap
        when 21 #> Effect Spore
          if(!BattleEngine::_has_item(launcher, 650) and !has_ability_usable(launcher, 141)) #> Safety Goggles / Overcoat
            n=rand(100)
            if(n < 9) #> Poisoned
              if launcher.can_be_poisoned?
                _mp([:ability_display, target, proc {launcher.hp > 0}])
                _mp([:status_poison, launcher, true])
              end
            elsif(n < 20) #> Asleep
              if launcher.can_be_asleep?
                _mp([:ability_display, target, proc {launcher.hp > 0}])
                _mp([:status_sleep, launcher, nil, 306, true])
              end
            elsif(n < 30) #> Paralyzed
              if launcher.can_be_paralyzed?
                _mp([:ability_display, target, proc {launcher.hp > 0}])
                _mp([:status_paralyze, launcher, true])
              end
            end
          end
          return
        when 98 #> Rough Skin
          _mp([:ability_display, target, proc {launcher.hp > 0}])
          _mp([:hp_down_proto, launcher, launcher.max_hp/8])
          #_msgp(19, 430, launcher)
          return
        when 115 #> Aftermath
          if(target.dead? && !has_ability_usable(launcher, 28)) #> Damp
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:hp_down_proto, launcher,launcher.max_hp/4])
            #_msgp(19, 430, launcher)
          return
          end
        when 151 #> Mummy
          unless UnMummyableAbilities.include?(launcher.ability)
            _mp([:ability_display, target, proc {launcher.hp > 0}])
            _mp([:set_ability, launcher, target.ability])
            _msgp(19, 405, launcher, ::PFM::Text::ABILITY[1] => target.ability_name)
            _mp([:ability_display, launcher, proc {launcher.hp > 0}])
          end
        return    
        end
      end
      #> Other cases
      case cap
      when 105 #> Color Change
        _mp([:set_type, target, skill.type, 1])
        _msgp(19, 899, target, PKNICK[0] => target.given_name, "[VAR TYPE(0001)]" => skill.type)
      end
    end
    #===
    #> Abilities that act on Pokémon launch
    #===
    UnTracableAbilities = [122, 104, 175]
    def on_launch_ability(pkmn, switched = false)
      enemies = BattleEngine::get_enemies!(pkmn)
      enemy = nil
      if has_ability_usable(pkmn, pkmn.ability)
        case pkmn.ability
        when 11 #> Intimidate
          if switched #> When the Pokémon is switched
            _mp([:ability_display, pkmn])
            enemies.each { |enemy| _mp([:change_atk, enemy, -1]) }
          end
        when 69 #> Trace
          unless enemy_has_ability_usable(pkmn, 69)
            target = BattleEngine::_random_target_selection(pkmn, nil)
            unless UnTracableAbilities.include?(target.ability)
              _mp([:ability_display, pkmn])
              _mp([:set_ability, pkmn, target.ability])
              _msgp(19, 381, target, ::PFM::Text::ABILITY[1] => target.ability_name)
            end
          end
        when 72 #> Pressure
          _mp([:ability_display, pkmn])
          _msgp(19, 487, pkmn)
        when 107 #> Drizzle
          if ::GameData::Flag_4G
            nb_turn = 1/0.0
          else
            nb_turn = BattleEngine::_has_item(pkmn, 285) ? 8 : 5 #> Damp Rock
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :rain, nb_turn])
          _mp([:global_animation, 493])
        when 108 #> Drought
          if ::GameData::Flag_4G
            nb_turn = 1/0.0
          else
            nb_turn = BattleEngine::_has_item(pkmn, 284) ? 8 : 5 #> Heat Rock
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :sunny, nb_turn])
          _mp([:global_animation, 492])
        when 87 #> Sand Stream
          if ::GameData::Flag_4G
            nb_turn = 1/0.0
          else
            nb_turn = BattleEngine::_has_item(pkmn, 283) ? 8 : 5 #> Smooth Rock
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :sandstorm, nb_turn])
          _mp([:global_animation, 494])
        when 118 #> Snow Warning
          if ::GameData::Flag_4G
            nb_turn = 1/0.0
          else
            nb_turn = BattleEngine::_has_item(pkmn, 282) ? 8 : 5 #> Icy Rock
          end
          _mp([:ability_display, pkmn])
          _mp([:weather_change, :hail, nb_turn])
        when 102 #> Anticipation
          skill = nil
          enemies.each do |enemy|
            enemy.skills_set.each do |skill|
              if BattleEngine._type_modifier_calculation(pkmn, skill) >= 2 || 
                skill.symbol == :s_ohko || 
                skill.symbol == :s_explosion
                _mp([:ability_display, pkmn])
                _msgp(19, 436, pkmn)
                skill = true
                break
              end
            end
            break if skill == true
          end
        when 50 #> Forewarn
          skill = nil
          _pkmn = enemies[0]
          _skill = _pkmn.skills_set[0]
          enemies.each do |enemy|
            enemy.skills_set.each do |skill|
              if _skill.power < skill.power
                _skill = skill
                _pkmn = enemy
              elsif _skill.power == skill.power && rand(2) == 0
                _skill = skill
                _pkmn = enemy
              end
            end
          end
          _msgp(19, 433, _pkmn, BattleEngine::MOVE[1] => _skill.name)
        when 85 #> Frisk
          target = BattleEngine::_random_target_selection(pkmn, nil)
          if(target.item_holding != 0)
            _mp([:ability_display, pkmn])
            _msgp(19, 439, pkmn, PKNICK[1] => target.given_name, ::PFM::Text::ITEM2[2] => target.item_name)
          end
        when 70 #> Download
          target = BattleEngine::_random_target_selection(pkmn, nil)
          _mp([:ability_display, pkmn])
          _mp([target.dfe < target.dfs ? :change_atk : :change_ats, pkmn, 1])
        end
      end
      #> Enemy's abilities check
      enemies.each do |enemy|
        unless enemy.battle_effect.has_no_ability_effect? || enemy.dead? || enemy.battle_effect.nb_of_turn_here > 0
          case enemy.ability
          when 11 #> Intimidate
            _mp([:ability_display, enemy])
            _mp([:change_atk, pkmn, -1])
          end
        end
      end

    end
    STURDY_BLOCK_MOVES = %i[s_multi_hit s_2hits s_explosion]
    #===
    #> Before damages abilities
    #  Tell if the Pokémon will lose HP or not
    #==
    def before_damage_ability(pkmn, skill, hp)
      return true unless skill
      if has_ability_usable(pkmn, pkmn.ability)
        case pkmn.ability
        when 32 #> Water Absorb
          if skill.type_water? && !pkmn.battle_effect.has_heal_block_effect?
            _mp([:ability_display, pkmn])
            _mp([:hp_up, pkmn, pkmn.max_hp / 4])
            return false
          end
        when 68 #> Volt Absorb
          if skill.type_electric? && !pkmn.battle_effect.has_heal_block_effect?
            _mp([:ability_display, pkmn])
            _mp([:hp_up, pkmn, pkmn.max_hp / 4])
            return false
          end
        when 37 #> Sturdy
          unless ::GameData::Flag_4G
            if pkmn.max_hp == pkmn.hp && hp >= pkmn.hp && !STURDY_BLOCK_MOVES.include?(skill.symbol)
              _mp([:ability_display, pkmn])
              _mp([:hp_down_proto, pkmn, pkmn.hp - 1])
              return false
            end
          end
        when 53 #> Lightning Rod
          unless ::GameData::Flag_4G
            if skill.type_electric?
              _mp([:ability_display, pkmn])
              _mp([:change_ats, pkmn, 1])
              return false
            end
          end
        when 113 #> Storm Drain
          unless ::GameData::Flag_4G
            if skill.type_water?
              _mp([:ability_display, pkmn])
              _mp([:change_ats, pkmn, 1])
              return false
            end
          end
        when 156 #> Sap Sipper
          if skill.type_grass?
            _mp([:ability_display, pkmn])
            _mp([:change_atk, pkmn, 1])
            return false
          end
        when 119 #> Motor Drive
          if skill.type_electric?
            _mp([:ability_display, pkmn])
            _mp([:change_spd, pkmn, 1])
            return false
          end
        when 18 #> Flash Fire
          if skill.type_fire? && !pkmn.frozen?
            pkmn.battle_effect.last_damaging_skill = skill
            _mp([:ability_display, pkmn])
            return false
          end
        when 22 #> Dry Skin
          if skill.type_water?
            _mp([:ability_display, pkmn])
            _mp([:hp_up, pkmn, pkmn.max_hp/4])
            return false
          end
        end
      end
      return true
    end
    #===
    #> Abilities triggered when the weather changes
    #===
    def on_weather_change
      battlers = ::BattleEngine.get_battlers
      pkmn = nil
      battlers.each do |pkmn|
        if has_ability_usable(pkmn, pkmn.ability)
          case pkmn.ability
          when 104 #> Forecast
            form = pkmn.form
            if $env.rain?
              pkmn.form = 3
            elsif $env.sunny?
              pkmn.form = 2
            elsif $env.hail?
              pkmn.form = 6
            else
              pkmn.form = 0
            end
            _mp([:switch_form, pkmn]) if form != pkmn.form
          end

        end
      end
    end
    #===
    #> Abilities that heal at the end of the turn
    #===
    def on_end_turn_heal_abilities
      battlers = ::BattleEngine.get_battlers
      pkmn = nil
      battlers.each do |pkmn|
        if has_ability_usable(pkmn, pkmn.ability)
          case pkmn.ability
          when 88 #> Rain Dish
            if $env.rain?
              _mp([:ability_display, pkmn])
              _mp([:hp_up, pkmn, pkmn.max_hp / 16])
            end
          when 4 #> Shed Skin
            if pkmn.status != 0 && rand(3) == 0
              _mp([:ability_display, pkmn])
              _mp([:status_cure, pkmn])
            end
          when 43 #> Hydration
            if pkmn.status != 0 && $env.rain?
              _mp([:ability_display, pkmn])
              _mp([:status_cure, pkmn])
            end
          when 106 #> Ice Body
            if $env.hail?
              _mp([:ability_display, pkmn])
              _mp([:hp_up, pkmn, pkmn.max_hp / 16])
            end
          when 22 #> Dry Skin
            if $env.rain?
              _mp([:ability_display, pkmn])
              _mp([:hp_up, pkmn, pkmn.max_hp / 8])
            end
          end
        end
      end
    end
    #===
    #> Abilitied at the end of the turn
    #===
    def on_end_turn_abilities
      battlers = ::BattleEngine.get_battlers
      pkmn = nil
      enemies = nil
      enemy = nil
      battlers.each do |pkmn|
        if has_ability_usable(pkmn, pkmn.ability)
          case pkmn.ability
          when 77 #> Speed Boost
            if pkmn.spd_stage < 6
              _mp([:ability_display, pkmn])
              _mp([:change_spd, pkmn, 1])
            end
          when 22 #> Dry Skin
            if $env.sunny?
              _mp([:ability_display, pkmn])
              _mp([:hp_down, pkmn, pkmn.max_hp / 8])
            end
          when 121 #> Bad Dreams
            enemies = ::BattleEngine.get_enemies!(pkmn)
            enemies.each do |enemy|
              if enemy.asleep?
                #> Magic Guard
                next if !enemy.battle_effect.has_no_ability_effect? && enemy.ability == 17
                _mp([:hp_down, enemy, enemy.max_hp/8])
                _msgp(19, 324, enemy) #> Pas le bon
              end
            end

          end
        end
      end
    end
    #===
    #> Abilities that attrack moves
    #===
    def target_attrating(launcher, target, skill)
      enemies = BattleEngine::get_enemies!(launcher)
      enemy = nil
      enemies.each do |enemy|
        if has_ability_usable(enemy, enemy.ability)
          case enemy.ability
          when 53 #> Lightning Rod
            return enemy if skill.type_electric?
          when 113 #> Storm Drain
            return enemy if skill.type_water?
          end
        end
      end
      return target
    end

  end
end