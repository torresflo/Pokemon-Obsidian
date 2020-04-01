module Battle
  class Visual
    class IdlePokemonAnimation
      # Number of frame require to make the Pokemon move from one pixel
      STATE_FRAME_COUNT = 30
      # Pixel offset for each state of the sprite
      STATE_OFFSET_SPRITE = [-1, 0]
      # Pixel offset for each state of the bar
      STATE_OFFSET_BAR = [1, 0]
      # Create a new IdlePokemonAnimation
      # @param visual [Battle::Visual]
      # @param pokemon [BattleUI::PokemonSprite]
      # @param bar [BattleUI::InfoBar]
      def initialize(visual, pokemon, bar)
        @visual = visual
        @pokemon = pokemon
        @bar = bar
        @counter = STATE_FRAME_COUNT
        @state = 0
        @bar_y = bar.y
        @pokemon_y = pokemon.y
      end

      def update
        @counter += 1
        if @counter >= STATE_FRAME_COUNT
          @counter = 0
          @state = (@state + 1) % STATE_OFFSET_SPRITE.size
          @pokemon.y = @pokemon_y + STATE_OFFSET_SPRITE[@state]
          @bar.y = @bar_y + STATE_OFFSET_BAR[@state]
        end
      end

      def remove
        @pokemon.y = @pokemon_y
        @bar.y = @bar_y
        @visual.parallel_animations.delete(self.class)
      end
    end
  end
end
