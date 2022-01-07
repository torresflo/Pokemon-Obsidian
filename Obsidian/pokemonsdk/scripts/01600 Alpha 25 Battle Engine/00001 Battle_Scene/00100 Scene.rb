# Module that holds all the Battle related classes
module Battle
  # Base classe of all the battle scene
  class Scene < GamePlay::Base
    include Hooks
    # @return [Battle::Visual]
    attr_reader :visual
    # @return [Battle::Logic]
    attr_reader :logic
    # @return [Battle::Logic::BattleInfo]
    attr_reader :battle_info
    # @return [UI::Message::Window]
    attr_reader :message_window
    # @return [Array]
    attr_reader :player_actions
    # @return [Array<AI::Base>]
    attr_reader :artificial_intelligences
    # Set the next update from outside (flee)
    # @return [Symbol]
    attr_accessor :next_update

    # Create a new Battle Scene
    # @param battle_info [Battle::Logic::BattleInfo] informations about the battle
    # @note This method create the banks, the AI, the pokemon battlers and the battle logic
    #       It should call the logic_init event
    def initialize(battle_info)
      # Call the initialize of GamePlay::Base (show message box at z index 10001)
      super(false, 10_001)
      @battle_info = battle_info
      $game_temp.vs_type = battle_info.vs_type
      $game_temp.trainer_battle = battle_info.trainer_battle?
      $game_temp.in_battle = true
      @logic = create_logic
      @logic.load_rng
      @logic.load_battlers
      @visual = create_visual
      @artificial_intelligences = create_ais
      # Next method called in update
      @next_update = :pre_transition
      # List of the player actions
      # @type [Array<Actions::Base>]
      @player_actions = []
      # Battle result
      @battle_result = -1
      # All the event procs
      @battle_events = {}
      # Skip the next frame to go faster in the next update
      @skip_frame = false
      @viewport = @visual.viewport
      # Create the message proc
      create_message_proc
      # Init & call first event
      load_events(logic.battle_info.battle_id)
      call_event(:logic_init)
    end

    # Safe to_s & inspect
    def to_s
      format('#<%<class>s:%<id>08X visual=%<visual>s logic=%<logic>s>', class: self.class, id: __id__, visual: @visual.inspect, logic: @logic.inspect)
    end
    alias inspect to_s

    # Disable the Graphics.transition
    def main_begin() end

    # Update the scene
    def update
      # Update the visuals
      @visual.update
      # Prevent update if a message is showing
      return unless super && !@visual.locking?
      # Call the next method
      next_update_process
    end

    # Process the next update method
    def next_update_process
      @skip_frame = true
      # Force the next update to be called if a frame skip was requested
      while @skip_frame
        @skip_frame = false
        log_debug("Calling #{@next_update} phase")
        send(@next_update)
      end
    end

    # Dispose the battle scene
    def dispose
      super
      @visual.dispose
    end

    # Take a snapshot of the scene
    # @note You have to dispose the bitmap you got from this function
    # @return [Texture]
    def snap_to_bitmap
      temp_view = Viewport.create(:main)
      # Snapshot of spriteset
      bitmaps = @visual.snap_to_bitmaps
      bitmaps.map { |bmp| Sprite.new(temp_view).set_bitmap(bmp) }
      result = temp_view.snap_to_bitmap
      bitmaps.each(&:dispose)
      temp_view.dispose
      # Return actual snapshot
      return result
    end

    private

    # Create a new logic object
    # @return [Battle::Logic]
    def create_logic
      return Battle::Logic.new(self)
    end

    # Create a new visual
    # @return [Battle::Visual]
    def create_visual
      return Battle::Visual.new(self)
    end

    # Create all the AIs
    # @return [Array<Battle::AI::Base>]
    def create_ais
      exec_hooks(Scene, :create_ais, binding)
      return @battle_info.ai_levels.flat_map.with_index do |ai_bank, bank|
        ai_bank.map.with_index do |ai_level, party_id|
          ai_level && AI::Base.registered(ai_level).new(self, bank, party_id, ai_level) || nil
        end
      end.compact
    end

    # Method that call @visual.show_pre_transition and change @next_update to :transition_animation
    def pre_transition
      Audio.bgm_play(*@battle_info.battle_bgm)
      @visual.show_pre_transition
      @next_update = :transition_animation
    end

    # Method that call @visual.show_transition and change @next_update to :player_action_choice
    # @note It should call the battle_begin event
    def transition_animation
      @visual.show_transition
      @next_update = :show_enter_event
    end

    # Method that call all the switch event for the Pokemon that entered the battle in the begining
    def show_enter_event
      @logic.all_alive_battlers.sort_by(&:spd).reverse.each do |battler|
        @logic.switch_handler.execute_switch_events(battler, battler)
      end
      call_event(:battle_begin)
      @next_update = :player_action_choice
    end

    # Create the message proc ensuring the scene is still updated
    def create_message_proc
      @__display_message_proc = proc do
        unless @visual.locking?
          should_unlock = true
          @visual.lock
        end
        # @visual.update if $game_temp.message_window_showing && @message_window.done_drawing_message?
        @visual.unlock if should_unlock
      end
    end

    # Return the message class used by this scene
    # @return [Class]
    def message_class
      return Message
    end
  end
end
