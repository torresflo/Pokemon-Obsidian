module PFM
  # Class that help to make choice inside Interfaces
  class Choice_Helper
    # Create a new Choice_Helper
    # @param klass [Class] class used to display the choice
    # @param can_cancel [Boolean] if the user can cancel the choice
    # @param cancel_index [Integer, nil] Index returned if the user cancel
    def initialize(klass, can_cancel = true, cancel_index = nil)
      # List of registered choices
      # @type [Array<Hash>]
      @choices = []
      # Class used to display the choice
      # @type [Class]
      @class = klass
      @can_cancel = can_cancel
      @cancel_index = cancel_index
    end

    # Return the number of choices (for calculation)
    # @return [Integer]
    def size
      return @choices.size
    end

    # Cancel the choice from outside
    def cancel
      @canceled = true
    end

    # Register a choice
    # @param text [String]
    # @param disable_detect [#call, nil] handle to call to detect if the choice is disabled or not
    # @param on_validate [#call, nil] handle to call when the choice validated on this choice
    # @param color [Integer, nil] non default color to use on this choice
    # @param args [Array] arguments to send to the disable_detect and on_validate handler
    # @return [self]
    def register_choice(text, *args, disable_detect: nil, on_validate: nil, color: nil)
      @choices << { text: text, args: args, disable_detect: disable_detect, on_validate: on_validate, color: color }
      return self
    end

    # Display the choice
    # @param viewport [Viewport] viewport in wich the choice is shown
    # @param x [Integer] x coordinate of the choice window
    # @param y [Integer] y coordinate of the choice window
    # @param width [Integer] width of the choice window
    # @param on_update [#call, nil] handle to call during choice update
    # @param align_right [Boolean] tell if the x/y coordinate are the top right coordinate of the choice
    # @param args [Array] argument to send to the on_update handle
    # @return [Integer] the choice made by the user
    def display_choice(viewport, x, y, width, *args, on_update: nil, align_right: false)
      @canceled = false
      # @type [Yuki::ChoiceWindow]
      window = build_choice_window(viewport, x, y, width, align_right)
      loop do
        Graphics.update
        next if Graphics::FPSBalancer.global.skipping? && (!$scene.message_window || $scene.message_window.can_sub_window_be_updated?)

        window.update
        on_update&.call(*args)
        break if check_cancel(window)
        break if check_validate(window)
      end
      $game_system.se_play($data_system.decision_se)
      index = window.index
      window.dispose
      call_validate_handle(index)
      return index
    end

    private

    # Build the choice window
    # @param viewport [Viewport] viewport in wich the choice is shown
    # @param x [Integer] x coordinate of the choice window
    # @param y [Integer] y coordinate of the choice window
    # @param width [Integer] width of the choice window
    # @param align_right [Boolean] tell if the x/y coordinate are the top right coordinate of the choice
    # @return [Yuki::ChoiceWindow]
    def build_choice_window(viewport, x, y, width, align_right)
      # @type [Array<String>]
      choice_list = @choices.collect { |c| c[:text] }
      # Choice window
      # @type [Yuki::ChoiceWindow]
      window = @class.new(width, choice_list, viewport)
      window.set_position(x - (align_right ? window.width : 0), y)
      window.z = viewport ? viewport.z : 1000
      @choices.each_with_index do |c, i|
        if c[:disable_detect]&.call(*c[:args])
          window.colors[i] = window.get_disable_color
        elsif c[:color]
          window.colors[i] = c[:color]
        end
      end
      window.refresh
      Graphics.sort_z
      return window
    end

    # Check if the choice is validated (enabled and choosen by the player)
    # @param window [Choice_Window] the choice window
    def check_validate(window)
      return false unless window.validated?
      choice = @choices[window.index]
      return true unless choice[:disable_detect]
      if choice[:disable_detect].call(*choice[:args])
        $game_system.se_play($data_system.buzzer_se)
        return false
      end
      return true
    end

    # Check if the choice is canceled by the user
    # @param window [Choice_Window] the choice window
    def check_cancel(window)
      return false unless @can_cancel
      return false unless Input.trigger?(:B) or @canceled
      if @cancel_index && @cancel_index >= 0
        window.index = @cancel_index
      elsif @cancel_index
        window.index = @choices.size + @cancel_index
      else
        window.index = @choices.size - 1
      end
      return true
    end

    # Attempt to call the on_validate handle when the user has choosen an option
    # @param index [Integer] choice made by the user
    def call_validate_handle(index)
      choice = @choices[index]
      return unless choice
      return unless choice[:on_validate]
      choice[:on_validate].call(*choice[:args])
    end
  end
end
