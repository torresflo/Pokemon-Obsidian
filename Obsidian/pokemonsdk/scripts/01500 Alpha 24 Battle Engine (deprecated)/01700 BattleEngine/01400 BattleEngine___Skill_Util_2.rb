#encoding: utf-8

#noyard
module BattleEngine
  module_function
  #> Ce qui suit est correct <#
  #===
  #> Pokémon au sol
  #===
  def _is_grounded(pkmn)
    return true if @_State[:gravity] > 0
    be = pkmn.battle_effect
    return true if be.has_ingrain_effect?
    return true if be.has_smack_down_effect? #> Anti-air
    return true if _has_item(pkmn, 278) #> Balle Fer
    return false if _has_item(pkmn, 541) #> Ballon
    return false if pkmn.type_fly?
    return false if be.has_magnet_rise_effect?
    return false if Abilities.has_ability_usable(pkmn, 48) #>Lévitation
    return true
  end
  #===
  #> Saisie
  #===
  def _snatch_check(pkmn, skill)
    if(skill.snatchable and pkmn.battle_effect.has_snatch_effect?)
      getter = pkmn.battle_effect.get_snatch_target
      if(getter.position < 0)
        add = $game_temp.trainer_battle ? 3 : 5
        _message_stack_push([:msg, parse_text(19, 754 + add + (pkmn.position < 0 ? 1 : 0), PKNICK[0] => getter.given_name, PKNICK[1] => pkmn.given_name)])
      else
        _message_stack_push([:msg, parse_text_with_pokemon(19, 754, pkmn, PKNICK[0] => getter.given_name, PKNICK[1] => pkmn.given_name)])
      end
      return 
    end
    return pkmn
  end
  #===
  #> Reflet magique
  #===
  def _magic_coat(launcher, target, skill)
    return launcher if target == launcher
    if (skill.magic_coat_affected and  target.battle_effect.has_magic_coat_effect?) or Abilities.has_ability_usable(target, 155) #>Miroir Magik
      _message_stack_push([:msg, parse_text_with_pokemon(19, 764, target, PKNICK[0] => target.given_name, ::PFM::Text::MOVE[1] => skill.name)])
      return launcher
    end
    return target
  end
  #===
  #>_can_switch : vérifie la possibilité de switch
  #===
  def _can_switch(pkmn)
    be = pkmn.battle_effect
    return true if _has_item(pkmn, 295) #>Carapace Mue
    #> Marque Ombre
    return false if(Abilities.enemy_has_ability_usable(pkmn, 79) and !Abilities.has_ability_usable(pkmn, 79))
    #> Magnépiège
    return false if(pkmn.type_steel? and Abilities.enemy_has_ability_usable(pkmn, 92))
    #> Etreinte
    return false if(be.has_bind_effect?)
    #> Racines
    return false if(be.has_ingrain_effect?)
    #> Piège
    return false if(_is_grounded(pkmn) and Abilities.enemy_has_ability_usable(pkmn, 24))
    #>Ne peut pas fuire
    clauncher = be.get_cant_flee_launcher
    return false if be.has_cant_flee_effect? and clauncher.hp  > 0 and get_battlers.include?(clauncher)
    return true
  end
  #===
  #>possession d'un item
  #===
  def _has_item(pkmn, item_id)
    #>Maladresse / Embargo / Sabotage
    return false if @_State[:klutz] or pkmn.battle_effect.has_embargo_effect? or 
    @_State[:knock_off].include?(pkmn) or @_State[:magic_room]>0
    return pkmn.battle_item==item_id
  end
  #===
  #>possession d'un ou plusieurs items
  #===
  def _has_items(pkmn, *item_ids)
    return false if @_State[:klutz] or pkmn.battle_effect.has_embargo_effect? or 
    @_State[:knock_off].include?(pkmn) or @_State[:magic_room]>0
    item_ids.each do |i|
      return true if pkmn.battle_item==i
    end
    return false
  end
  #> Ce qui suit devra être corrigé ! (capacité spéciale)<#
  #===
  #>Vérification de la possibilité d'attaque
  #===
  def _lutte?(pkmn)
    lutte=true
    be=pkmn.battle_effect
    if(be.has_encore_effect? and be.has_disable_effect?)
      return true if be.encore_skill.id == be.disable_skill_id
    end
    4.size.times do |i|
      skill=pkmn.skills_set[i]
      if(skill) #>Check Skill et PP
        id=skill.id
        if(skill.pp>0)
          #>Check de tous les effets
          unless(be.has_cant_attack_effect? and be.get_cant_attack_id==id)
            unless(be.has_cant_use_last_skill_effect? and pkmn.last_skill.to_i.abs==id)
              unless(be.has_taunt_effect? and !skill.status?)
                unless(be.has_imprison_effect? and be.is_skill_imprisonned?(skill))
                  lutte=false
                  break
                end
              end
            end
          end
        end
      end
    end
    return lutte
  end
end
