#encoding: utf-8

#noyard
module BattleEngine
  module Abilities
    #> Moves affected by Mold Breaker
    ATK_Block = [32, 68, 52, 71, 82, 164, 19, 39, 144, 125, 46, 35, 112, 103, 27, 101, 3, 30, 37, 58, 64, 165, 131, 91, 174, 45, 133, 156, 51, 62, 117, 110, 49, 42, 48, 113, 134, 155, 28, 119, 135, 53, 170, 146, 22, 8, 7, 83, 99, 100, 139, 40, 168, 18, 73, 84, 13]
    #> Here we define a singleton method
    module_function
    #===
    #> has_ability_usable(launcher, id)
    # Check if the Pokémon has a specific ability and if it's usable.
    #---
    #E : pokemon : PFM::Pokemon   Pokémon that must validate the usability of the ability
    #S : true/false   check
    #===
    def has_ability_usable(pokemon, id)
      return false unless pokemon
      return false unless pokemon.ability == id
      #> Check if the ability is not blocked
      return false if pokemon.battle_effect.has_no_ability_effect?
      #> Check if the ability is blocking
      atk_block_ability = ATK_Block.include?(id)
      #> If the ability is blocking then check Mold Breaker on the actor & its ally
      if(atk_block_ability)
        enemies=BattleEngine.get_enemies!(pokemon)
        enemies.each do |i|
          return false if has_blocking_ability(i)
        end
      end
      return true
    end
    #===
    #> has_abilities(launcher, *ids)
    # Check if the Pokémon has the specified ability & if it's usable.
    #---
    #E : pokemon : PFM::Pokemon   Pokémon that must validate the usability of the ability
    #S : true/false   vérification
    #===
    def has_abilities(pokemon, *ids)
      return false unless ids.include?(pokemon.ability)
      #> Check if the ability is not blocked
      return false if pokemon.battle_effect.has_no_ability_effect?
      id = 0
      atk_block_ability = false
      #> Check if the ability is blocking
      ids.each do |id|
        atk_block_ability |= ATK_Block.include?(id)
      end
      #> If the ability is blocking then check Mold Breaker on the actor & its ally
      if atk_block_ability
        enemies=BattleEngine.get_enemies!(pokemon)
        enemies.each do |i|
          return false if has_blocking_ability(i)
        end
      end
      return true
    end

    Blocking_ability_ids = [66, 162, 163]
    def has_blocking_ability(pokemon)
      return false if pokemon.battle_effect.has_no_ability_effect?
      return Blocking_ability_ids.include?(pokemon.ability)
    end
    #===
    #> enemy_has_ability_usable(launcher, id)
    # Check if one of the enemies has the ability
    # E : launcher : PFM::Pokemon    Launcher that must check if one of the opponent Pokémon has the ability
    # S : true/false   check
    #===
    def enemy_has_ability_usable(launcher, id)
      #> Variable which contains the enemies
      enemies=BattleEngine.get_enemies!(launcher)
      #> Variable which contains the allies
      allies=BattleEngine.get_ally!(launcher)
      #> Check if the move is blocking
      atk_block_ability = ATK_Block.include?(id)
      #> If the ability is blocking then check Mold Breaker on the actor & its ally
      if atk_block_ability
        allies.each do |i|
          return false if has_blocking_ability(i)
        end
      end
      #> We check for enemies
      enemies.each do |i|
        #> Check if the ability is not blocked
        return i if !i.battle_effect.has_no_ability_effect? and i.ability==id
      end
      return false
    end
    #===
    #> Add a message to the BattleEngine stack
    #===
    def _mp(msg)
      ::BattleEngine._mp(msg)
    end
    #===
    #> Add a text message to the stack
    #===
    def _msgp(*args)
      ::BattleEngine._msgp(*args)
    end
  end
end
