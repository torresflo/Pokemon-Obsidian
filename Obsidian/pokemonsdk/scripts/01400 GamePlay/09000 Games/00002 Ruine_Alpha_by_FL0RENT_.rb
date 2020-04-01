class Interpreter
  def puzzle_alpha(id = 1, id_switch = Yuki::Sw::RuinsVictory)
    $game_switches[id_switch] = false
    $scene = GamePlay::Alph_Ruins_Puzzle.new(id, id_switch)
    @wait_count = 2
  end
end

module GamePlay
  class Alph_Ruins_Puzzle
    #Choix des fichiers son
    #SE
    MOVESOUND1 = "Audio/SE/psn" #mouvement sans piece
    MOVESOUND2 = "Audio/SE/hitlow" #mouvement avec piece
    PLACESOUND = MOVESOUND2 #pose de piece
    TAKESOUND = nil #prise de piece
    #BGM
    VICTORY_THEME = "Audio/ME/ROSA_YourPokemonEvolved.ogg"
    #Images
    GR_CursorB = "Puzzle_Ruines Curseur_b"
    GR_Cursor = "Puzzle_Ruines Curseur"
    GR_Background = "Puzzle_Ruines Fond"
    GR_Background2 = "Puzzle_Ruines Fond2"
    #> Offset
    BaseOffsetX = 112 - 24
    BaseOffsetY = 72 - 24

    def initialize(id, id_switch)
      @viewport = Viewport.create(:main, 100)
      @id_switch = id_switch
      @background = Plane.new(@viewport)
      @background.bitmap = RPG::Cache.interface(GR_Background)
      @background2 = Sprite.new(@viewport)
      @background2.bitmap = RPG::Cache.interface(GR_Background2)
      @background2.x = 112
      @background2.y = 72
      @grid = Array.new(6) { Array.new(6) }
      @pieces = []
      @cursor_piece = nil
      @cursor = Sprite.new(@viewport)
      @cursor.bitmap = RPG::Cache.interface(GR_Cursor)
      @cursor.z = 9001
      @cursor_x = 0
      @cursor_y = 0
      @cursor_wait = 0
      #> Génération des images des pièces
      bmp = RPG::Cache.interface("Puzzle_Ruines #{id}")
      @pieces = Array.new(16) do |i|
        img = Sprite.new(@viewport)
        img.bitmap = bmp
        img.src_rect.set(24 * (i / 4), 24 * (i % 4), 24, 24)
        next(img)
      end
      #> Tri aléatoire des pièces
      @pieces.each do |piece|
        verif = false
        until verif
          a = rand(3)
          case a
          when 0
            b = rand(6)
            if @grid[0][b] == nil
              verif = true
              @grid[0][b] = piece
            end
          when 1
            b = rand(6)
            if @grid[5][b] == nil
              verif = true
              @grid[5][b] = piece
            end
          when 2
            b = rand(4)
            if @grid[b + 1][0] == nil
              verif = true
              @grid[b + 1][0] = piece
            end
          end
        end
      end
      pieces_position
      @viewport.sort_z
    end

    def main
      Graphics.transition
      while $scene == self
        Graphics.update
        update
        if victory_check
          $game_switches[@id_switch] = true
          if VICTORY_THEME
            Audio.me_play(VICTORY_THEME)
            wait(80)
            wait_hit
            $scene = Scene_Map.new
          else
            wait(120)
            $scene = Scene_Map.new
          end
        end
      end

      Graphics.freeze
      dispose
    end

    
    def update
      if @cursor_piece == nil
        @cursor_wait += 1
        @cursor_wait = 0 if @cursor_wait > 40
        @cursor.opacity = 0 if @cursor_wait == 20
        @cursor.opacity = 255 if @cursor_wait == 0
      end
      if Input.trigger?(:B)
        return $scene = Scene_Map.new
      elsif Input.trigger?(:DOWN)
        unless @cursor_y >= 5 or (@cursor_y == 4 and @cursor_x != 0 and @cursor_x != 5)
          @cursor_y += 1
          move
        end
      elsif Input.trigger?(:UP)
        unless @cursor_y == 0
          @cursor_y -= 1
          move
        end
      elsif Input.trigger?(:RIGHT)
        unless @cursor_x >= 5 or @cursor_y == 5
          @cursor_x += 1
          move
        end
      elsif Input.trigger?(:LEFT)
        unless @cursor_x == 0 or @cursor_y == 5
          @cursor_x -= 1
          move
        end
      elsif Input.trigger?(:A)
        if @cursor_piece == nil
          if @grid[@cursor_x][@cursor_y]
            wait 4
            @cursor_piece = @grid[@cursor_x][@cursor_y]
            @grid[@cursor_x][@cursor_y] = nil
            Audio.se_play(TAKESOUND, 80) if TAKESOUND
            @cursor.bitmap = RPG::Cache.interface(GR_CursorB)
            @cursor.opacity = 255
            @cursor_wait = 0
          end
        else
          if @grid[@cursor_x][@cursor_y] == nil
            wait 4
            @grid[@cursor_x][@cursor_y] = @cursor_piece
            @cursor_piece = nil
            Audio.se_play(PLACESOUND) if PLACESOUND
            @cursor.bitmap = RPG::Cache.interface(GR_Cursor)
          end
        end
      else
        return #> Condition évitant le pieces_position quand aucune action est réalisée
      end
      pieces_position
    end

    def dispose
      @background.dispose
      @background2.dispose
      @cursor.dispose
      @pieces.each do |p|
        p.dispose
      end
    end

    
    def victory_check
      4.times do |x|
        4.times do |y|
          if @grid[x + 1][y + 1] != @pieces[y + (4 * x)]
            return false
          end
        end
      end
      return true
    end

    def pieces_position
      @cursor.x = BaseOffsetX + @cursor_x * 24
      @cursor.y = BaseOffsetY + @cursor_y * 24

      for piece in @pieces
        if @cursor_piece == piece
          piece.x = BaseOffsetX + @cursor_x * 24
          piece.y = BaseOffsetY + @cursor_y * 24
          piece.z = 1
        else
          for line in @grid
            if line.include?(piece)
              x = @grid.index(line).to_i
              y = line.index(piece).to_i
              piece.x = BaseOffsetX + x * 24
              piece.y = BaseOffsetY + y * 24
              piece.z = 0
            end
          end
        end
      end
    end

    def wait(x)
      Graphics.wait(x * 3 / 2)
    end

    def wait_hit
      until Input.trigger?(:A) or Input.trigger?(:B)
        Graphics.update
      end
    end

    def move
      if @cursor_piece == nil
        Audio.se_play(MOVESOUND1, 80) if MOVESOUND1
        wait(5)
        @cursor.opacity = 255
        @cursor_wait = 0
      else
        Audio.se_play(MOVESOUND2, 80) if MOVESOUND2
        wait(5)
      end
    end
  end
end
