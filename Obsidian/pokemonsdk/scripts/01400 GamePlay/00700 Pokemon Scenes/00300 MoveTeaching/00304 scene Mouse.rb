module GamePlay
  class MoveTeaching
    # Function responsive of updating the mouse
    def update_mouse(moved)
      return true unless moved || Mouse.trigger?(:LEFT)

      old_index = @index
      @skill_set.each_with_index do |skill, index|
        next unless skill.simple_mouse_in?

        @index = index
        swap_buttons(old_index)
        action_a unless moved
        break
      end
    end
  end
end
