#encoding: utf-8

# Collection of Game_Actor
class Game_Actors
  # Default initialization
  def initialize
    @data = []
  end
  # Fetch Game_Actor
  # @param actor_id [Integer] id of the Game_Actor in the database
  # @return [Game_Actor, nil]
  def [](actor_id)
    if actor_id > 999 or $data_actors[actor_id] == nil
      return nil
    end
    if @data[actor_id] == nil
      @data[actor_id] = Game_Actor.new(actor_id)
    end
    return @data[actor_id]
  end
end
