#encoding: utf-8

#noyard
module BattleEngine
  module BE_Interpreter
    module_function
    #===
    #>Fonction de retour d'index du Pokémon pour les strings
    #===
    def __get_txt_offset(pokemon)
      if(pokemon.position<0)
        return 2 if $game_temp.trainer_battle
        return 1
      end
      return 0
    end
    #===
    #>Positions des textes dans le fichier de textes des combat
    #===
    Pos_atk = [0,27,48,69, 153,174, 132,111,90]
    Pos_dfe = Array.new(9) { |i| Pos_atk[i] + 3 }
    Pos_ats = Array.new(9) { |i| Pos_atk[i] + 6 }
    Pos_dfs = Array.new(9) { |i| Pos_atk[i] + 9 }
    Pos_spd = Array.new(9) { |i| Pos_atk[i] + 12 }
    Pos_acc = Array.new(9) { |i| Pos_atk[i] + 15 }
    Pos_eva = Array.new(9) { |i| Pos_atk[i] + 18 }
    AnimIDS = {atk: 478, dfe: 480, spd: 482, ats: 484, dfs: 486, eva: 488, acc: 490}
    #===
    #>Je vais faire de la macrogénération
    # les fonctions générés seront change_atk, change_dfe, change_spd, change_ats, change_dfs, change_acc, change_eva
    #===
    eval_data = "module_function
def check_flora_stats(target)
	if BattleEngine.get_ally(target)[0]
		c = BattleEngine.get_ally(target)[0]
	else
		c = target
	end
	if ((Abilities.has_abilities(target, 165) && target.type_grass?) || (Abilities.has_abilities(c, 165) && target.type_grass?))
	  _mp([:ability_display, target]) unless c.ability == 165
	  _mp([:ability_display, c]) if c.ability == 165
	  _msgp(19, 198, target)
	 return true
	end
end
def change_{d1}(target, power)
  return if @ignore or target.hp<=0
  return if @no_secondary_effect
  return if target.battle_effect.has_no_stat_change_effect?
  return if target.battle_effect.has_substitute_effect? && @launcher != target && @skill && @skill.id != 432
  if power < 0 && target != @launcher
    #> Corps Sain / Écran Fumée
	  return if check_flora_stats(target) == true
	  # Herbivore
    if @skill && @skill.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
	    _mp([:ability_display, target])
	    _mp([:change_atk, target, 1])
	    #_msgp(19, something_not_written,target)
	    return
    end
    if(Abilities.has_abilities(target, 35, 101))
	    _mp([:ability_display, target])
	    _msgp(19, 198, target)
      return
    #> Hyper Cutter
    elsif(:{d1} == :atk and Abilities.has_ability_usable(target, 51))
      _mp([:ability_display, target])
      _msgp(19, 201, target)
      return
    #> Keen Eye
    elsif(:{d1} == :acc and Abilities.has_ability_usable(target, 7))
      _mp([:ability_display, target])
      _msgp(19, 207, target)
      return
    end
  elsif power < 0
    #> Herbe blanche
    if(BattleEngine._has_item(target, 214))
      set_item(target, 0, 0)
      return
    end
  end
  #> Simple
  power *= 2 if Abilities::has_ability_usable(target, 99)
  amount = target.change_{d1}(power)
  if(amount != 0)
    power = (power < -2 ? -3 : (power > 2 ? 3 : power))
  else
    power = (power > 0 ? 4 : 5)
  end
  _mp([:animation_on, target, AnimIDS[:{d1}] + (power < 0 ? 1 : 0)])
  msg(parse_text_with_pokemon(19, Pos_{d1}[power], target))
end"
    module_eval(eval_data.gsub("{d1}","atk"))
    module_eval(eval_data.gsub("{d1}","dfe"))
    module_eval(eval_data.gsub("{d1}","spd"))
    module_eval(eval_data.gsub("{d1}","dfs"))
    module_eval(eval_data.gsub("{d1}","ats"))
    module_eval(eval_data.gsub("{d1}","eva"))
    module_eval(eval_data.gsub("{d1}","acc"))
    eval_data.clear
    eval_data = nil
  end
end
