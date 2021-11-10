#encoding: utf-8

module GamePlay
  # Sprite that show the Ability of a Pokemon
  class BattleAbilityDisplayer < ::Yuki::Sprite
    #>Nom des fichiers
    Files = ["battle_ability_a","battle_ability_e"]
    #>Animation de fade_out
    FadeOutAnim = Array.new(20) do |i|
      next([:opacity=, 255*(20-i)/20])
    end
    FadeOutAnim << [:stop_animation]
    # Creates a new BattleAbilityDisplayer
    # @param viewport [Viewport] The viewport in which the interface is shown
    # @param pokemon [PFM::Pokemon] the Pokemon that has the ability to show
    # @param animation_stack [Array] the stack of animated sprite of the Battle
    def initialize(viewport, pokemon, animation_stack)
      super(viewport)
      set_bitmap(Files[pokemon.position < 0 ? 1 : 0], :interface)
      #> Text generation
      text = parse_text(18, 107, 
        PFM::Text::PKNICK[0] => pokemon.given_name, 
        PFM::Text::ABILITY[1] => pokemon.ability_name)
      align = pokemon.position < 0 ? 2 : 0
      @text = Text.new(0, viewport, 0, 8 - Text::Util::FOY, bitmap.width - 10, 16, nil.to_s, align)
      @text.y -= 8 if(@text.text_width(text) > @text.width)
      @text.multiline_text = text
      @text.load_color(9)
      Audio.se_play(_utf8("audio/se/Ability_Display"))
      @pokemon = pokemon
      ajust_position
      move_to(pokemon.position < 0 ? 320 - self.bitmap.width : 0, self.y, 10)
      @step = 0
      @animation_stack = animation_stack
      animation_stack.push(self)
    end
    # Update the sprite animation
    def update
      @text.x = self.x
      if(@step == 0) #>Apparition
        unless @moving
          @step += 1
        end
      elsif(@step == 40) #>Disparition
        unless @animated
          dispose
          return
        end
      else
        @step += 1
        anime(FadeOutAnim) if(@step == 40)
      end
      super
    end
    # Dispose the sprite
    def dispose
      @animation_stack.delete(self)
      @text.dispose
      super()
    end
    # Adjust the Sprite position according to the Pokemon
    def ajust_position
      if(@pokemon.position < 0)
        pos = BattleBar::E_Pos
        index = $game_temp.vs_type == 2 ? -@pokemon.position - 1 : 2
      else
        pos = BattleBar::A_Pos
        index = $game_temp.vs_type == 2 ? @pokemon.position : 2
      end
      self.set_position(@pokemon.position < 0 ? 320 : -self.bitmap.width, pos[index][1])
      @text.y += pos[index][1]
      @text.z = self.z = 48 + @pokemon.position
    end
  end
end
