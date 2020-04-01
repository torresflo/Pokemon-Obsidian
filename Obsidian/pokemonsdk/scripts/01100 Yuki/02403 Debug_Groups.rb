module Yuki
  class Debug
    # Show the Groups in debug mod
    class Groups
      # List of the Zone type names
      ZONE_TYPE_NAMES = [
        'default (%d)',
        'tall grass (%d)',
        'taller grass (%d)',
        'cave (%d)',
        'mount (%d)',
        'sand (%d)',
        'pond (%d)',
        'sea (%d)',
        'under water (%d)',
        'snow (%d)',
        'ice (%d)',
      ]
      # List of the Zone type names without the tag
      ZONE_TYPE_NAMES_NTAG = [
        'default', 'tall grass', 'taller grass', 'cave', 'mount', 'sand',
        'pond', 'sea', 'under water', 'snow', 'ice'
      ]
      # List of the fishing names
      FISHING_NAMES = {
        normal: 'OldRod (%s)',
        super: 'GoodRod (%s)',
        mega: 'SuperRod (%s)',
        rock: 'Rock Smash (%s)',
        headbutt: 'HeadButt (%s)'
      }
      # Create a new Group viewer
      # @param viewport [Viewport]
      # @param stack [UI::SpriteStack] main stack giving the coordinates to use
      def initialize(viewport, stack)
        @stack = UI::SpriteStack.new(viewport, stack.x, stack.y + 64, default_cache: :b_icon)
        @width = viewport.rect.width - stack.x
        @height = viewport.rect.height - @stack.y
      end

      # Update the view
      def update
        if $scene.is_a?(Scene_Map) && $wild_battle
          @stack.visible ||= true
          if @last_code != $wild_battle.code || @last_id != $game_map.map_id
            @last_code = $wild_battle.code
            @last_id = $game_map.map_id
            @stack.dispose
            load_groups
          end
        else
          @stack.visible &&= false
        end
      end

      # Load the groups
      def load_groups
        @stack.add_text(0, 0, 320, 16, "Zone : #{$env.get_current_zone_data&.map_name}", color: 9)
        y = load_remaining_groups(16)
        load_fishing_groups(y)
      end

      # Load the remaining groups
      # @param y [Integer] initial y position
      # @return [Integer] final y position
      def load_remaining_groups(y)
        x = 0
        name_format = PFM::Pokemon::MALE_NAME
        $wild_battle.remaining_pokemons.each_with_index do |arr, zone|
          break if y >= @height
          arr.each_with_index do |group, tag|
            next unless group
            @stack.add_text(x, y, 320, 16, format(ZONE_TYPE_NAMES[zone], tag), color: 9)
            group.ids.each do |id|
              @stack.push(x, y, format(name_format, id))
              x += 32
              if x >= @width
                y += 32
                x = 0
              end
            end
            y += 32
            x = 0
            break if y >= @height
          end
        end
        return y
      end

      # Load the fishing groups
      # @param y [Integer] initial y position
      def load_fishing_groups(y)
        x = 0
        name_format = PFM::Pokemon::MALE_NAME
        $wild_battle.fishing.each do |type, arr|
          break if y >= @height
          name = FISHING_NAMES[type]
          arr.each_with_index do |group, zone|
            next unless group
            @stack.add_text(x, y, 320, 16, format(name, ZONE_TYPE_NAMES_NTAG[zone]), color: 9)
            group.ids.each do |id|
              @stack.push(x, y, format(name_format, id))
              x += 32
              if x >= @width
                y += 32
                x = 0
              end
            end
            y += 32
            x = 0
            break if y >= @height
          end
        end
      end
    end
  end
end
