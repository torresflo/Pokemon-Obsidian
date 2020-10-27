#encoding: utf-8

#noyard
module BattleEngine
  module_function
  def set_actors(v)
    @_Actors=v
  end
  def get_actors
    return @_Actors
  end
  def set_enemies(v)
    @_Enemies=v
  end
  def get_enemies
    return @_Enemies
  end
  #===
  #> Get the allies
  #===
  def get_ally(pkmn)
    arr=(pkmn&.position.to_i < 0 ? @_Enemies : @_Actors)
    arr2=Array.new
    $game_temp.vs_type.times do |i|
      arr2<<arr[i] if arr[i]&.position != pkmn&.position
    end
    return arr2
  end
  #===
  #> Get the enemies
  #===
  def get_enemies!(pkmn)
    return (pkmn&.position.to_i < 0 ? @_Actors : @_Enemies)[0, $game_temp.vs_type]
  end
  #===
  #> Get the allies (Pokémon included)
  #===
  def get_ally!(pkmn)
    return (pkmn&.position.to_i < 0 ? @_Enemies : @_Actors)[0, $game_temp.vs_type]
  end
  #===
  #> Get the Pokémon on the ground
  #===
  def get_battlers
    return (@_Enemies[0, $game_temp.vs_type]+@_Actors[0, $game_temp.vs_type])
  end
  #===
  #> Count the alive Pokémon number
  #===
  def count_alives(party = :enemies)
    party = party == :enemies ? @_Enemies : @_Actors
    counter = 0
    party.each do |i|
      counter += 1 if i && !i.dead?
    end
    return counter
  end
  #===
  #> Check if the Pokémon can attack
  #===
  def battler_can_attack?(pkmn, skill)
    ::PFM::Text.set_variable(PKNICK[0], pkmn.given_name)
    ::PFM::Text.set_variable(MOVE[1], skill.name)
    be = pkmn.battle_effect
    #> Torment
    if(be.has_torment_effect? && skill.id == pkmn.last_skill)
      _mp([:msg, parse_text_with_pokemon(19, 580, pkmn)])
      return false
    end
    #> Gravity
    if(@_State[:gravity] > 0 && skill.gravity_affected?)
      _mp([:msg, parse_text_with_pokemon(19, 1092, pkmn)])
      return false
    end
    #> If afraid
    if(be.has_afraid_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 363, pkmn)])
      _mp([:animation_on, pkmn, 469 + 7])
      return false
    end
    #> Si le Pokémon a Absentésime (changer 90 en une constante !)
    if BattleEngine::Abilities::has_ability_usable(pkmn, 90)
      if pkmn.ability_used
        _mp([:msg, parse_text_with_pokemon(19, 445, pkmn)])
        return pkmn.ability_used = false
      end
      pkmn.ability_used = true
    end
    #> If frozen
    if pkmn.frozen?
      if pkmn.froze_check
        if skill.unfreeze?
          _mp([:ice_cure, pkmn])
          _mp([:msg, parse_text_with_pokemon(19, 303, pkmn)])
        else
          _mp([:msg, parse_text_with_pokemon(19, 288, pkmn)])
          _mp([:animation_on, pkmn, 469 + pkmn.status])
          return false
        end
      else
        _mp([:ice_cure, pkmn])
        _mp([:msg, parse_text_with_pokemon(19, 294, pkmn)])
      end
    #> If paralyzed
    elsif pkmn.paralyzed? && pkmn.paralysis_check
      _mp([:msg, parse_text_with_pokemon(19, 276, pkmn)])
      _mp([:animation_on, pkmn, 469 + pkmn.status])
      return false
    #> If asleep
    elsif pkmn.asleep?
      if pkmn.sleep_check
        unless GameData::Skill[skill.db_symbol].sleeping_attack?
          _mp([:msg, parse_text_with_pokemon(19, 309, pkmn)])
          _mp([:animation_on, pkmn, 469 + pkmn.status])
          return false if skill.id != 173 || skill.id != 214
        end
      else
        _mp([:status_bar_update, pkmn])
        _mp([:msg, parse_text_with_pokemon(19, 312, pkmn)])
      end
    end
    #>Si le Pokémon est amoureux
    if be.has_attract_effect? && get_enemies!(pkmn).include?(be.attracted_to)
      _mp([:msg, parse_text_with_pokemon(19, 333, pkmn, {PKNICK[1] => be.attracted_to.given_name})])
      if rand(2) == 1
        _mp([:msg, parse_text_with_pokemon(19, 336, pkmn)])
        return false
      end
    end
    #>Si le Pokémon est affecté par Powder (Nuée de Poudre)
    if be.has_powder_effect? && skill.type_fire?
      if pkmn.ability == 17 #> Magic Guard
        _mp(MSG_Fail)
      else
        _mp([:use_skill_msg, pkmn, pkmn, skill])
        _mp([:msg, parse_text(18, 259, MOVE[0] => skill.name)])
        _message_stack_push([:hp_down, pkmn, pkmn.max_hp/4])
      end
      return false
    end
    #> Check if the Pokémon is confused
    if pkmn.confused?
      stat = pkmn.confuse_check
      _mp([:msg, parse_text_with_pokemon(19, (stat == :cured ? 351 : 348), pkmn)])
      _mp([:animation_on, pkmn, 469 + 6])
      if stat == true
        hp = pkmn.confuse_damage
        _mp([:msg, parse_text(18, 83)])
        _mp([:hp_down, pkmn, hp])
        return false
      end
    end
    return true
  end
end

