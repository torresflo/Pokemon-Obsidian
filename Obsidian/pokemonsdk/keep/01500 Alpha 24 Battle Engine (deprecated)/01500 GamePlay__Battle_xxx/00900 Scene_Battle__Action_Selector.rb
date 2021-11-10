#encoding: utf-8

# Scene that define a Pokemon Battle
class Scene_Battle
  # Action Selector interface
  #
  # This interface is used during battle and allows the user to choose an action on a specific Pokemon
  class Action_Selector < UI::SpriteStack
    # Constant that define the Action Selector background
    Bar="Choice_4"
    # Constant that define the Selector image
    Selector="Choice_Select"
    # Creates a new Action Selector interface
    def initialize
      super(nil)
      push(0, 0, "choice_4").z = 10005
      @select_sprite = push(0, 0, "choice_select")
      @select_sprite.z = z = 10006
      push(281, 115, nil, type: UI::PokemonIconSprite).z = z
      add_text(256, 28, 64, 135, text_get(32,0), 1, 1, color: 9).z = z
      add_text(0, 49, 62, 18, text_get(32,2), 1, 1, color: 9).z = z
      add_text(0, 117, 62, 18, text_get(32,1), 1, 1, color: 9).z = z
      add_text(109, 158, 102, 34,text_get(32,3), 1, 1, color: 9).z = z
      self.visible = false
      self.pos_selector(0)
    end
    # Sets the position of the selector
    # @param action_index [Integer] the index of the action (0 to 3)
    def pos_selector(action_index)
      sprite = @select_sprite
      sprite.angle = 0
      sprite.ox = sprite.oy = 0
      sprite.mirror = false
      case action_index
      when 0 #> Attaquer
        sprite.x = 233
        sprite.y = 81
        sprite.mirror = true
      when 1 #> Pokémon
        sprite.x = 54
        sprite.y = 42
      when 2 #> Sac
        sprite.x = 54
        sprite.y = 111
      else
        sprite.x = 159
        sprite.y = 148
        sprite.ox = sprite.oy = 16
        sprite.angle = 90
      end
    end
    # Sets the Pokemon used to show the Action Selector
    alias pokemon= data=
    # Ranges that describe the Attack button surface
    ATK = [257..319, 29..161]
    # Ranges that describe the Pokemon button surface
    POK = [0..61, 32..93]
    # Ranges that describe the Bag button surface
    BAG = [0..61, 100..161]
    # Ranges that describe the Flee button surface
    RUN = [98..221, 158..191]
    # Action to do when mouse clicks on the interface
    # @param index [Integer] the index of the current action
    # @return [Array(Symbol, Integer)] forced_action, new_index
    # @note forced_action return can be nil
    def mouse_action(index)
      mx, my = @stack[0].translate_mouse_coords
      return :A, 0 if ATK[0].include?(mx) and ATK[1].include?(my)
      return :A, 1 if POK[0].include?(mx) and POK[1].include?(my)
      return :A, 2 if BAG[0].include?(mx) and BAG[1].include?(my)
      return :A, 3 if RUN[0].include?(mx) and RUN[1].include?(my)
      return nil, index
    end
  end
end
