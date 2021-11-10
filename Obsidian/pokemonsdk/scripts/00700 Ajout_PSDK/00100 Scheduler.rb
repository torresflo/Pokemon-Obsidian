# Module that allows you to schedule some tasks and run them at the right time
#
# The Scheduler has a @tasks Hash that is organized the following way:
#   @tasks[reason][class] = [tasks]
#   reason is one of the following reasons :
#     on_update: during Graphics.update
#     on_scene_switch: before going outside of the #main function of the scene (if called)
#     on_dispose: during the dispose process
#     on_init: at the begining of #main before Graphics.transition
#     on_warp_start: at the begining of player warp process (first action)
#     on_warp_process: after the player has been teleported but before the states has changed
#     on_warp_end: before the transition starts
#     on_hour_update: When the current hour change (ex: refresh groups)
#     on_getting_tileset_name: When the Map Engine search for the correct tileset name
#     on_transition: When Graphics.transition is called
#   class is a Class Object related to the scene where the Scheduler starts
#
# The Sheduler also has a @storage Hash that is used by the tasks to store informations
module Scheduler
  module_function

  # Initialize the Scheduler with no task and nothing in the storage
  def init
    @tasks = {
      on_update: {},
      on_scene_switch: {},
      on_dispose: {},
      on_init: {},
      on_warp_start: {},
      on_warp_process: {},
      on_warp_end: {},
      on_hour_update: {},
      on_getting_tileset_name: {},
      on_transition: {}
    }
    @storage = {}
  end

  init

  # Start tasks that are related to a specific reason
  # @param reason [Symbol] reason explained at the top of the page
  # @param klass [Class, :any] the class of the scene
  def start(reason, klass = $scene.class)
    task_hash = @tasks[reason]
    return unless task_hash # Bad reason

    if klass != :any
      start(reason, :any)
      klass = klass.to_s
    end
    task_array = task_hash[klass]
    return unless task_array # No task for this class

    task_array.each(&:start)
  end

  # Remove a task
  # @param reason [Symbol] the reason
  # @param klass [Class, :any] the class of the scene
  # @param name [String] the name that describe the task
  # @param priority [Integer] its priority
  def __remove_task(reason, klass, name, priority)
    task_array = @tasks.dig(reason, klass.is_a?(Symbol) ? klass : klass.to_s)
    return unless task_array

    priority = -priority
    task_array.delete_if { |obj| obj.priority == priority && obj.name == name }
  end

  # add a task (and sort them by priority)
  # @param reason [Symbol] the reason
  # @param klass [Class, :any] the class of the scene
  # @param task [ProcTask, MessageTask] the task to run
  def __add_task(reason, klass, task)
    task_hash = @tasks[reason]
    return unless task_hash # Bad reason

    klass = klass.to_s unless klass.is_a?(Symbol)
    task_array = task_hash[klass] || []
    task_hash[klass] = task_array
    task_array << task
    task_array.sort! { |a, b| a.priority <=> b.priority }
  end

  # Description of a Task that execute a Proc
  class ProcTask
    # Priority of the task
    # @return [Integer]
    attr_reader :priority
    # Name that describe the task
    # @return [String]
    attr_reader :name
    # Initialize a ProcTask with its name, priority and the Proc it executes
    # @param name [String] name that describe the task
    # @param priority [Integer] the priority of the task
    # @param proc_object [Proc] the proc (with no param) of the task
    def initialize(name, priority, proc_object)
      @name = name
      @priority = -priority
      @proc = proc_object
    end

    # Invoke the #call method of the proc
    def start
      @proc.call
    end
  end

  # Add a proc task to the Scheduler
  # @param reason [Symbol] the reason
  # @param klass [Class] the class of the scene
  # @param name [String] the name that describe the task
  # @param priority [Integer] the priority of the task
  # @param proc_object [Proc] the Proc object of the task (kept for compatibility should not be defined)
  # @param block [Proc] the Proc object of the task
  def add_proc(reason, klass, name, priority, proc_object = nil, &block)
    proc_object = block if block
    __add_task(reason, klass, ProcTask.new(name, priority, proc_object))
  end

  # Describe a Task that send a message to a specific object
  class MessageTask
    # Priority of the task
    # @return [Integer]
    attr_reader :priority
    # Name that describe the task
    # @return [String]
    attr_reader :name
    # Initialize a MessageTask with its name, priority, the object and the message to send
    # @param name [String] name that describe the task
    # @param priority [Integer] the priority of the task
    # @param object [Object] the object that receive the message
    # @param message [Array<Symbol, *args>] the message to send
    def initialize(name, priority, object, message)
      @name = name
      @priority = -priority
      @object = object
      @message = message
    end

    # Send the message to the object
    def start
      @object.send(*@message)
    end
  end
  # Add a message task to the Scheduler
  # @param reason [Symbol] the reason
  # @param klass [Class, :any] the class of the scene
  # @param name [String] name that describe the task
  # @param priority [Integer] the priority of the task
  # @param object [Object] the object that receive the message
  # @param message [Array<Symbol, *args>] the message to send
  def add_message(reason, klass, name, priority, object, *message)
    __add_task(reason, klass, MessageTask.new(name, priority, object, message))
  end

  # Return the object of the Boot Scene (usually Scene_Title)
  # @return [Object]
  def get_boot_scene
    if PARGV[:tags]
      ScriptLoader.load_tool('Editors/SystemTags')
      return Editors::SystemTags.new
    end
    return Yuki::WorldMapEditor if PARGV[:worldmap]
    return Yuki::AnimationEditor if PARGV[:"animation-editor"]

    test = PARGV[:test].to_s # ARGV.grep(/--test=./).first.to_s.gsub("--test=","")
    return Scene_Title.new if test.empty?

    test = "tests/#{test}.rb"
    return Tester.new(test) if File.exist?(test)

    return Scene_Title.new
  end
end

Hooks.register(Graphics, :transition, 'PSDK Graphics.transition') { Scheduler.start(:on_transition) }
Hooks.register(Graphics, :update, 'PSDK Graphics.update') { Scheduler.start(:on_update) }
