module BattleUI
  # Object that display the Battle Party Balls of a trainer in Battle
  #
  # Remaining Pokemon, Pokemon with status
  class TrainerPartyBalls < UI::SpriteStack
    include UI
    include GoingInOut
    include MultiplePosition
    # X coordinate of the first ball in the stack depending on the bank
    BALL_X = [3, 7]
    # Y coordinate of the first ball in the stack depending on the bank
    BALL_Y = [-3, -3]
    # Delta X between each balls
    BALL_DELTA = 14
    # Get the animation handler
    # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    attr_reader :animation_handler
    # Get the position
    # @return [Integer]
    attr_reader :position
    # Get the bank of the party shown
    # @return [Integer]
    attr_reader :bank
    # Get the scene linked to this object
    # @return [Battle::Scene]
    attr_reader :scene

    # Create a new Trainer Party Balls
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    # @param bank [Integer]
    def initialize(viewport, scene, bank)
      super(viewport)
      @animation_handler = Yuki::Animation::Handler.new
      @bank = bank
      @position = 0
      @scene = scene
      create_graphics
      set_position(*sprite_position)
      refresh
      go_out(-999)
      update
    end

    # Update all the animation of this UI element
    def update
      @animation_handler.update
    end

    # Refresh the content of the bar
    def refresh
      self.data = 6.times.map { |i| @scene.logic.battler(@bank, i) }
    end

    # Tell if the UI has done displaying its animation
    # @return [Boolean]
    def done?
      return @animation_handler.done?
    end

    private

    # Get the base position of the Pokemon in 1v1
    # @return [Array(Integer, Integer)]
    def base_position_v1
      return @viewport.rect.width, 0 if enemy? && !@scene.battle_info.trainer_battle?
      return 227, 48 if enemy?

      return 0, 173
    end
    alias base_position_v2 base_position_v1

    # Get the offset position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def offset_position_v2
      return 0, 0
    end

    # Creates the go_in animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_in_animation
      origin_x = enemy? ? @viewport.rect.width : -@background.width

      return Yuki::Animation.move_discreet(0.2, self, origin_x, y, *sprite_position)
    end

    # Creates the go_out animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_out_animation
      target_x = enemy? ? @viewport.rect.width : -@background.width

      return Yuki::Animation.move_discreet(0.2, self, *sprite_position, target_x, y)
    end

    def create_graphics
      create_background
      create_balls
    end

    def create_background
      @background = add_background(enemy? ? 'battle/ball_win_enemy' : 'battle/ball_win_actor')
    end

    def create_balls
      base_x = BALL_X[@bank] || 0
      base_y = BALL_Y[@bank] || 0
      # @type [Array<BallSprite>]
      @balls = 6.times.map do |i|
        add_sprite(base_x + i * BALL_DELTA, base_y, NO_INITIAL_IMAGE, i, type: BallSprite)
      end
    end

    # Class showing a ball in the TrainerPartyBalls UI
    class BallSprite < Sprite
      # Create a new ball
      # @param viewport [Viewport]
      # @param index [Integer]
      def initialize(viewport, index)
        super(viewport)
        @index = index
      end

      # Update the data
      # @param party [Array<PFM::PokemonBattler>]
      def data=(party)
        pokemon = party[@index]
        set_bitmap(image_filename(pokemon), :interface)
      end

      # Get the filename of the image to show as ball sprite
      # @param pokemon [PFM::PokemonBattler]
      def image_filename(pokemon)
        return 'battle/ball_null' unless pokemon
        return 'battle/ball_dead' if pokemon.dead?
        return 'battle/ball_sick' if pokemon.status != 0

        return 'battle/ball_normal'
      end
    end
  end
end
