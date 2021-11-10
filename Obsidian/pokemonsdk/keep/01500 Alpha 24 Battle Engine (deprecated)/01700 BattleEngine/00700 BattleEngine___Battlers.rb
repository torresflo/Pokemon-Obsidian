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
end

