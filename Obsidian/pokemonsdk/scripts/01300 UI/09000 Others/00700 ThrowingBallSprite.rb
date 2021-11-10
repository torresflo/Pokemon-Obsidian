module UI
  # Sprite responsive of showing the sprite of the Ball we throw to Pokemon or to release Pokemon
  class ThrowingBallSprite < SpriteSheet
    # Array mapping the move progression to the right cell
    MOVE_PROGRESSION_CELL = [17, 16, 15, 16, 17, 18, 19, 18, 17]
    # Create a new ThrowingBallSprite
    # @param viewport [Viewport]
    # @param pokemon_or_item [PFM::Pokemon, GameData::BallItem]
    def initialize(viewport, pokemon_or_item)
      super(viewport, 1, 32)
      resolve_image(pokemon_or_item)
      self.sy = 3
    end

    # Function that adjust the sy depending on the progression of the "throw" animation
    # @param progression [Float]
    def throw_progression=(progression)
      self.sy = (progression * 4).floor.clamp(0, 3)
    end

    # Function that adjust the sy depending on the progression of the "open" animation
    # @param progression [Float]
    def open_progression=(progression)
      self.sy = (progression * 2).floor.clamp(0, 1) + 4
    end

    # Function that adjust the sy depending on the progression of the "close" animation
    # @param progression [Float]
    def close_progression=(progression)
      target = (progression * 9).floor
      if target == 9
        self.sy = 3
      else
        self.sy = target + 6
      end
    end

    # Function that adjust the sy depending on the progression of the "move" animation
    # @param progression [Float]
    def move_progression=(progression)
      self.sy = MOVE_PROGRESSION_CELL[(progression * 8).floor]
    end

    # Function that adjust the sy depending on the progression of the "break" animation
    # @param progression [Float]
    def break_progression=(progression)
      self.sy = (progression * 7).floor.clamp(0, 6) + 20
    end

    # Function that adjust the sy depending on the progression of the "caught" animation
    # @param progression [Float]
    def caught_progression=(progression)
      target = (progression * 5).floor
      if target == 5
        self.sy = 17
      else
        self.sy = 27 + target
      end
    end

    # Get the ball offset y in order to make it the same position as the Pokemon sprite
    # @return [Integer]
    def ball_offset_y
      return 8
    end

    # Get the ball offset y in order to make it look like being in trainer's hand
    # @return [Integer]
    def trainer_offset_y
      return 40
    end

    private

    # Resolve the sprite image
    # @param pokemon_or_item [PFM::Pokemon, GameData::BallItem]
    def resolve_image(pokemon_or_item)
      # @type [GameData::BallItem]
      item = pokemon_or_item.is_a?(PFM::Pokemon) ? GameData::Item[pokemon_or_item.captured_with] : pokemon_or_item
      unless item.is_a?(GameData::BallItem)
        log_error("The parameter #{pokemon_or_item} did not endup into GameData::BallItem object...")
        return
      end

      self.bitmap = RPG::Cache.ball(item.img)
      set_origin(width / 2, height / 2)
    end
  end
end
