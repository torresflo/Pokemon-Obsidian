module Battle
  class AI
    # Create a new Logic instance
    # @param battle_scene [Scene] scene that hold the logic object
    def initialize(battle_scene)
      @battle_scene = battle_scene
    end

    # Trigger the AI work
    # @return [Array<Hash>] the action to do
    def trigger

      return []
    end
  end
end
