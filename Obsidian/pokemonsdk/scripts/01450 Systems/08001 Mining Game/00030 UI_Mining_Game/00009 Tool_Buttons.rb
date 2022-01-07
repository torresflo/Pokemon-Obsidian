module UI
  module MiningGame
    # Class that describes the buttons that let the player choose his tool
    class Tool_Buttons < SpriteStack
      # Coordinates in no dynamite mode
      COORD_Y_2_TOOLS = [0, 80]
      # Coordinates in dynamite mode
      COORD_Y_3_TOOLS = [0, 64, 128]
      # Symbols of the tools
      TOOL_FILENAME = %w[pickaxe mace dynamite]

      # @return [Integer] the currently selected button
      attr_accessor :index
      # @return [Array<SpriteSheet>] the array containing each button
      attr_accessor :buttons
      # @return [Yuki::Animation::TimedAnimation] the animation played when selecting a button
      attr_accessor :animation

      # Create the tool buttons
      # @param viewport [Viewport] the viewport of the scene
      def initialize(viewport)
        super(viewport, *initial_coordinates)
        @index = 0
        # @type [Yuki::Animation::ResolverObjectCommand]
        @animation = nil
        nb_tool = PFM.game_state.mining_game.dynamite_unlocked ? 3 : 2
        coord_y = PFM.game_state.mining_game.dynamite_unlocked ? COORD_Y_3_TOOLS : COORD_Y_2_TOOLS
        @buttons = []
        nb_tool.times { |i| buttons << add_sprite(0, coord_y[i], "mining_game/#{TOOL_FILENAME[i]}", 2, 1, type: SpriteSheet) }
        @button_click_anim = add_sprite(0, 0, 'mining_game/button_anim', 3, 3, type: SpriteSheet)
        @button_click_anim.visible = false
        button_state_change
      end

      # Change the state of each button depending on the one that is hit
      # @param index [Integer] the index of the hitted button
      # @return [Symbol] the symbol of the new tool to use
      def change_buttons_state(index)
        @index = index
        button_state_change
        button_animation
        return TOOL_FILENAME[index].to_sym
      end

      private

      # Initial coordinates of the SpriteStack
      # @return [Array<Integer>]
      def initial_coordinates
        if PFM.game_state.mining_game.dynamite_unlocked
          return 273, 52
        else
          return 273, 76
        end
      end

      # Change the tool buttons state and set the new tool
      # @return [Symbol] the symbol of the new tool to use
      def button_state_change
        @stack.each_with_index { |button, i| button.sx = i == @index ? 1 : 0 }
      end

      # Method that setup the button hit animation
      # @return [Yuki::Animation::TimedAnimation]
      def button_animation
        anim = Yuki::Animation
        @animation = anim.wait(0.01)
        @animation.play_before(anim.send_command_to(@button_click_anim, :sy=, @index))
                  .parallel_add(anim.send_command_to(@button_click_anim, :sx=, 0))
                  .parallel_add(anim.send_command_to(@button_click_anim, :x=, @stack[@index].x - 6))
                  .parallel_add(anim.send_command_to(@button_click_anim, :y=, @stack[@index].y - 8))
                  .parallel_add(anim.send_command_to(@button_click_anim, :visible=, true))
                  .parallel_add(anim.se_play('choose'))
        @animation.play_before(anim.wait(0.04))
        @animation.play_before(anim.send_command_to(@button_click_anim, :sx=, @button_click_anim.sx + 1))
        @animation.play_before(anim.wait(0.04))
        @animation.play_before(anim.send_command_to(@button_click_anim, :sx=, @button_click_anim.sx + 1))
        @animation.play_before(anim.wait(0.04))
        @animation.play_before(anim.send_command_to(@button_click_anim, :visible=, false))
        @animation.start
      end
    end
  end
end
