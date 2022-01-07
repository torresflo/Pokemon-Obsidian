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
    ::PFM::Text.define_const(self)
    include Input
    # The viewport in which the scene is shown
    # @return [Viewport, nil]
    attr_reader :viewport
    # The scene that called this scene (usefull when this scene needs to return to the last scene)
    # @return [Base]
    attr_reader :__last_scene
    # The process that is called when the call_scene method returns
    # @return [Proc, nil]
    attr_accessor :__result_process
    # If the current scene is still running
    # @return [Boolean]
    attr_accessor :running

    # rubocop: disable Style/OptionalBooleanParameter
    # Create a new GamePlay scene
    # @param no_message [Boolean] if the scene is created wihout the message management
    # @param message_z [Integer] the z superiority of the message
    # @param message_viewport_args [Array] if empty : [:main, message_z] will be used.
    def initialize(no_message = false, message_z = 20_000, *message_viewport_args)
      # List of object to dispose in #dispose
      @object_to_dispose = []
      # Force the message window of the map to be closed
      Scene_Map.from($scene).window_message_close(true) if $scene.instance_of?(Scene_Map)
      message_initialize(no_message, message_z, message_viewport_args)
      # Store the current scene
      @__last_scene = $scene
      message_soft_lock_prevent
    end
    # rubocop: enable Style/OptionalBooleanParameter

    # Scene update process
    # @return [Boolean] if the scene should continue the update process or abort it (message/animation etc...)
    def update
      message_update
      return false if message_processing?

      return true
    end

    # Dispose the scene graphics.
    # @note @viewport and @message_window will be disposed.
    def dispose
      message_soft_lock_prevent
      Scheduler.start(:on_dispose, self.class)
      message_dispose
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
      yield if block_given? # Ensure we call the on_scene_switch in call_scene
      # Tell the interface is running
      @running = true
      # Main processing
      main_begin
      main_process
      main_end
      # Reset $scene unless it was already done
      $scene = @__last_scene if $scene == self
      Scheduler.start(:on_scene_switch, self.class)
    end

    # Change the viewport visibility of the scene
    # @param value [Boolean]
    def visible=(value)
      @viewport.visible = value if @viewport
      self.message_visible = value
    end

    # Tell if the scene is visible
    # @return [Boolean]
    def visible
      return @viewport.visible if @viewport
      return message_visible if @message_window

      return true
    end

    # Call an other scene
    # @param name [Class] the scene to call
    # @param args [Array] the parameter of the initialize method of the scene to call
    # @param fade_out_params [Array, nil] params to send to the fade_out function (when this scene hides to call the next scene)
    # @param fade_in_params [Array, nil] params to send to the fade_in function (when this scene comes back)
    # @return [Boolean] if this scene can still run
    def call_scene(name, *args, fade_out_params: nil, fade_in_params: nil, **kwarg, &result_process)
      fade_out(*(fade_out_params || [@cfo_type || DEFAULT_TRANSITION, @cfo_param || DEFAULT_TRANSITION_PARAMETER]))
      # Make the current scene invisible
      self.visible = false
      result_process ||= @__result_process
      @__result_process = nil
      # @type [GamePlay::Base]
      scene = name.new(*args, **kwarg)
      scene.main { Scheduler.start(:on_scene_switch, self.class) }
      # Call the result process if any
      result_process&.call(scene)
      # If the scene has changed we stop this one
      return @running = false if $scene != self || !@running

      self.visible = true
      fade_in(*(fade_in_params || [@cfi_type || DEFAULT_TRANSITION, @cfi_param || DEFAULT_TRANSITION_PARAMETER]))
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

    # Take a snapshot of the scene
    # @note You have to dispose the bitmap you got from this function
    # @return [Texture]
    def snap_to_bitmap
      @viewport&.snap_to_bitmap || Texture.new(16, 16)
    end

    # Find a parent scene
    # @param klass [Class<GamePlay::Base>] criteria passed to .is_a?()
    # @param fallback [GamePlay::Base] result if the scene was not found
    def find_parent(klass, fallback = self)
      scene = self
      while scene.is_a?(Base)
        scene = scene.__last_scene
        break if scene == self
        next unless scene.is_a?(klass)

        return scene
      end
      return false
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
      fade_out(@mef_type || DEFAULT_TRANSITION, @mef_param || DEFAULT_TRANSITION_PARAMETER) if visible
      dispose
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
          next unless actions[i]
          sp.set_press(sp.simple_mouse_in?)
        end
      elsif Mouse.released?(:left)
        buttons.each_with_index do |sp, i|
          next if only_test_return && i != return_index
          next unless actions[i]
          if sp.simple_mouse_in?
            send(actions[i])
            sp.set_press(false)
            break
          end
          sp.set_press(false)
        end
      end
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
      Scheduler.start(:on_transition, self.class) if type != :transition # Done in Graphics.transition
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
      # @type [Viewport]
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
    AIU_KEY2METHOD = {
      A: :action_a, B: :action_b, X: :action_x, Y: :action_y, L: :action_l, R: :action_r,
      L2: :action_l2, R2: :action_r2, L3: :action_l3, R3: :action_r3,
      START: :action_start, SELECT: :action_select, HOME: :action_home
    }
    # Scene update process
    # @return [Boolean] if the scene should continue the update process or abort it (message/animation etc...)
    def update
      can_continue = true
      # Process message
      can_continue = false unless super
      # Update inputs
      can_continue = false if can_continue && respond_to?(:update_inputs, true) && update_inputs == false
      # Update mouse
      can_continue = false if can_continue && respond_to?(:update_mouse, true) && update_mouse(Mouse.moved) == false
      # Update the graphics at the end with the correct state
      return update_graphics && can_continue if respond_to?(:update_graphics, true)

      return can_continue
    end

    # Automatically detect input update and call the corresponding action method
    # @param key2method [Hash] Hash associating Input Keys to action method name
    # @return [Boolean] if the update_inputs should continue
    # @example Use the generic aiu
    #   def update_inputs
    #     return false unless automatic_input_update
    #     # Do something else
    #     return true
    #   end
    # @example Use aiu with specific functions
    #   return false unless automatic_input_update(A: :action_a2, B: :action_b2)
    def automatic_input_update(key2method = AIU_KEY2METHOD)
      key2method.each do |key, method_name|
        if respond_to?(method_name, true) && Input.trigger?(key)
          send(method_name)
          return false
        end
      end
      return true
    end

    # Base that takes frame balancing in account
    class FrameBalanced < self
      include Graphics::FPSBalancer::Marker

      # Update with frame balancing
      def update
        super unless Graphics::FPSBalancer.global.skipping?
      end
    end
  end
end
