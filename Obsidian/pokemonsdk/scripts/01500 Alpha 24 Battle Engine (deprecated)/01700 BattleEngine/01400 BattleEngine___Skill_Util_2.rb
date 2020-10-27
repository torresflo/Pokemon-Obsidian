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
    return true if _has_item(pkmn, 278) #> Iron Ball
    return false if _has_item(pkmn, 541) #> Balloon
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
    if (skill.magic_coat_affected && target.battle_effect.has_magic_coat_effect?) || Abilities.has_ability_usable(target, 155) #> Magic Coat & Magic Bounce
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
    return false if Abilities.enemy_has_ability_usable(pkmn, 79) && !Abilities.has_ability_usable(pkmn, 79)
    #> Magnépiège
    return false if pkmn.type_steel? && Abilities.enemy_has_ability_usable(pkmn, 92)
    #> Etreinte
    return false if be.has_bind_effect?
    #> Racines
    return false if be.has_ingrain_effect? && !pkmn.type_ghost?
    #> Piège
    return false if _is_grounded(pkmn) && Abilities.enemy_has_ability_usable(pkmn, 24)
    #>Ne peut pas fuire
    clauncher = be.get_cant_flee_launcher
    return false if be.has_cant_flee_effect? && clauncher.hp  > 0 && get_battlers.include?(clauncher)
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
      return true if pkmn.battle_item == i
    end
    return false
  end

  # Check if the Pokemon is forced to use struggle
  # @param pokemon [PFM::Pokemon]
  # @return [Boolean]
  def forced_to_use_struggle?(pokemon)
    be = pokemon.battle_effect
    return true unless be
    # Encore is forcing the Pokemon to use struggle if the move to use again is disabled
    return true if be.has_encore_effect? && be.has_disable_effect? && be.encore_skill.id == be.disable_skill_id

    # Pokemon has to use struggle if none of the move can be used
    return pokemon.skills_set.none? do |move|
      next false if move.pp <= 0
      id = move.id
      next false if BattleEngine::blocked_by_choice_item?(pokemon, id)
      next false if be.has_cant_attack_effect? && be.get_cant_attack_id == id
      next false if be.has_cant_use_last_skill_effect? && pokemon.last_skill.to_i.abs == id
      next false if be.has_taunt_effect? && move.status?
      next false if be.has_imprison_effect? && be.is_skill_imprisonned?(move)
      next false if be.has_encore_effect?

      next true # Move can be used
    end
  end
end
