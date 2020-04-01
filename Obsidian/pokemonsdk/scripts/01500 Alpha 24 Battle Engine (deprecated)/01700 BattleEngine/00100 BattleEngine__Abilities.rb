#encoding: utf-8

#noyard
module BattleEngine
  module Abilities
    #>Capacités affectés par Brise Moule
    ATK_Block = [32, 68, 52, 71, 82, 164, 19, 39, 144, 125, 46, 35, 112, 103, 27, 101, 3, 30, 37, 58, 64, 165, 131, 91, 174, 45, 133, 156, 51, 62, 117, 110, 49, 42, 48, 113, 134, 155, 28, 119, 135, 53, 170, 146, 22, 8, 7, 83, 99, 100, 139, 40, 168, 18, 73, 84, 13]
    #>A partir d'ici on défini des singleton method
    module_function
    #===
    #>has_ability_usable(launcher, id)
    # Vérifie si le Pokémon à la capacité spéciale spécifiée et si elle est utilisable
    #---
    #E : pokemon : PFM::Pokemon   Pokemon qui doit valider l'utilisabilité de la capacité
    #S : true/false   vérification
    #===
    def has_ability_usable(pokemon, id)
      return false unless pokemon.ability==id
      #>On vérifie si la capacité spéciale n'est pas bloquée
      return false if pokemon.battle_effect.has_no_ability_effect?
      #>Vérification de si la capacité est bloquante
      atk_block_ability = ATK_Block.include?(id) #>Faire de quoi récupérer cette info
      #>Si elle est bloquante on vérifie brise moule sur l'actor et son allié
      if(atk_block_ability)
        enemies=BattleEngine.get_enemies!(pokemon)
        enemies.each do |i|
          return false if has_blocking_ability(i)
        end
      end
      return true
    end
    #===
    #>has_abilities(launcher, *ids)
    # Vérifie si le Pokémon à la capacité spéciale spécifiée et si elle est utilisable
    #---
    #E : pokemon : PFM::Pokemon   Pokemon qui doit valider l'utilisabilité de la capacité
    #S : true/false   vérification
    #===
    def has_abilities(pokemon, *ids)
      return false unless ids.include?(pokemon.ability)
      #>On vérifie si la capacité spéciale n'est pas bloquée
      return false if pokemon.battle_effect.has_no_ability_effect?
      id = 0
      atk_block_ability = false
      #>Vérification de si la capacité est bloquante
      ids.each do |id|
        atk_block_ability |= ATK_Block.include?(id) #>Faire de quoi récupérer cette info
      end
      #>Si elle est bloquante on vérifie brise moule sur l'actor et son allié
      if(atk_block_ability)
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
    #>enemy_has_ability_usable(launcher, id)
    # Vérifie si l'un des Pokémon énemies a la capacité spécifiée
    #E : launcher : PFM::Pokemon    Lanceur qui doit vérifier si l'un des Pokémon adverse a la capacité
    #S : true/false   vérification
    #===
    def enemy_has_ability_usable(launcher, id)
      #>Variable contenant les ennemis
      enemies=BattleEngine.get_enemies!(launcher)
      #>Variable contenant l'allié
      allies=BattleEngine.get_ally!(launcher)
      #>Vérification de si la capacité est bloquante
      atk_block_ability = ATK_Block.include?(id) #>Faire de quoi récupérer cette info
      #>Si elle est bloquante on vérifie brise moule sur l'actor et son allié
      if(atk_block_ability)
        allies.each do |i|
          return false if has_blocking_ability(i)
        end
      end
      #>On fait la vérification pour les ennemis
      enemies.each do |i|
        #>On vérifie si la capacité spéciale n'est pas bloquée
        return i if i.battle_effect.has_no_ability_effect? and i.ability==id #>Faire la vérification !
      end
      return false
    end
    #===
    #>Ajout d'un message dans le stack de BattleEngine
    #===
    def _mp(msg)
      ::BattleEngine._mp(msg)
    end
    #===
    #>Ajout d'un message textuel dans le stack
    #===
    def _msgp(*args)
      ::BattleEngine._msgp(*args)
    end
  end
end
