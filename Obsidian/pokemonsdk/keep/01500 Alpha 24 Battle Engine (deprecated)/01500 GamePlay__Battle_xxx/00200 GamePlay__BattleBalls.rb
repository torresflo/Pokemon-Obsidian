#encoding: utf-8

module GamePlay
  # Object that show the balls of a Trainer (remaining Pokemons, Pokemon with status)
  class BattleBalls < UI::SpriteStack
    # File names
    Files = ["ball_win","ball_dead","ball_normal","ball_null","ball_sick"]
    # Ball offset
    Offset = 14
    # Create a new Battle Bal
    # @param viewport [Viewport]
    # @param team [Array<PFM::Pokemon>] the pokemon of a trainer
    # @param direction [Boolean] if the balls comes from the right
    def initialize(viewport, team, direction)
      super(viewport)
      #>Stockage de l'équipe
      @team = team
      bmp = ::RPG::Cache.interface(Files[0])
      #>Positionnement automatique
      ox, x = (direction ? [bmp.width, 320] : [0, 0])
      set_position(x, 0)
      push(0, 0, bmp, ox: ox).mirror = direction
      @resources = Array.new(4) { |i| ::RPG::Cache.interface(Files[1+i]) }
      @ball_base_index = @stack.size
      base_offset = Offset
      if direction
        base_x = (bmp.width - base_offset * 6) / 2 - base_offset
        base_offset *= -1
      else
        base_x = bmp.width - (bmp.width - base_offset * 6) / 2
      end
      6.times do |i|
        base_x -= base_offset
        push(base_x, 0, nil, ox: ox)
      end
      redraw
    end
    # Redraw the interface
    def redraw
      6.times do |i|
        pkmn = @team[i]
        if(!pkmn)
          img = @resources[2]
        elsif(pkmn.dead?)
          img = @resources[0]
        elsif(pkmn.status != 0)
          img = @resources[3]
        else
          img = @resources[1]
        end
        @stack[@ball_base_index + i].set_bitmap(img, :interface)
      end
    end
  end
end
