#encoding: utf-8

class Scene_Battle
  # The Skill Selector interface
  # 
  # This interface is used during battle, it allows the user to select the skill he wants his pokemon to use
  class Skill_Selector
    # Creates a new Skill Selector
    def initialize
      @background = Sprite.new
        .set_bitmap("choice_skill", :interface)
      @background.z = 10005
      @selector = Sprite.new
        .set_bitmap("selector_skill", :interface)
      @selector.z = 10025
      @buttons = Array.new(4) { |i| Skill_Element.new(i) }
      self.visible = false
    end
    # Detect if the mouse is inside a button and return its id if so
    # @return [Integer, nil]
    def mouse_action
      @buttons.each_with_index do |sprite, i|
        return i if sprite.simple_mouse_in?
      end
      return nil
    end
    # Update the text of the buttons (if self.visible = false) and adjust the selector position
    # @note You should call <this_object>.visible = true after
    # @param atk_pos [Integer] the position of the selector (0 to 3)
    # @param actor [PFM::Pokemon] the Pokemon use to show the moves
    def update_text(atk_pos, actor)
      unless @selector.visible
        4.times do |i|
          @buttons[i].set_skill(actor.skills_set[i])
        end
      end
      @selector.mirror = (@selector.x = @buttons[atk_pos].x) != 0
      @selector.y = @buttons[atk_pos].y
    end
    # Dispose this interface
    def dispose
      @selector.dispose
      @background.dispose
      @buttons.each { |sprite| sprite.dispose }
    end
    # Set the visibility of the interface
    # @note true only affect the background and the selector, false affect everything. Buttons visibility is managed by update_text when self.visible = false
    # @param v [Boolean]
    def visible=(v)
      @selector.visible = @background.visible = v
      @buttons.each { |sprite| sprite.visible = v } unless v
    end
  end
end
