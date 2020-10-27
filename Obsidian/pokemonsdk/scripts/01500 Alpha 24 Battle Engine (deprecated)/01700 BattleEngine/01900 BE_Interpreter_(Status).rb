#encoding: utf-8

#noyard
module BattleEngine
  module BE_Interpreter
		Status_Abilities = [12, 14, 21, 33, 65]
		Status_Items = [272, 273]
		Status_Not_Overwritten = [GameData::States::POISONED, GameData::States::BURN, GameData::States::PARALYZED, GameData::States::TOXIC]
    module_function
    #===
    #>Synchronize
    #===
    def synchro_apply(target, meth)
      return if @ignore || target.hp<=0
      #> Synchronize
	  	if(@launcher != target && @launcher && BattleEngine::Abilities.has_ability_usable(target, 33))
				# Security check
				return if Status_Not_Overwritten.include?(@launcher.status)
        @launcher.send(meth, true)
        _msgp(19, 1159, @launcher)
      #> Quick Feet
      elsif(BattleEngine::Abilities.has_ability_usable(target, 80))
        _mp([:ability_display, target])
        _mp([:change_spd, target, 1])
      end
    end
    #===
    #>Rendre confus
    #  Forced indique une confusion auto induite ou provenant d'une cap' (colère etc...)
    #===
    def status_confuse(target, forced=false, msg_id = 345)
      return if @ignore or target.hp<=0
      return if @no_secondary_effect
      #> Already confused
      if target.confused?
        _msgp(19, 354, target)
        return
      end
      be = target.battle_effect
      #> Substitute
      if(be.has_substitute_effect? && @launcher != target && @skill)
        msg_fail if @skill.power <= 0
        return
      end
      #> Safe Guard
      if(!forced && be.has_safe_guard_effect?)
        _msgp(19, 842, target)
        return
      end
      #> Tempo perso
      if(BattleEngine::Abilities.has_ability_usable(target, 40))
        _mp([:ability_display, target])
        _msgp(19, 357, target)
        return
      end
      target.status_confuse
      _msgp(19, msg_id, target)
      @scene.status_bar_update(target)
    end
    #===
    #>Endormir
    #===
		def status_sleep(target, nb_turn = nil, msg_id = 306, forced = false)
			return if @ignore or target.hp<=0
			return if @no_secondary_effect
			# Herbivore
			if @skill&.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
				_mp([:ability_display, target])
				_mp([:change_atk, target, 1])
				#_msgp(19, something_not_written,target)
				return
			end
			if target.asleep? #> Déjà endormi
				_msgp(19, 315, target)
				return
			end
			be = target.battle_effect
			#> Clonage
			if be.has_substitute_effect? && @launcher != target
				msg_fail if @skill&.power <= 0
				return
			end
			#> Rune protect
			if !forced && be.has_safe_guard_effect?
				_msgp(19, 842, target)
				return
			end
			return if check_flora_voile(target, forced) == true
			#> Feuille Garde / Esprit Vital / Insomnia  / Flora-Voile
			if(($env.sunny? && BattleEngine::Abilities.has_ability_usable(target, 58)) ||
				BattleEngine::Abilities.has_abilities(target, 30, 49))
				_mp([:ability_display, target])
				_msgp(19, 318, target)
				return
			end
			#> Pokémon is now asleep
			if target.can_be_asleep? || @skill&.id == 156 #> Rest
				target.status_sleep(true, nb_turn)
				#> Matinal
				if BattleEngine::Abilities.has_ability_usable(target, 41)
				  target.status_count /= 2
				end
				_msgp(19, 306, target)
			else
				_msgp(19, 318, target)
			end
			
			@scene.status_bar_update(target)
		end
		#===
		#>Geler
		#===
		def status_frozen(target, forced = false)
			return if @ignore || target.hp<=0
			return if @no_secondary_effect
			# Herbivore
			if @skill&.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
				_mp([:ability_display, target])
				_mp([:change_atk, target, 1])
				#_msgp(19, something_not_written,target)
				return
			end
			#> Déjà gelé
			if(target.frozen?)
				_msgp(19, 297, target)
				return
			end
			be = target.battle_effect
			#> Clonage
			if be.has_substitute_effect? && @launcher != target
				msg_fail if @skill&.power <= 0
				return
			end
			#> Rune protect
			if(!forced && be.has_safe_guard_effect?)
				_msgp(19, 842, target)
				return
			end
			return if check_flora_voile(target, forced)
			#> Feuille Garde / Armumagma
			if(($env.sunny? && BattleEngine::Abilities.has_ability_usable(target, 58)) ||
				BattleEngine::Abilities.has_ability_usable(target, 82))
				_mp([:ability_display, target])
				_msgp(19, 300, target)

				return
			end
			#> Geler la cible
			if target.can_be_frozen?(@skill ? @skill.type : 0)
				target.status_frozen
				_msgp(19, 288, target)
			else
				_msgp(19, 300, target)
			end
			@scene.status_bar_update(target)
		end
		#===
		#>Poison
		#===
		def status_poison(target, forced = false)
			return if @ignore or target.hp<=0
			return if @no_secondary_effect
			#> Already poisoned
			# Sap Sipper
			if @skill&.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
				_mp([:ability_display, target])
				_mp([:change_atk, target, 1])
				#_msgp(19, something_not_written,target)
				return
			end
			if target.poisoned?
				_msgp(19, 249, target)
				return
			end
			be = target.battle_effect
			#> Substitute
			if be.has_substitute_effect? && @launcher != target
				msg_fail if @skill&.power <= 0
				return
			end
			#> Safe Guard
			if !forced && be.has_safe_guard_effect?
				_msgp(19, 842, target)
				return
			end
			return if check_flora_voile(target, forced) == true
			#> Feuille Garde / Vaccin
			if(($env.sunny? && BattleEngine::Abilities.has_ability_usable(target, 58)) ||
				BattleEngine::Abilities.has_ability_usable(target, 73))
				_mp([:ability_display, target])
				_msgp(19, 252, target)
				return
			end
			#> Poison
			if target.can_be_poisoned?
				target.status_poison
				_msgp(19, 234, target)
				synchro_apply(target, :status_poison) if @launcher&.can_be_poisoned?
			else
				_msgp(19, 252, target)
			end
			@scene.status_bar_update(target)
		end
		#===
		#> Intoxicate
		#===
		def status_toxic(target, forced = false)
			return if @ignore or target.hp<=0
			return if @no_secondary_effect
			#> Already poisoned
			# Sap Sipper
			if @skill&.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
				_mp([:ability_display, target])
				_mp([:change_atk, target, 1])
				#_msgp(19, something_not_written,target)
				return
			end
			if(target.poisoned?)
				_msgp(19, 249, target)
				return
			end
			be = target.battle_effect
			#> Substitute
			if be.has_substitute_effect? && @launcher != target
				msg_fail if @skill&.power <= 0
				return
			end
			return if check_flora_voile(target, forced) == true
			#> Leaf Guard / Immunity
			if(($env.sunny? && BattleEngine::Abilities.has_ability_usable(target, 58)) ||
				BattleEngine::Abilities.has_ability_usable(target, 73))
				_mp([:ability_display, target])
				_msgp(19, 252, target)
				return
			end
			#> Intoxicate
			if target.can_be_poisoned?
				target.status_toxic
				_msgp(19, 237, target)
				synchro_apply(target, :status_toxic) if @launcher&.can_be_poisoned?
			else
				_msgp(19, 252, target)
			end
			@scene.status_bar_update(target)
		end
		#===
		#>Paralyze
		#===
		def status_paralyze(target, forced = false)
			return if @ignore || target.hp<=0
			return if @no_secondary_effect
			# Sap Sipper
			if @skill&.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
				_mp([:ability_display, target])
				_mp([:change_atk, target, 1])
				#_msgp(19, something_not_written,target)
				return
			end
			#> Already paralyzed
			if target.paralyzed?
				_msgp(19, 282, target)
				return
			end
			be = target.battle_effect
			#> Substitute
			if be.has_substitute_effect? && @launcher != target
				msg_fail if @skill&.power <= 0
				return
			end
			#> Safe Guard
			if !forced && be.has_safe_guard_effect?
				_msgp(19, 842, target)
				return
			end
			return if check_flora_voile(target, forced) == true
			#> Leaf Guard / Limber
			if(($env.sunny? && BattleEngine::Abilities.has_ability_usable(target, 58)) ||
				BattleEngine::Abilities.has_ability_usable(target, 27))
				_mp([:ability_display, target])
				_msgp(19, 285, target)
				return
			end
			#> Paralyser
			if target.can_be_paralyzed? || @skill&.id == 34 #> Body Slam
				target.status_paralyze
				_msgp(19, 273, target)
				synchro_apply(target, :status_paralyze) if @launcher&.can_be_paralyzed?
			else
				_msgp(19, 285, target)
			end
			@scene.status_bar_update(target)
		end
		#===
		#>Burn
		#===
		def status_burn(target, forced = false)
			return if @ignore or target.hp<=0
			return if @no_secondary_effect
			# Sap Sipper
			if @skill&.type_grass? && BattleEngine::Abilities.has_ability_usable(target, 156)
				_mp([:ability_display, target])
				_mp([:change_atk, target, 1])
				#_msgp(19, something_not_written,target)
				return
			end
			#> Already burnt
			if target.burn?
				_msgp(19, 267, target)
				return
			end
			be = target.battle_effect
			#> Clonage
			if be.has_substitute_effect? && @launcher != target
				msg_fail if @skill&.power <= 0
				return
			end
			#> Rune protect
			if !forced && be.has_safe_guard_effect?
				_msgp(19, 842, target)
				return
			end
			
			return if check_flora_voile(target, forced) == true
			#> Feuille Garde / Ignifu-Voile
			if(($env.sunny? && BattleEngine::Abilities.has_ability_usable(target, 58)) ||
				BattleEngine::Abilities.has_ability_usable(target, 62))
				_mp([:ability_display, target])
				_msgp(19, 270, target)
				return
			end
			#> Burn
			if target.can_be_burn?
				target.status_burn
				_msgp(19, 255, target)
				synchro_apply(target, :status_burn) if @launcher&.can_be_burn?
			else
				_msgp(19, 270, target)
			end
			@scene.status_bar_update(target)
		end
		
		def check_flora_voile(target, forced)
			if BattleEngine.get_ally(target)[0]
				c = BattleEngine.get_ally(target)[0]
			else
				c = target
			end
			
			if ((BattleEngine::Abilities.has_ability_usable(target, 165) && target.type_plante?) || (BattleEngine::Abilities.has_ability_usable(c, 165) && target.type_plante?) ) && (@skill&.id != 156)
				unless forced == true 
					_mp([:ability_display, target]) unless c.ability == 165 && target.ability != 165
					_mp([:ability_display, c]) if c.ability == 165 && target.ability != 165
					_msgp(19,1180,target)
					return true
				end
			end
		end
    #===
    #>Heal the target
    #===
    def status_cure(target)
      return if @ignore || target.hp <= 0
      return if target.status == 0
			#@scene.display_message(GameData.b_str(47, target.given_name)) #"N'a aucune altération de status, cela échoue.")
      if target.poisoned? || target.toxic?
        id = 246
			elsif target.burn?
        id = 264
      elsif target.frozen?
        id = 294
			elsif target.paralyzed?
        id = 279
      else #asleep
        id = 312
      end
      target.cure
      @scene.status_bar_update(target)
      _msgp(19, id, target)
    end
    #===
    #>Soin forcé du gel
    #===
    def ice_cure(target)
      return if @ignore || target.hp<=0 || !target.frozen?
      target.cure
      _msgp(19, 294, target)
      @scene.status_bar_update(target)
    end
    #===
    #> Forcer un statut
    #===
    def set_status(target, status)
      target.status = status
    end
  end
end
