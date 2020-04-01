class Interpreter_RMXP
  # Command that starts a message display, if followed by a choice/input num command,
  # displays the choice/input num in the meantime
  def command_101
    return false if $game_temp.message_text
    # $game_player.look_to(@event_id) unless $game_switches[::Yuki::Sw::MSG_Noturn]
    @message_waiting = true
    $game_temp.message_proc = proc { @message_waiting = false }
    $game_temp.message_text = @list[@index].parameters[0].force_encoding(Encoding::UTF_8) + "\n"
    loop do
      if @list[@index.next].code == 401 # Next Message Line
        $game_temp.message_text += @list[@index.next].parameters[0].force_encoding(Encoding::UTF_8) + "\n"
      else
        if @list[@index.next].code == 102 # Choice command right after
          @index += 1
          # $game_temp.choice_start = line_count # There was a line_count counting line for RMXP
          setup_choices(@list[@index].parameters)
        elsif @list[@index.next].code == 103 # Input Number call
          @index += 1
          $game_temp.num_input_start = -99 # line_count
          $game_temp.num_input_variable_id = @list[@index].parameters[0]
          $game_temp.num_input_digits_max = @list[@index].parameters[1]
        end
        return true
      end
      @index += 1
    end
    $game_temp.message_text.gsub!(/\n([^ ])|\n /, ' \1') if $game_switches[Yuki::Sw::MSG_Recalibrate]
    return true
  end

  # Command that display a choice if possible (no message)
  def command_102
    return false if $game_temp.message_text
    @message_waiting = true
    $game_temp.message_proc = proc { @message_waiting = false }
    $game_temp.message_text = nil.to_s
    $game_temp.choice_start = 0
    setup_choices(@parameters)
    return true
  end

  # Command that execute the choice branch depending on the choice result
  def command_402
    if @branch[@list[@index].indent] == @parameters[0]
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end

  # Command that execute the cancel branch if the result was 4 (max option in RMXP)
  def command_403
    if @branch[@list[@index].indent] == 4
      @branch.delete(@list[@index].indent)
      return true
    end
    return command_skip
  end

  # Display an input number if possible (no message)
  def command_103
    return false if $game_temp.message_text
    @message_waiting = true
    $game_temp.message_proc = proc { @message_waiting = false }
    $game_temp.message_text = nil.to_s
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = @parameters[0]
    $game_temp.num_input_digits_max = @parameters[1]
    return true
  end

  # Change the message settings (position / frame type)
  def command_104
    return false if $game_temp.message_window_showing
    $game_system.message_position = @parameters[0]
    $game_system.message_frame = @parameters[1]
    return true
  end

  # Start a store button id to variable process
  def command_105
    @button_input_variable_id = @parameters[0]
    @index += 1
    return false
  end

  # Wait 2 times the number of frame requested
  def command_106
    @wait_count = @parameters[0] * 2
    return true
  end

  # Conditionnal command
  def command_111
    result = false
    case @parameters[0]
    when 0  # Switch test
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # Variable comparison
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
      when 0  # Equal
        result = (value1 == value2)
      when 1  # Greater or Equal
        result = (value1 >= value2)
      when 2  # Lesser or Equal
        result = (value1 <= value2)
      when 3  # Greater
        result = (value1 > value2)
      when 4  # Lesser
        result = (value1 < value2)
      when 5  # Different
        result = (value1 != value2)
      end
    when 2  # Local Switch Test
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key] == true)
        else
          result = ($game_self_switches[key] != true)
        end
      end
    when 3  # Timer test
      if $game_system.timer_working
        sec = $game_system.timer / 60 # Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4 # Actor test
      actor = PFM::BattleInterface.get_actor(@parameters[1]) # $game_actors[@parameters[1]]
      if actor
        case @parameters[2]
        when 0 # Is in Party => Alive
          result = !actor.dead? # ($game_party.actors.include?(actor))
        when 1  # Name => Given Name
          result = (actor.given_name == @parameters[3])
        when 2  # Skill learnt
          result = actor.skill_learnt?(@parameters[3], true) # (actor.skill_learn?(@parameters[3]))
        when 3 # Weapon => Item holding
          result = (actor.item_holding == @parameters[3]) # (actor.weapon_id == @parameters[3])
        when 4 # Armor => Ability
          result = (actor.current_ability == @parameters[3])
=begin
          (actor.armor1_id == @parameters[3] or
                    actor.armor2_id == @parameters[3] or
                    actor.armor3_id == @parameters[3])
=end
        when 5 # Status
          result = (actor.status == @parameters[3]) # (actor.state?(@parameters[3]))
        end
      end
    when 5 # Enemy Test
      enemy = PFM::BattleInterface.get_enemy(@parameters[1]) # $game_troop.enemies[@parameters[1]]
      if enemy
        case @parameters[2]
        when 0 # Exists => alive
          result = !enemy.dead? # (enemy.exist?)
        when 1 # State
          result = (enemy.status == @parameters[3]) # (enemy.state?(@parameters[3]))
        end
      end
    when 6 # Character direction test
      if (character = get_character(@parameters[1]))
        result = (character.direction == @parameters[2])
      end
    when 7 # Money test
      if @parameters[2] == 0
        result = ($pokemon_party.money >= @parameters[1]) # ($game_party.gold >= @parameters[1])
      else
        result = ($pokemon_party.money <= @parameters[1]) # ($game_party.gold <= @parameters[1])
      end
    when 8 # Item is owned
      result = $bag.contain_item?(@parameters[1]) # ($game_party.item_number(@parameters[1]) > 0)
    when 9 # Weapon owned
      result = false # ($game_party.weapon_number(@parameters[1]) > 0)
    when 10 # Armor owned
      result = false # ($game_party.armor_number(@parameters[1]) > 0)
    when 11 # Key pressed
      result = Input.press?(RGSS2LiteRGSS_Input[@parameters[1]])
    when 12 # Script
      result = eval_condition_script(@parameters[1])
    end
    # Set current branch result
    @branch[@list[@index].indent] = result
    # If true, remove current branch and execute the next command
    if @branch[@list[@index].indent] == true
      @branch.delete(@list[@index].indent)
      return true
    end
    # If false, skip next command until false command are found
    return command_skip
  end

  # Function that execute a script for the conditions
  # @param script [String]
  def eval_condition_script(script)
    last_eval = Yuki::EXC.get_eval_script
    script = script.force_encoding('UTF-8')
    result = false
    Yuki::EXC.set_eval_script(script)
    Yuki::ErrorHandler.critical_section("Eval from condition (EVENT_ID = #{@event_id.to_i}).\nThe condition will not be valid.\nScript:\n#{script}") do
      result = eval(script) ? true : false
    end
    Yuki::EXC.set_eval_script(last_eval)
    return result
  end

  # Command testing the false section of condition
  def command_411
    if @branch[@list[@index].indent] == false
      @branch.delete(@list[@index].indent)
      return true
    end
    # Skip commands until we find the normal commands (after conditition)
    return command_skip
  end

  # Loop command
  def command_112
    return true
  end

  # Repeat loop command (try to go back to the loop command of the same indent)
  def command_413
    indent = @list[@index].indent
    loop do
      @index -= 1
      return true if @list[@index].indent == indent
    end
  end

  # Break loop command (try to go to the end of the loop)
  def command_113
    indent = @list[@index].indent
    temp_index = @index
    loop do
      temp_index += 1
      return true if temp_index >= @list.size - 1
      # If we find a repeat loop of the a parent loop, we stop there and let the command execute
      if @list[temp_index].code == 413 && @list[temp_index].indent < indent
        @index = temp_index
        return true
      end
    end
  end

  # End the interpretation of the current event
  def command_115
    command_end
    return true
  end

  # erase this event
  def command_116
    $game_map.events[@event_id].erase if @event_id > 0
    @index += 1
    return false
  end

  # Call a common event
  def command_117
    if (common_event = $data_common_events[@parameters[0]])
      @child_interpreter = Interpreter.new(@depth + 1)
      @child_interpreter.setup(common_event.list, @event_id)
    end
    return true
  end

  # Label command
  def command_118
    return true
  end

  # jump to a label
  def command_119
    label_name = @parameters[0]
    temp_index = 0
    loop do
      return true if temp_index >= @list.size - 1
      if @list[temp_index].code == 118 && @list[temp_index].parameters[0] == label_name
        @index = temp_index
        return true
      end
      temp_index += 1
    end
  end
end
