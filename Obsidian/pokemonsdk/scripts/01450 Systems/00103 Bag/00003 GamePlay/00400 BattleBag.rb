module GamePlay
  class Battle_Bag < Bag
    # Create a new Battle_Bag
    # @param team [Array<PFM::PokemonBattler>] party that use this bag UI
    def initialize(team)
      super(:battle)
      @team = team
    end
  end
end

GamePlay.battle_bag_class = GamePlay::Battle_Bag
