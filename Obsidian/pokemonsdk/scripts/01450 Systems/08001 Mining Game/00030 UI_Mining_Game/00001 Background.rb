module UI
  module MiningGame
    # Class that describes the Background of the Mining Game
    class Background < Sprite
      # Create the background
      # @param viewport [Viewport] the viewport of the scene
      def initialize(viewport)
        super(viewport)
        set_position(0, 0)
        set_bitmap(background_filename, :interface)
      end

      private

      # The filename of the background depending on the use of the dynamite or not
      # @return [String]
      def background_filename
        PFM.game_state.mining_game.dynamite_unlocked ? 'mining_game/background2' : 'mining_game/background'
      end
    end
  end
end
