module GamePlay
  module Casino
    class SlotMachine < BaseCleanUpdate::FrameBalanced
      include UI::Casino
      # PAYOUT associated to each values
      PAYOUT_VALUES = {
        1 => 3, # v2
        2 => 300, # v3
        6 => 300, # v7
        3 => 12, # v4
        4 => 6, # v5
      }
      # Actions for the mouse
      ACTIONS = %i[action_b action_b action_b action_b]
      # Create a new SlotMachine Scene
      # @param speed [Integer] speed of the machine
      def initialize(speed)
        super()
        @speed = speed
        @update_input_method = :update_input_pay
        @payout = 1
      end

      def update_inputs
        return send(@update_input_method)
      end

      def update_graphics
        @bands.each(&:update)
        @credit_display.update
        @payout_display.update
      end

      # Amount of coin the player has
      # @return [Integer]
      def player_coin
        $game_variables[Yuki::Var::CoinCase]
      end

      # Set the number of coin the player has
      # @param coins [Integer]
      def player_coin=(coins)
        $game_variables[Yuki::Var::CoinCase] = coins
      end

      private

      # Input update when we want the player to pay
      def update_input_pay
        return @running = false if player_coin <= 0
        if Input.trigger?(:A)
          return play_buzzer_se if player_coin < @payout
          play_decision_se
          self.player_coin -= @payout
          @credit_display.target = player_coin
          @bands.each { |band| band.locked = false }
          @update_input_method = :update_input_band
        elsif Input.trigger?(:B)
          action_b
        elsif index_changed(:@payout, :DOWN, :UP, 3, 1)
          play_cursor_se
          @payout_display.number = @payout
        else
          return true
        end
        return false
      end

      # Input update when we want the player to stop bands
      def update_input_band
        if @bands.all?(&:locked)
          if animation_done?
            @update_input_method = :update_input_pay
          end
          return false
        elsif Input.trigger?(:LEFT) && !@bands[0].locked
          play_cursor_se
          @bands[0].locked = true
        elsif Input.trigger?(:UP) && !@bands[1].locked
          play_cursor_se
          @bands[1].locked = true
        elsif Input.trigger?(:RIGHT) && !@bands[2].locked
          play_cursor_se
          @bands[2].locked = true
        else
          return true
        end
        make_new_payout if @bands.all?(&:locked)
        return false
      end

      def update_mouse(moved)
        return if @update_input_method != :update_input_pay
        update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS, true)
      end

      def action_b
        play_cancel_se
        @running = false
      end

      # Tell if the animationes are done
      # @return [Boolean]
      def animation_done?
        @bands.all?(&:done?) && @credit_display.done? && @payout_display.done?
      end

      # Function that makes the new payout
      def make_new_payout
        payout_value = calculate_payout
        if payout_value == :replay
          return @bands.each { |band| band.locked = false }
        end
        @payout_display.number = payout_value
        @payout_display.target = @payout
        @credit_display.target = (self.player_coin += payout_value)
      end

      # Function that calculate the payout depending on the rows
      # @return [Integer, :replay]
      def calculate_payout
        rows = all_rows
        rows.each do |row|
          val = row.first
          if row.all? { |value| value == val }
            payout = PAYOUT_VALUES[val]
            return payout if payout
            return :replay if val == 0
          end
        end
        rows.each do |row|
          return 2 if row.count(5) == 1 # v6 (cherry)
          return 4 if row.count(5) == 2 # v6 (2 cherry)
          return 90 if row.count(2) == 2 && row.count(6) == 1 # ?7 ?7 !7
          return 90 if row.count(2) == 1 && row.count(6) == 2 # !7 !7 ?7
        end
        return 0
      end

      # Function that returns the row depending on the payout
      # @return [Array<Array<Integer>>]
      def all_rows
        return [@bands.collect(&:value)] if @payout == 1
        all_rows = Array.new(3) { |row| @bands.collect { |band| band.value(row) } }
        return all_rows if @payout == 2
        all_rows << @bands.collect.with_index { |band, i| band.value(i) }
        all_rows << @bands.collect.with_index { |band, i| band.value(2 - i) }
        return all_rows
      end

      # Create all the required sprites
      def create_graphics
        create_viewport
        create_base_ui
        create_credit_payout
        create_bands
      end

      # Create the base UI of the slot machine
      def create_base_ui
        @base_ui = BaseUI.new(@viewport, button_texts)
      end

      # Get the button text for the generic UI
      # @return [Array<String>]
      def button_texts
        return [nil, nil, nil, ext_text(9000, 115)]
      end

      def create_credit_payout
        @credit_display = NumberDisplay.new(@viewport, 114, 188, 7)
        @credit_display.number = player_coin
        @payout_display = NumberDisplay.new(@viewport, 174, 188, 3)
        @payout_display.number = @payout
      end

      def create_bands
        @bands = Array.new(3) do |i|
          BandDisplay.new(@viewport, 104 + i * 40, 64, create_band_array, @speed)
        end
        BandDisplay.dispose_images
      end

      # Function that creates a band array
      # @return [Array<Integer>]
      def create_band_array
        band = (0...BandDisplay::FILES.size).to_a.shuffle
        return band + band[0, 3]
      end
    end
  end
end
