# Interpreter of the event commands
class Interpreter_RMXP
  # Id of the event that started the Interpreter
  # @return [Integer]
  attr_reader :event_id
  # Initialize the Interpreter
  # @param depth [Integer] depth of the Interpreter
  # @param main [Boolean] if the interpreter is the main interpreter
  def initialize(depth = 0, main = false)
    @depth = depth
    @main = main
    if depth > 100
      print('The common event call exceeded the upper boundary.')
      exit
    end
    clear
  end

  # Clear the state of the interpreter
  def clear
    # Map ID where the Interpreter was started
    @map_id = 0
    # Event ID in the map that is currently running the Interpreter
    @event_id = 0
    # If the Interpreter is waiting for a message
    @message_waiting = false
    # If the Interpreter is waiting for events to complete their mouve_rotue
    @move_route_waiting = false
    # If the Interpreter is waiting for a specific event to complete its moves
    @move_route_waiting_id = nil
    # ID of the variable where the Interpreter should put the Input key value
    @button_input_variable_id = 0
    # Number of frame the Interpreter has to wait until next execution
    @wait_count = 0
    # Sub Interpreters
    @child_interpreter = nil
    # Branches (condition, choices etc...)
    @branch = {}
  end

  # Launch a common event in a child interpreter
  # @param id [Integer] id of the common event
  def launch_common_event(id)
    common_event = $data_common_events[id]
    if common_event
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
  end

  # Setup the interpreter with a list of Commands
  # @param list [Array<RPG::Command>] list of commands
  # @param event_id [Integer] id of the event that launch the interpreter
  # @param block [Proc] the ruby commands to execute using a fiber (list is ignored if this variable is set)
  def setup(list, event_id, block = nil)
    clear
    @map_id = $game_map.map_id
    @event_id = event_id
    @list = block ? :fiber : list
    @index = 0
    @branch.clear
    create_fiber(block) if block
  end

  # Tells if the interpreter is running or not
  # @return [Boolean]
  def running?
    return !@list.nil?
  end

  # Setup the interpreter with an event (Game_Event / Game_CommonEvent) that can run
  def setup_starting_event
    # Refresh the event page when switch/variable was changed
    $game_map.refresh if $game_map.need_refresh
    # Start common event if required
    if $game_temp.common_event_id > 0
      setup($data_common_events[$game_temp.common_event_id].list, 0)
      $game_temp.common_event_id = 0
      return
    end
    # Try to start an event
    $game_map.events.each_value do |event|
      next unless event.starting
      if event.trigger < 3
        event.clear_starting
        event.lock
      end
      return setup(event.list, event.id)
    end
    # Try to start a common event
    $data_common_events.each do |common_event|
      next unless common_event&.trigger == 1 && $game_switches[common_event.switch_id]
      return setup(common_event.list, 0)
    end
  end

  # Update the interpreter
  def update
    @loop_count = 0
    loop do
      update_loop_count
      # We set the current event_id to 0 if the map has changed
      # (to prevent messing with event that as the same id in other map)
      @event_id = 0 if $game_map.map_id != @map_id
      # If a child interpreter is running
      unless @child_interpreter.nil?
        # We update it
        @child_interpreter.update
        # And clear it if it's not running anymore
        @child_interpreter = nil unless @child_interpreter.running?
        # We also break the loop if it's still running
        break unless @child_interpreter.nil?
      end
      # If we're waiting for the message to process
      break if @message_waiting
      # If we used a Wait events command
      break if waiting_event?
      # Process input if asked (need to return)
      break input_button if @button_input_variable_id > 0
      # Return if we're waiting
      break @wait_count -= 1 if @wait_count > 0
      # Quit if we're forcing a battle action
      break unless $game_temp.forcing_battler.nil?
      # If we're calling a scene we immediately quit
      break if calling_scene?
      # If the event has terminated we try to call another event
      if @list.nil?
        setup_starting_event if @main
        break if @list.nil?
      end
      # Return if the command returned false
      break if execute_command == false
      # Process next command
      @index += 1
    end
  end

  # Constant that holds the LiteRGSS input key to RGSS input Key
  LiteRGSS2RGSS_Input = {
    A: 13, B: 12, X: 14, Y: 15,
    L: 17, R: 18,
    UP: 8, DOWN: 2, LEFT: 4, RIGHT: 6,
    L2: 16, R2: 25, L3: 23, R3: 29,
    START: 22, SELECT: 21
  }
  # Constant that holds the RGSS input key to LiteRGSS input key
  RGSS2LiteRGSS_Input = LiteRGSS2RGSS_Input.invert
  RGSS2LiteRGSS_Input[11] = :A
  RGSS2LiteRGSS_Input.default = :HOME
  # Check if a button is triggered and store its id in a variable
  def input_button
    n = 0
    LiteRGSS2RGSS_Input.each do |key, i|
      n = i if Input.trigger?(key)
    end
    if n > 0
      $game_variables[@button_input_variable_id] = n
      $game_map.need_refresh = true
      @button_input_variable_id = 0
    end
  end

  # Setup choices in order to start a choice process
  def setup_choices(parameters)
    $game_temp.choice_max = parameters[0].size
    $game_temp.choices = parameters[0].clone.each { |s| s.force_encoding(Encoding::UTF_8) }
    $game_temp.choice_cancel_type = parameters[1]
    current_indent = @list[@index].indent
    $game_temp.choice_proc = proc { |n| @branch[current_indent] = n }
  end

  # Execute a block on a specific actor (parameter > 0) or every actors in the Party
  # @param parameter [Integer] whole party or id of an actor in the database
  def iterate_actor(parameter)
    if parameter == 0
      $game_party.actors.each { |actor| yield actor }
    else
      actor = $game_actors[parameter]
      yield actor if actor
    end
  end

  # Execute a block on a specific enemy (parameter >= 0) or every enemies in the troop
  # @param parameter [Integer] whole troop or index of an enemy in the troop
  def iterate_enemy(parameter)
    if parameter == -1
      $game_troop.enemies.each { |enemy| yield enemy }
    else
      enemy = $game_troop.enemies[parameter]
      yield enemy if enemy
    end
  end

  # Execute a block on a every enemies (parameter1 == 0) or every actors (parameter2 == -1) or a specific actor in the party
  # @param parameter1 [Integer] if 0, execute a block on every enemies
  # @param parameter2 [Integer] whole party or index of an actor in the party
  def iterate_battler(parameter1, parameter2)
    if parameter1 == 0
      iterate_enemy(parameter2) { |enemy| yield enemy }
    elsif parameter2 == -1
      $game_party.actors.each { |actor| yield actor }
    else
      actor = $game_party.actors[parameter2]
      yield actor if actor
    end
  end

  private

  # Test a scene is being called
  # @return [Boolean]
  def calling_scene?
    $game_temp.battle_calling || $game_temp.shop_calling ||
      $game_temp.name_calling || $game_temp.menu_calling ||
      $game_temp.save_calling || $game_temp.gameover
  end

  # Test if the Interpreter is currently waiting for an event
  # @return [Boolean]
  # @note This function automatically update the states it use if it returns false
  def waiting_event?
    return false unless @move_route_waiting
    # If we're waiting for a specific event
    if @move_route_waiting_id
      return true if @move_route_waiting_id == 0 && $game_player.move_route_forcing
      wanted_event = $game_map.events[@move_route_waiting_id]
      return true if wanted_event&.move_route_forcing || wanted_event&.path
      @move_route_waiting = false
      @move_route_waiting_id = nil
      return false
    end
    # Otherwise we're waiting for all event
    return true if $game_player.move_route_forcing
    return true if $game_map.events.any? { |_, event| event.move_route_forcing }
    @move_route_waiting = false
    return false
  end

  # Prevent the event from freezing the game if they process more than 100 commands
  def update_loop_count
    @loop_count += 1
    if @loop_count > 100
      log_debug("Event #{@event_id} executed 100 commands without giving the control back")
      Graphics.update
      @loop_count = 0
    end
  end

  # Create the Interpreter Fiber
  # @param block [Proc] the ruby commands to execute using a fiber 
  def create_fiber(block)
    raise 'Another fiber is running!' if @fiber
    @fiber = Fiber.new do
      instance_exec(&block)
    ensure # Release the fiber & list whatever happens in the fiber
      @fiber = @list = nil
    end
  end
end
