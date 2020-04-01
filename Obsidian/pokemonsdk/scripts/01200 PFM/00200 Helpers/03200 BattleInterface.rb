module PFM
  # Module that helps to get data from Battles or to perform actions
  module BattleInterface
    module_function
    # Retrieve an actor
    # @param index [Integer] index of the actor in the team, 1..6 = in $actor, 7..Infinity = in BattleEngine.get_actors
    # @param team [Integer, nil] id of the team (0 = player, 1 = friend, nil = no distinction)
    # @note team is ingored when index > 6
    # @return [PFM::Pokemon, nil]
    def get_actor(index, team = 0)
      index -= 1
      if index < 6
        case team
        when 0
          return $actors[index]
        when 1
          return $storage.other_party[index]
        else
          return ($actors + $storage.other_party)[index]
        end
      end
      if $game_temp.in_battle
        index -= 6
        return BattleEngine.get_actors[index]
      end
      return nil
    end
    # Retrieve an enemy
    # @param index [Integer] index of the actor in the team, 1..6 = in $actor, 7..Infinity = in BattleEngine.get_actors
    # @param team [Integer, nil] id of the team (0 = 1st trainer, 1 = 2nd trainer, nil = no distinction)
    # @return [PFM::Pokemon, nil]
    def get_enemy(index, team = nil)
      return nil unless $game_temp.in_battle
      index -= 1
      if index < 6
        return get_pokemon_from_stack($scene.enemy_party.actors, index, team)
      end
      index -= 6
      return get_pokemon_from_stack(BattleEngine.get_enemies, index, team)
    end
    # Get a pokemon from a stack where there's pokemon from more than 1 trainer
    # @param party [Array<PFM::Pokemon>] party that contain the Pokemon
    # @param index [Integer] index of the Pokemon in the team
    # @param team [Integer, nil] id of the team
    # @param property [Symbol] that gives the team of a Pokemon
    # @return [PFM::Pokemon, nil]
    def get_pokemon_from_stack(party, index, team, property = :trainer_id)
      return party[index] unless team
      real_index = -1
      party.each do |pokemon|
        if pokemon.public_send(property) == team
          real_index += 1
          return pokemon if real_index == index
        end
      end
      return nil
    end
  end
end
