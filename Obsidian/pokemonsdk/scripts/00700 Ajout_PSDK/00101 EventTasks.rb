module Scheduler
  # Module that aim to add task triggered by events actions
  #
  # List of the event actions :
  #   - begin_step
  #   - begin_jump
  #   - begin_slide
  #   - end_step
  #   - end_jump
  #   - end_slide
  #
  # Events can be specified with the following criteria
  #   - map_id / :any : ID of the map where the task can trigger
  #   - event_id / :any : ID of the event that trigger the task (-1 = player, -2 its first follower, -3 its second, ...)
  #
  # Parameter sent to the task :
  #   - event : Game_Character object that triggered the task
  #   - event_id : ID of the event that triggered the task (for :any tasks)
  #   - map_id : ID of the map where the task was triggered (for :any tasks)
  #
  # Important note : The system will detect the original id & map of the events (that's why the event object is sent & its id)
  module EventTasks
    # Hash of tasks : type -> map_id/:any -> event_id/:any
    @tasks = {}

    module_function

    # Add a new task
    # @param task_type [Symbol] one of the specific tasks
    # @param description [String] description allowing to retrieve the task
    # @param event_id [Integer, :any] id of the event that triggers the task
    # @param map_id [Integer, :any] id of the map where the task triggers
    # @param task [Proc] task executed
    def on(task_type, description, event_id = :any, map_id = :any, &task)
      tasks = (@tasks[task_type] ||= {})
      tasks = (tasks[map_id] ||= {})
      tasks = (tasks[event_id] ||= {})
      tasks[description] = task
    end

    # Trigger a specific task
    # @param task_type [Symbol] one of the specific tasks
    # @param event [Game_Character] event triggering the task
    def trigger(task_type, event)
      return unless (tasks = @tasks[task_type])
      event_id = resolve_id(event)
      map_id = resolve_map_id(event)
      # Tasks of the current map
      if (map_tasks = tasks[map_id])
        if (event_tasks = map_tasks[event_id])
          event_tasks.each_value { |task| task.call(event, event_id, map_id) }
        end
        if (event_tasks = map_tasks[:any])
          event_tasks.each_value { |task| task.call(event, event_id, map_id) }
        end
      end
      # Tasks of all the map
      if (map_tasks = tasks[:any])
        if (event_tasks = map_tasks[event_id])
          event_tasks.each_value { |task| task.call(event, event_id, map_id) }
        end
        if (event_tasks = map_tasks[:any])
          event_tasks.each_value { |task| task.call(event, event_id, map_id) }
        end
      end
    end

    # Resolve the id of the event
    # @param event [Game_Character]
    # @return [Integer]
    def resolve_id(event)
      if event.is_a?(Game_Event)
        return event.original_id
      elsif event == $game_player
        return -1
      end
      # Follower resolution
      id = -1
      follower = $game_player
      while (follower = follower.follower)
        id -= 1
        return id if follower == event
      end
      return 0
    end

    # Resolve the id of the event
    # @param event [Game_Character]
    # @return [Integer]
    def resolve_map_id(event)
      return event.original_map if event.is_a?(Game_Event)
      return $game_map.map_id
    end

    # Remove a task
    # @param task_type [Symbol] one of the specific tasks
    # @param description [String] description allowing to retrieve the task
    # @param event_id [Integer, :any] id of the event that triggers the task
    # @param map_id [Integer, :any] id of the map where the task triggers
    def delete(task_type, description, event_id, map_id)
      return unless (tasks = @tasks[task_type])
      return unless (tasks = tasks[map_id])
      return unless (tasks = tasks[event_id])
      tasks.delete(description)
    end
  end
end

Scheduler::EventTasks.on(:end_jump, 'Dust after jumping') do |event|
  next if event.particles_disabled

  particle = Game_Character::SurfTag.include?(event.system_tag) ? :water_dust : :dust
  Yuki::Particles.add_particle(event, particle)
end
Scheduler::EventTasks.on(:end_step, 'Repel count', -1) { PFM.game_state.repel_update }
Scheduler::EventTasks.on(:end_step, 'Daycare', -1) { $daycare.update }
Scheduler::EventTasks.on(:end_step, 'Loyalty check', -1) { PFM.game_state.loyalty_update }
Scheduler::EventTasks.on(:end_step, 'PoisonUpdate', -1) { PFM.game_state.poison_update }
Scheduler::EventTasks.on(:end_step, 'Hatch check', -1) { PFM.game_state.hatch_check_update }
Scheduler::EventTasks.on(:begin_step, 'BattleStarting', -1) { PFM.game_state.battle_starting_update }
