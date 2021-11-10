module Debug
  module AiWindow
    class AIInfo < UI::SpriteStack
      # Get the stack
      # @return [Array<AIWindow>]
      attr_reader :stack

      # Create a new AIInfo
      # @param window [LiteRGSS::DisplayWindow]
      def initialize(window)
        super(LiteRGSS::Viewport.new(window, 0, 0, window.width, window.height))
        viewport.define_singleton_method(:simple_mouse_in?) { |*| true }
        viewport.define_singleton_method(:translate_mouse_coords) { |x, y| [x, y + oy] }
        @data = []
      end

      # Update the data shown
      # @param data [Array<Hash>]
      # @note This will not regenerate the previous stacks, you need to clear everything before doing so!
      def data=(data)
        if data.empty?
          stack.each(&:dispose)
          stack.clear
          return
        end
        # Create the new elements
        @data.size.upto(data.size - 1) do |i|
          push_sprite AIWindow.new(viewport, data[i])
        end
      ensure
        @data = data.clone
      end

      # Update the position of all window
      def update_position
        y = 0
        stack.each do |window|
          window.set_position(16, y)
          y += (window.height + 16)
        end
      end

      # Get the maximum scroll
      def max_scroll
        return 0 if stack.empty?

        (stack.last.y - 32).clamp(0, Float::INFINITY)
      end

      # UI element responsive of showing AI data
      class AIWindow < UI::Window
        # Create a new AIWindow
        # @param viewport [LiteRGSS::Viewport]
        # @param data [Hash]
        def initialize(viewport, data)
          @data = data
          super(viewport, 16, 0, viewport.rect.width - 32, 32)
          # @type [Array<String>]
          @lines = create_lines
          @open = true
          self.height = total_height
          create_sprites
        end

        # Toogle the window
        def toggle
          @open = !@open
          self.height = total_height
        end

        private

        # Create the text lines
        def create_lines
          # @type [Battle::AI::Base]
          ai = @data[:ai]
          lines = ["Bank##{ai.bank} Party##{ai.party_id} Turn##{@data[:turn]}"]
          mapped_actions = @data[:actions].map do |action|
            "  [#{action.first.to_f.round(2)}] #{action_text(action.last)}"
          end
          return lines.concat(mapped_actions)
        end

        # Create all the sprites
        def create_sprites
          @lines.each.each_with_index do |line, i|
            add_text(0, i * 16, 0, 16, line, color: i == 0 ? 1 : 0)
          end
        end

        # Get the total height of the window
        # @return [Integer]
        def total_height
          return 16 + windowskin.height - window_builder[3] + height_adjustment unless @open

          return @lines.size * 16 + windowskin.height - window_builder[3] + height_adjustment
        end

        # Get the height adjustment
        # @return [Integer]
        def height_adjustment
          return -16
        end

        # Get the action text
        # @param action [Battle::Actions::Base]
        def action_text(action)
          case action
          when Battle::Actions::Attack
            attack = Battle::Actions::Attack.from(action)
            return "Move (#{attack.move.name}) #{attack.launcher} -> #{attack.target} (#{attack.move.target})"
          when Battle::Actions::Switch
            switch = Battle::Actions::Switch.from(action)
            return "Switch #{switch.who} -> #{switch.with}"
          when Battle::Actions::Item
            item = Battle::Actions::Item.from(action)
            return "Item #{item.item_wrapper.item.name} -> #{item.user}"
          else
            return "Other #{action}"
          end
        end
      end
    end
  end
end
