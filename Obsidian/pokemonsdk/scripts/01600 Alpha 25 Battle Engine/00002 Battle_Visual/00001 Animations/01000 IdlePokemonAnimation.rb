module Battle
  class Visual
    class IdlePokemonAnimation
      # Pixel offset for each index of the sprite
      OFFSET_SPRITE = [0, 1, 2, 3, 4, 5, 5, 4, 3, 2, 1, 0]
      # Pixel offset for each index of the bar
      OFFSET_BAR = [0, -1, -2, -3, -4, -5, -5, -4, -3, -2, -1, 0]
      # Create a new IdlePokemonAnimation
      # @param visual [Battle::Visual]
      # @param pokemon [BattleUI::PokemonSprite]
      # @param bar [BattleUI::InfoBar]
      def initialize(visual, pokemon, bar)
        @visual = visual
        @pokemon = pokemon
        # @type [Array<Integer>]
        @pokemon_origin = pokemon.send(:sprite_position)
        @bar = bar
        # @type [Array<Integer>]
        @bar_origin = bar.send(:sprite_position)
        @animation = create_animation
      end

      # Function that updates the idle animation
      def update
        @animation.update
      end

      # Function that rmoves the idle animation from the visual
      def remove
        @pokemon.y = @pokemon_origin.last if @pokemon.in?
        @bar.y = @bar_origin.last if @bar.in?
        @visual.parallel_animations.delete(self.class)
      end

      private

      # Function that create the animation
      # @return [Yuki::Animation::TimedLoopAnimation]
      def create_animation
        root = Yuki::Animation::TimedLoopAnimation.new(1.2)
        pokemon_anim = Yuki::Animation::DiscreetAnimation.new(1.2, self, :move_pokemon, 0, OFFSET_SPRITE.size - 1)
        bar_anim = Yuki::Animation::DiscreetAnimation.new(1.2, self, :move_bar, 0, OFFSET_BAR.size - 1)
        pokemon_anim.parallel_add(bar_anim)
        root.play_before(pokemon_anim)
        root.start
        return root
      end

      # Function that moves the bar using the relative offset specified by 
      def move_bar(index)
        return if @bar.out?

        @bar.y = @bar_origin.last + OFFSET_BAR[index]
      end

      # Function that moves the pokemon using the relative offset specified by 
      def move_pokemon(index)
        return if @pokemon.out?

        @pokemon.y = @pokemon_origin.last + OFFSET_SPRITE[index]
      end
    end
  end
end
