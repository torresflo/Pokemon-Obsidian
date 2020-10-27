#encoding: utf-8

#noyard

# Switches related skills
module BattleEngine
  module_function

  # Circle Throw / Dragon Tail skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_dragon_tail(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
    unless(launcher.position >= 0 && !$game_temp.trainer_battle)
      party = (target.position < 0 ? $scene.enemy_party : $pokemon_party)
      if party.pokemon_alive > $game_temp.vs_type
        party = (target.position < 0 ? @_Enemies : @_Actors)
        n_party = Array.new
        $game_temp.vs_type.upto(party.size-1) do |i|
          n_party<<party[i] if party[i].hp > 0
        end
        if(Abilities.has_ability_usable(target, 84)) #> Suction Cups
          _mp([:msg, parse_text_with_pokemon(19,454,target)])
        elsif(false) #> Ingrain
          _mp([:msg, parse_text_with_pokemon(19,742,target)])
        else
          _mp([:switch_pokemon, target, n_party[rand(n_party.size)]]) if n_party.size > 0
        end
        return
      end
    end
  end

  # Pursuit skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_pursuit(launcher, target, skill, msg_push = true)
    if _attacking_before?(launcher, target) && target.attack_order != 255 && target.prepared_skill == 0
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Roar & Whirlwind skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_roar(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    #> Wild Battle
    unless $game_temp.trainer_battle
      return if(launcher.position < 0 and target.position < 0)
      #> Trainer Battle
      if launcher.position >= 0
        if Abilities.has_ability_usable(target, 84) #> Suction Cups
          _mp([:msg, parse_text_with_pokemon(19,454,target)])
        elsif target.battle_effect.has_ingrain_effect? && !target.type_ghost? #> Ingrain
          _mp([:msg, parse_text_with_pokemon(19,742,target)])
        elsif(launcher.level > target.level && !$game_switches[Yuki::Sw::BT_NoEscape])
          _mp([:msg, parse_text_with_pokemon(19, 767, launcher)])
          _message_stack_push([:roar, target])
        else
          _message_stack_push([:msg_fail, target])
        end
        return
      end
    end
    unless launcher.position >= 0 && !$game_temp.trainer_battle
      party = (target.position < 0 ? $scene.enemy_party : $pokemon_party)
      if party.pokemon_alive > $game_temp.vs_type
        party = (target.position < 0 ? @_Enemies : @_Actors)
        n_party = Array.new
        $game_temp.vs_type.upto(party.size-1) do |i|
          n_party<<party[i] unless party[i].dead?
        end
        if Abilities.has_ability_usable(target, 84) #> Suction Cups
          _mp([:msg, parse_text_with_pokemon(19,454,target)])
        elsif false && !target.type_ghost? #> Ingrain
          _mp([:msg, parse_text_with_pokemon(19,742,target)])
        else
          _mp([:switch_pokemon, target, n_party[rand(n_party.size)]]) if n_party.size > 0
        end
        return
      end
    end
    _mp([:msg_fail, target])
  end

  # Teleport skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_teleport(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if($game_temp.trainer_battle || $game_switches[Yuki::Sw::BT_NoEscape])
      _mp(MSG_Fail)
    else
      _mp([:msg, parse_text_with_pokemon(19, 767, launcher)])
      _mp([:roar, launcher])
    end
  end
  
  # U-Turn / Volt Switch / Baton Pass skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_u_turn(launcher, target, skill, msg_push = true)
    return unless skill.id == 226 || s_basic(launcher, target, skill)
    unless(launcher.position < 0 && !$game_temp.trainer_battle)
      _mp([:switch_pokemon, launcher, nil])
    end
  end

end