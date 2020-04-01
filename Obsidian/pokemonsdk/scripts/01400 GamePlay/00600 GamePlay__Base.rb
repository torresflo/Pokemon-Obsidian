module GamePlay
  # The base class of every GamePlay scene interface
  #
  # Add some usefull functions like message display and scene switch and perform the most of the task for you.
  #   Generic Process of a GamePlay::Base
  #     1. initialize
  #       1.1 Create the message box (if called by super(false) or super())
  #     2. main
  #     2.1 main_begin
  #       2.1.1 create_graphics
  #       2.1.2 Graphics.transition (fade in)
  #     2.2 loop { update }
  #     2.3 main_end
  #       2.3.1 Graphics.freeze (fade out)
  #       2.3.2 dispose : grep all the /viewport/ ivar and dispose them
  #     3. update (in GamePlay::BaseCleanUpdate)
  #       3.1 update message
  #       3.2 update inputs (if not locked by message)
  #       3.3 update mouse (if not locked by inputs)
  #       3.4 update graphics (always)
  #
  # This class is inherited by GamePlay::BaseCleanUpdate
  #
  # You usually will define your Scene the following way :
  # ```ruby
  #   class Scene < BaseCleanUpdate
  #     # Create a new scene
  #     # @param args [Array] input arguments (do something better than *args)
  #     def initialize(*args)
  #       super() # <= the () force super to be called without argument because by `super` alone use the method arguments!
  #       # Initialize only the logic here (instance variable used for the state or data used by the UI)
  #     end
  #
  #     # Called when input can be updated (put your input related code inside)
  #     # @return [Boolean] if the update can continue
  #     def update_inputs
  #       # ...
  #       return true
  #     end
  #
  #     # Called when mouse can be updated (put your mouse related code inside, optional)
  #     # @param moved [Boolean] boolean telling if the mouse moved
  #     # @return [Boolean] if the update can continue
  #     def update_mouse(moved)
  #       return unless moved
  #       # ...
  #       return true
  #     end
  #
  #     # Called each frame after message update and eventual mouse/input update
  #     # @return [Boolean] if the update can continue
  #     def update_graphics
  #       # ...
  #       return true
  #     end
  #
  #     private
  #
  #     # Create all the UI and thing related to graphics (super create the viewport)
  #     def create_graphics
  #       create_viewport # Necessary to make the scene work properly
  #       # ...
  #     end
  #
  #     # (optional) Create the viewport (called by create_graphics from Base)
  #     def create_viewport
  #       super # < if you still use main with default settings, otherwise don't call super
  #       @sub_viewport = Viewport.create(...) # < Sub viewport for other stuff
  #     end
  #   end
  # ```
  #
  # Note : You don't have to define the dispose function with this. All the viewport that are stored inside ivar will be
  #       automatically disposed if the variable name contains viewport.
  # @author Nuri Yuri
  class Base
    # Default fade type used to switch between interfaces
    # @return [Symbol] :transition (for Graphics.freeze/transition), :fade_bk (for fade through black)
    DEFAULT_TRANSITION = :transition
    # Parameters of the transition
    # @return [Integer, Array] (usually the number of frame for the transition)
    DEFAULT_TRANSITION_PARAMETER = 16
    # Message the displays when a GamePlay scene has been initialized without message processing and try to display a message
    MESSAGE_ERROR = 'This interface has no MessageWindow, you cannot call display_message'
    ::PFM::Text.define_const(self)
    include Sprites
    include Input
    # The viewport in which the scene is shown
    # @return [Viewport, nil]
    attr_reader :viewport
    # The scene that called this scene (usefull when this scene needs to return to the last scene)
    # @return [#main]
    attr_reader :__last_scene
    # The message window
    # @return [Yuki::Message, nil]
    attr_reader :message_window
    # The process that is called when the call_scene method returns
    # @return [Proc, nil]
    attr_accessor :__result_process
    # If the current scene is still running
    # @return [Boolean]
    attr_accessor :running
    # Create a new GamePlay scene
    # @param no_message [Boolean] if the scene is created wihout the message management
    # @param message_z [Integer] the z superiority of the message
    # @param message_viewport_args [Array] if empty : [:main, message_z] will be used.
    def initialize(no_message = false, message_z = 10_001, *message_viewport_args)
      # List of object to dispose in #dispose
      @object_to_dispose = []
      # Force the message window of the map to be closed
      $scene.window_message_close(true) if $scene.class == Scene_Map
      message_initialize(no_message, message_z, message_viewport_args)
      # Store the current scene
      @__last_scene = $scene
      _init_sprites
      message_soft_lock_prevent
    end

    # Scene update process
    # @return [Boolean] if the scene should continue the update process or abort it (message/animation etc...)
    def update
      continue = true
      # We update the message window if there's a message window
      if @message_window
        @message_window.update
        return false if $game_temp.message_window_showing
      end
      return continue
    end

    # Dispose the scene graphics.
    # @note @viewport and @message_window will be disposed.
    def dispose
      message_soft_lock_prevent
      @message_window&.dispose(with_viewport: true) unless @inherited_message_window || @message_window == false
      @object_to_dispose.each { |object| object.dispose unless object.disposed? }
      instance_variables.grep(/viewport/).collect { |ivar| instance_variable_get(ivar) }.each do |vp|
        vp.dispose if vp.is_a?(Viewport) && !vp.disposed?
      end
    end

    # Add a disposable object to the "object_to_dispose" array
    # @param args [Array<#dispose>]
    def add_disposable(*args)
      @object_to_dispose.concat(args)
    end

    # The GamePlay entry point (Must not be overridden).
    def main
      raise 'You forgot to call super in initialize of your scene' unless @object_to_dispose
      # Store the last scene and store self in $scene
      @__last_scene = $scene if $scene != self
      $scene = self
      # Tell the interface is running
      @running = true
      # Main processing
      main_begin
      main_process
      main_end
      # Reset $scene unless it was already done
      $scene = @__last_scene if $scene == self
    end

    # Change the viewport visibility of the scene
    # @param value [Boolean]
    def visible=(value)
      @viewport.visible = value if @viewport
      @message_window.viewport.visible = value if @message_window
    end

    # Display a message with choice or not
    # @param message [String] the message to display
    # @param start [Integer] the start choice index (1..nb_choice)
    # @param choices [Array<String>] the list of choice options
    # @return [Integer, nil] the choice result
    def display_message(message, start = 1, *choices)
      raise ScriptError, MESSAGE_ERROR unless @message_window
      # message = @message_window.contents.multiline_calibrate(message)
      $game_temp.message_text = message
      processing_message = true
      $game_temp.message_proc = proc { processing_message = false }
      # Choice management
      choice = nil
      unless choices.empty?
        $game_temp.choice_max = choices.size
        $game_temp.choice_cancel_type = choices.size
        $game_temp.choice_proc = proc { |i| choice = i }
        $game_temp.choice_start = start
        $game_temp.choices = choices
      end
      edit_max = $game_temp.num_input_start > 0
      # Message update
      while processing_message
        Graphics.update
        @message_window.update
        @__display_message_proc&.call
        if edit_max && @message_window.input_number_window
          edit_max = false
          @message_window.input_number_window.max = $game_temp.num_input_start
        end
      end
      Graphics.update
      return choice
    end

    # Display a message with choice or not. This method will wait the message window to disappear
    # @param message [String] the message to display
    # @param start [Integer] the start choice index (1..nb_choice)
    # @param choices [Array<String>] the list of choice options
    # @return [Integer, nil] the choice result
    def display_message_and_wait(message, start = 1, *choices)
      choice = display_message(message, start, *choices)
      close_message_window
      return choice
    end

    # Call an other scene
    # @param name [Class] the scene to call
    # @param args [Array] the parameter of the initialize method of the scene to call
    # @return [Boolean] if this scene can still run
    def call_scene(name, *args, &result_process)
      fade_out(@cfo_type || DEFAULT_TRANSITION, @cfo_param || DEFAULT_TRANSITION_PARAMETER)
      # Make the current scene invisible
      self.visible = false
      result_process ||= @__result_process
      @__result_process = nil
      scene = name.new(*args)
      scene.main
      # Call the result process if any
      result_process&.call(scene)
      # If the scene has changed we stop this one
      return @running = false if $scene != self || !@running
      self.visible = true
      fade_in(@cfi_type || DEFAULT_TRANSITION, @cfi_param || DEFAULT_TRANSITION_PARAMETER)
      return true
    end

    # Return to an other scene, create the scene if args.size > 0
    # @param name [Class] the scene to return to
    # @param args [Array] the parameter of the initialize method of the scene to call
    # @note This scene will stop running
    # @return [Boolean] if the scene has successfully returned to the desired scene
    def return_to_scene(name, *args)
      if args.empty?
        scene = self
        while scene.is_a?(Base)
          scene = scene.__last_scene
          break if scene == self
          next unless scene.class == name
          $scene = scene
          @running = false
          return true
        end
        return false
      end
      $scene = name.new(*args)
      @running = false
      return true
    end

    private

    # The main process at the begin of scene
    def main_begin
      create_graphics
      sort_sprites
      fade_in(@mbf_type || DEFAULT_TRANSITION, @mbf_param || DEFAULT_TRANSITION_PARAMETER)
    end

    # The main process (block until scene stop running)
    def main_process
      while @running
        Graphics.update
        update
      end
    end

    # The main process at the end of the scene (when scene is not running anymore)
    def main_end
      fade_out(@mef_type || DEFAULT_TRANSITION, @mef_param || DEFAULT_TRANSITION_PARAMETER)
      dispose
    end

    # Initialize the window related interface of the UI
    # @param no_message [Boolean] if the scene is created wihout the message management
    # @param message_z [Integer] the z superiority of the message
    # @param message_viewport_args [Array] if empty : [:main, message_z] will be used.
    def message_initialize(no_message, message_z, message_viewport_args)
      if no_message.is_a?(::Yuki::Message)
        @message_window = no_message
        @inherited_message_window = true
      elsif no_message
        @message_window = false
      else
        # if $game_temp.in_battle
        #  @message_window = ::Scene_Battle::Window_Message.new
        #  @message_window.wait_input = true
        # else
        message_viewport_args = [:main, message_z] if message_viewport_args.empty?
        @message_window = message_class.new(Viewport.create(*message_viewport_args), self)
        # end
        @message_window.z = message_z
      end
    end

    # Force the message window to "close"
    def close_message_window
      return unless @message_window
      while $game_temp.message_window_showing
        Graphics.update
        yield if block_given?
        @message_window.update
      end
    end

    # Perform an index change test and update the index (rotative)
    # @param varname [Symbol] name of the instance variable that plays the index
    # @param sub_key [Symbol] name of the key that substract 1 to the index
    # @param add_key [Symbol] name of the key that add 1 to the index
    # @param max [Integer] maximum value of the index
    # @param min [Integer] minmum value of the index
    # @return [Boolean] if the index has changed
    def index_changed(varname, sub_key, add_key, max, min = 0)
      index = instance_variable_get(varname) - min
      mod = max - min + 1
      return false if mod <= 0 # Invalid value fix
      if Input.repeat?(sub_key)
        instance_variable_set(varname, (index - 1) % mod + min)
      elsif Input.repeat?(add_key)
        instance_variable_set(varname, (index + 1) % mod + min)
      end
      return instance_variable_get(varname) != (index + min)
    end

    # Perform an index change test and update the index (borned)
    # @param varname [Symbol] name of the instance variable that plays the index
    # @param sub_key [Symbol] name of the key that substract 1 to the index
    # @param add_key [Symbol] name of the key that add 1 to the index
    # @param max [Integer] maximum value of the index
    # @param min [Integer] minmum value of the index
    # @return [Boolean] if the index has changed
    def index_changed!(varname, sub_key, add_key, max, min = 0)
      index = instance_variable_get(varname) - min
      mod = max - min + 1
      if Input.repeat?(sub_key) && index > 0
        instance_variable_set(varname, (index - 1) + min)
      elsif Input.repeat?(add_key) && index < mod && index != max
        instance_variable_set(varname, index + 1 + min)
      end
      return instance_variable_get(varname) != (index + min)
    end

    # Update the mouse CTRL button (button hub)
    # @param buttons [Array<UI::DexCTRLButton>] buttons to update
    # @param actions [Array<Symbol>] method to call if the button is clicked & released
    # @param only_test_return [Boolean] if we only test the return button
    # @param return_index [Integer] index of the return button
    def update_mouse_ctrl_buttons(buttons, actions, only_test_return = false, return_index = 3)
      if Mouse.trigger?(:left)
        buttons.each_with_index do |sp, i|
          next if only_test_return && i != return_index
          sp.set_press(sp.simple_mouse_in?)
        end
      elsif Mouse.released?(:left)
        buttons.each_with_index do |sp, i|
          next if only_test_return && i != return_index
          if sp.simple_mouse_in?
            send(actions[i])
            sp.set_press(false)
            break
          end
          sp.set_press(false)
        end
      end
    end

    # Return the message class used
    # @return [Class]
    def message_class
      Yuki::Message
    end

    # Process the fade out process (going through black)
    # @param type [Symbol] type of transition
    # @param parameters [Integer, Array] parameters of the transition
    def fade_out(type, parameters)
      case type
      when :transition
        Graphics.freeze
        Graphics.brightness = 255
      when :fade_bk
        (parameters - 1).downto(0) do |i|
          Graphics.brightness = i * 255 / parameters
          Graphics.update
        end
      end
    end

    # Process the fade in process
    # @param type [Symbol] type of transition
    # @param parameters [Integer, Array] parameters of the transition
    def fade_in(type, parameters)
      case type
      when :transition
        Graphics.brightness = 255
        Graphics.transition(*parameters)
      when :fade_bk
        1.upto(parameters) do |i|
          Graphics.brightness = i * 255 / parameters
          Graphics.update
        end
      end
    end

    # Define the transition info when the scene start
    # @param type [Symbol] type of transition
    # @param parameters [Integer, Array] parameters of the transition
    def define_main_begin_fade(type, parameters = nil)
      @mbf_type = type
      @mbf_param = parameters
    end

    # Define the transition info when the scene stops
    # @param type [Symbol] type of transition
    # @param parameters [Integer, Array] parameters of the transition
    def define_main_end_fade(type, parameters = nil)
      @mef_type = type
      @mef_param = parameters
    end

    # Define the transition info when we switch to the called scene
    # @param type [Symbol] type of transition
    # @param parameters [Integer, Array] parameters of the transition
    def define_call_scene_fade_out(type, parameters = nil)
      @cfo_type = type
      @cfo_param = parameters
    end

    # Define the transition info when we return from call_scene
    # @param type [Symbol] type of transition
    # @param parameters [Integer, Array] parameters of the transition
    def define_call_scene_fade_in(type, parameters = nil)
      @cfi_type = type
      @cfi_param = parameters
    end

    # Function performing some tests to prevent softlock from messages at certain points
    def message_soft_lock_prevent
      if $game_temp.message_window_showing
        log_error('Message were still showing!')
        $game_temp.message_window_showing = false
      end
    end

    # Return the text according to the param
    # @param to_translate [Array(Symbol, Integer, Integer), String] the text info in order to get the right text
    # @example :
    #   get_text([:text_get, 0, 25]) # will return 'Pikachu'
    #   get_text('test') # will return 'test'
    def get_text(to_translate)
      return send(*to_translate) if to_translate.is_a?(Array)
      return to_translate
    end

    # Create the viewport (oftern used)
    def create_viewport
      # Main viewport
      # @type [LiteRGSS::Viewport]
      @viewport = Viewport.create(:main, 10_000)
    end

    # Create the Scene Graphics (should be overloaded, called before Graphics.transition in main_begin)
    def create_graphics
      create_viewport
    end

    # Sort the sprites inside the main viewport
    def sort_sprites
      @viewport&.sort_z
    end

    # Play decision SE
    def play_decision_se
      $game_system&.se_play($data_system&.decision_se)
    end

    # Play cursor SE
    def play_cursor_se
      $game_system&.se_play($data_system&.cursor_se)
    end

    # Play buzzer SE
    def play_buzzer_se
      $game_system&.se_play($data_system&.buzzer_se)
    end

    # Play cancel SE
    def play_cancel_se
      $game_system&.se_play($data_system&.cancel_se)
    end
  end

  # Base Scene where you should not define update but dedicated update methods :
  # ```ruby
  #   class MyScene < BaseCleanUpdate
  #     # Called when input can be updated (put your input related code inside)
  #     # @return [Boolean] if the update can continue
  #     def update_inputs
  #       # ...
  #       return true
  #     end
  #
  #     # Called when mouse can be updated (put your mouse related code inside)
  #     # @param moved [Boolean] boolean telling if the mouse moved
  #     # @return [Boolean] if the update can continue
  #     def update_mouse(moved)
  #       return unless moved
  #       # ...
  #       return true
  #     end
  #
  #     # Called each frame after message update and eventual mouse/input update
  #     # @return [Boolean] if the update can continue
  #     def update_graphics
  #       # ...
  #       return true
  #     end
  #   end
  # ```
  # All the update methods are optionnal but you should define at least one otherwise your Scene
  # will be useless and softlock the game
  class BaseCleanUpdate < Base
    # Scene update process
    # @return [Boolean] if the scene should continue the update process or abort it (message/animation etc...)
    def update
      can_continue = true
      # Process message
      can_continue = false unless super
      # Update inputs
      can_continue = false if can_continue && respond_to?(:update_inputs) && update_inputs == false
      # Update mouse
      can_continue = false if can_continue && respond_to?(:update_mouse) && update_mouse(Mouse.moved) == false
      # Update the graphics at the end with the correct state
      return update_graphics && can_continue if respond_to?(:update_graphics)
      return can_continue
    end
  end
end
