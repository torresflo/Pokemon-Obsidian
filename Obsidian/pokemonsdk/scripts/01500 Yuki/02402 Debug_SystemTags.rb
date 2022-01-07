module Yuki
  class Debug
    # Show the system tag in debug mod
    class SystemTags
      # Create a new system tags viewer
      # @param viewport [Viewport]
      # @param stack [UI::SpriteStack] main stack giving the coordinates to use
      def initialize(viewport, stack)
        @stack = UI::SpriteStack.new(viewport, stack.x, stack.y + 16, default_cache: :tileset)
        @current_tag_sprite = @stack.push(34, 16, 'prio_w', rect: [0, 0, 32, 32])
        @front_tag_sprite = @stack.push(134, 16, 'prio_w', rect: [0, 0, 32, 32])
        @stack.add_text(0, 0, 100, 16, 'Current SysTag', 1, color: 9)
        @stack.add_text(100, 0, 100, 16, 'Front SysTag', 1, color: 9)
        @terrain_tag = @stack.add_text(34, 16, 32, 16, '', 2, 1, color: 9)
      end

      # Update the view
      def update
        if $scene.is_a?(Scene_Map) && $game_player
          @stack.visible ||= true
          if @last_x != $game_player.x || @last_y != $game_player.y || @last_dir != $game_player.direction
            tag = $game_player.system_tag
            tag = tag < 384 ? 0 : tag - 384
            @current_tag_sprite.src_rect.set(tag % 8 * 32, tag / 8 * 32)
            tag = $game_player.front_system_tag
            tag = tag < 384 ? 0 : tag - 384
            @front_tag_sprite.src_rect.set(tag % 8 * 32, tag / 8 * 32)
            @terrain_tag.text = $game_player.terrain_tag.to_s
            @last_x = $game_player.x
            @last_y = $game_player.y
            @last_dir = $game_player.direction
          end
        else
          @stack.visible &&= false
        end
      end
    end
  end
end
