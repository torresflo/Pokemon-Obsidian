module Util
  module EventConvert
    class CommandConvert
      def initialize(list, *path)
        if list.is_a?(Integer)
          @list = load_path(list, *path)
        else
          @list = list
        end
        @labels = {}
        @choices = []
        @indent = 0
        @split_next = false
        convert
      end

      private

      def load_path(map_id, event_id, page)
        map = load_data(format('Data/Map%03d.rxdata', map_id))
        event = map.events[event_id]
        page = event.pages[page]
        return page.list
      end

      def convert
        @index = 0
        @master_list = @current_list = make_list
        perform_list_analysis
        write_ruby(STDOUT)
      end

      def make_list(previous = nil, parent = nil, label = nil)
        current_list = {
          begin: @index,
          end: nil,
          label: label,
          parent: parent,
          child: nil,
          previous: previous,
          internal_labels: [],
          next: nil
        }
        parent[:child] = current_list if parent && !parent[:child]
        previous[:next] = current_list if previous
        current_list
      end

      def perform_list_analysis
        while cmd = @list[@index]
          case cmd.code
          when 112 # Loop
            @current_list[:end] = @index - 1
            @current_list = make_list(nil, @current_list)
          when 413 # Redo loop <=> End of the loop
            raise "Unexpected 413 at index #{@index - 1}" unless @current_list[:parent]
            @current_list[:end] = @index - 1
            @current_list = make_list(@current_list[:parent], @current_list[:parent][:parent])
          when 118 # Label def
            @current_list[:end] = @index - 1
            @current_list = make_list(@current_list, @current_list[:parent], label = cmd.parameters.first)
            @labels[label] ||= @index
            taint_parent_loop_with_label(@current_list, label)
          when 402, 403, 111, 411, 601, 602, 603 # Choice option, cancel, condition, else, battle results
            @current_list[:end] = @index - 1
            @current_list = make_list(@current_list, @current_list[:parent])
            @split_next = true
          when 404, 412, 604 # End of choice / End of condition / End of battle conditions
            #@current_list[:end] = @index - 1
            #@current_list = make_list(@current_list, @current_list[:parent])
            @split_next = true
          else
            if @split_next
              @split_next = false
              @current_list[:end] = @index - 1
              @current_list = make_list(@current_list, @current_list[:parent])
            end
          end
          @index += 1
        end
        @current_list[:end] = @index - 1
      end

      # Function that tries to tell the internal labels of each parent of the current node
      def taint_parent_loop_with_label(parent, label)
        begin
          while parent[:previous]
            parent = parent[:previous]
          end
          parent[:internal_labels] << label
        end while(parent = parent[:parent])
      end

      def write_ruby(io)
        @labels.each do |label, line|
          io.puts("g#{line} = false # Flag to jump to #{label}")
        end
        write_ruby_loop(io, @master_list, "Safety loop")
      end

      def write_ruby_loop(io, node, comment = nil)
        io.puts(comment ? "#{' ' * @indent}loop do # #{comment}" : "#{' ' * @indent}loop do")
        @indent += 2
        current_list = node
        write_non_internal_labels(io, node)
        while current_list
          write_internal_list(io, node, current_list)
          # Manage other loop
          if(child = current_list[:child])
            write_ruby_loop(io, child)
          end
          current_list = current_list[:next]
        end
        io.puts("#{' ' * @indent}break") if node == @master_list
        write_end(io)
      end

      def write_internal_list(io, node, current_list)
        unless is_skipable_list(current_list)
          wrote_unless = write_unless(io, node, current_list)
          index = current_list[:begin]
          while index <= current_list[:end]
            index = write_ruby_translation(io, index, current_list)
            index += 1
          end
          write_end(io) if wrote_unless
        end
      end

      def write_non_internal_labels(io, node)
        non_internal_label = @labels.keys - node[:internal_labels]
        return if non_internal_label.empty?
        non_internal_label = non_internal_label.collect { |label| "g#{@labels[label]}" }
        io.puts("#{' ' * @indent}break if #{non_internal_label.join(' or ')}")
      end

      CONDITION_SKIP_UNLESS_LISTS = [402, 403, 111, 411]
      def write_unless(io, node, current_list)
        if CONDITION_SKIP_UNLESS_LISTS.include?(@list[current_list[:begin]].code)
          return false
        end
        skip_labels = node[:internal_labels] - [current_list[:label]]
        skip_labels = skip_labels.collect { |label| "g#{@labels[label]}" }
        if skip_labels.empty?
          return false
        else
          io.puts("#{' ' * @indent}unless #{skip_labels.join(' or ')}")
        end
        @indent += 2
        true
      end

      def write_end(io)
        @indent -= 2
        io.puts("#{' ' * @indent}end")
        @last_pic_number = nil
      end

      def write_ruby_translation(io, index, current_list)
        cmd = @list[index]
        param = cmd.parameters
        case cmd.code
        when 101
          index = translate_message_command(io, index)
        when 102
          translate_choice_command(io, cmd)
        when 103
          translate_input_number_command(io, index)
        when 104
          translate_window_setting_command(io, cmd)
        when 105
          translate_wait_input_command(io, cmd)
        when 106
          translate_wait_command(io, cmd)
        when 118 # label def
          io.puts("#{' ' * @indent}g#{@labels[param.first]} = false # Simulate label #{param.first}")
        when 119 # Goto label
          io.puts("#{' ' * @indent}next(g#{@labels[param.first].to_i} = true) # Goto label #{param.first}")
        when 112, 413 # Loop / Loop end
          # do nothing
        when 402, 403 # Choice
          write_event_choice(io, cmd, current_list)
        when 601, 602, 603 # Battle result check
          write_event_battle_result_conditions(io, cmd, current_list)
        when 111 # Conditions
          write_event_condition(io, cmd, current_list)
        when 411 # Else
          @last_pic_number = nil
          io.puts("#{' ' * (@indent - 2)}else")
        when 113 # Break loop
          io.puts("#{' ' * @indent}break # Leave loop")
        when 404, 412, 604 # End of condition / end of choice
          write_end(io)
          @choices.pop if cmd.code == 404 || cmd.code == 604
        when 115 # Stop current event execution
          io.puts("#{' ' * @indent}terminate_this_event")
        when 116 # Erase current event
          io.puts("#{' ' * @indent}$game_map.events[@event_id].erase if @event_id > 0")
        when 117 # Call common event
          io.puts("#{' ' * @indent}call_common_event(#{param.first})")
        when 121 # Multiple switch set
          translate_multiple_switch_set(io, param)
        when 122 # Variable set
          translate_variable_set(io, param)
        when 123 # Self switch set
          translate_self_switch_set(io, param)
        when 124 # Timer management
          translate_timer_command(io, param)
        when 125 # Earn gold
          translate_earn_gold_command(io, param)
        when 126 # Item gain command
          translate_item_gain_command(io, param)
        when 131 # Windowskin change command
          io.puts("#{' ' * @indent}$game_system.windowskin_name = '#{param[0]}'")
        when 132 # Battle BGM change
          io.puts("#{' ' * @indent}$game_system.battle_bgm = '#{param[0]}'")
        when 133 # Battle end ME change
          io.puts("#{' ' * @indent}$game_system.battle_end_me = '#{param[0]}'")
        when 134 # Disable save command
          io.puts("#{' ' * @indent}$game_system.save_disabled = #{param[0] == 0}")
        when 135 # Disable menu command
          io.puts("#{' ' * @indent}$game_system.menu_disabled = #{param[0] == 0}")
        when 136 # Disable encounter command
          translate_disable_encounter_command(io, param)
        when 201 # Warp command
          translate_warp_command(io, param)
        when 202 # Displace command
          translate_displace_command(io, param)
        when 203 # Map scroll command
          translate_map_scroll_command(io, param)
        when 204 # Map property change command
          translate_map_property_command(io, param)
        when 205 # Tone change command
          io.puts("#{' ' * @indent}$game_map.start_fog_tone_change(Tone.new#{param[0]}, #{param[1]} * 2)")
        when 206 # Fog change command
          io.puts("#{' ' * @indent}$game_map.start_fog_opacity_change(#{param[0]}, #{param[1]} * 2)")
        when 207 # Animation on character
          io.puts("#{' ' * @indent}show_animation(#{param[1]}, event: #{param[0]})")
        when 208 # Player transparency
          io.puts("#{' ' * @indent}$game_player.transparent = #{param[0] == 0}")
        when 210 # Wait movement
          io.puts("#{' ' * @indent}wait_movement_termination")
        when 221 # Prepare transition
          io.puts("#{' ' * @indent}prepare_transition")
        when 222 # Execute transition
          io.puts("#{' ' * @indent}execute_transition(#{param[0]})")
        when 223 # Screen tone change
          translate_screen_tone_change(io, param)
        when 224 # Flash screen
          io.puts("#{' ' * @indent}$game_screen.start_flash(Color.new#{param[0]}, #{param[1]} * 2)")
        when 225 # Shake screen
          io.puts("#{' ' * @indent}$game_screen.start_shake(#{param[0]}, #{param[1]}, #{param[2]} * 2)")
        when 231 # Display picture
          translate_display_picture(io, param)
        when 232 # Move picture
          translate_move_picture(io, param)
        when 233 # Rotate picture
          translate_rotate_picture(io, param)
        when 234 # Picture tone change
          translate_picture_tone_change(io, param)
        when 235 # Erase picture
          translate_erase_picture(io, param)
        when 236 # Weather command
          io.puts("#{' ' * @indent}$game_screen.weather(#{param[0]}, #{param[1]}, #{param[2]})")
        when 241 # BGM Play
          io.puts("#{' ' * @indent}$game_system.bgm_play('#{param[0]}')")
        when 242 # BGM Fade
          io.puts("#{' ' * @indent}$game_system.bgm_fade(#{param[0]})")
        when 245 # BGS Play
          io.puts("#{' ' * @indent}$game_system.bgs_play('#{param[0]}')")
        when 246 # BGS Fade
          io.puts("#{' ' * @indent}$game_system.bgs_fade(#{param[0]})")
        when 247 # BGM & BGS Memorize
          io.puts("#{' ' * @indent}$game_system.bgm_memorize")
          io.puts("#{' ' * @indent}$game_system.bgs_memorize")
        when 248 # BGM & BGS Restore
          io.puts("#{' ' * @indent}$game_system.bgm_restore")
          io.puts("#{' ' * @indent}$game_system.bgs_restore")
        when 249 # ME Play
          io.puts("#{' ' * @indent}$game_system.me_play('#{param[0]}')")
        when 250 # SE Play
          io.puts("#{' ' * @indent}$game_system.se_play('#{param[0]}')")
        when 251 # SE stop
          io.puts("#{' ' * @indent}Audio.se_stop")
        when 301 # Battle call command
          io.puts("#{' ' * @indent}battle_result = start_battle(id: #{param[0]}, can_escape: #{param[1]}, can_loose: #{param[2]})")
        when 302 # Call shop
          index = translate_shop_command(io, index)
        when 303 # Call name
          io.puts("#{' ' * @indent}enter_name(actor_id: #{param[0]}, max_char: #{param[1]})")
        when 320 # Name change command
          io.puts("#{' ' * @indent}actor = $game_actors[#{param[0]}]")
          io.puts("#{' ' * @indent}actor.name = '#{param[1]}' if actor")
        when 322 # Set graphics command
          io.puts("#{' ' * @indent}actor = $game_actors[#{param[0]}]")
          io.puts("#{' ' * @indent}actor.set_graphic('#{param[1]}', #{param[2]}, '#{param[3]}', #{param[4]}) if actor")
          io.puts("#{' ' * @indent}$game_player.refresh")
        when 340 # Battle end command
          io.puts("#{' ' * @indent}abort_battle")
        when 351 # Call menu
          io.puts("#{' ' * @indent}call_menu")
        when 352 # Call save
          io.puts("#{' ' * @indent}call_save")
        when 353 # Game Over
          io.puts("#{' ' * @indent}game_over")
        when 354 # Return to tile
          io.puts("#{' ' * @indent}return_to_title")
        when 355 # Script command
          index = translate_script_command(io, index)
        when 209 # Move route
          io.puts("#{' ' * @indent}# TODO : Moveroute !")
        else
          io.puts("#{' ' * @indent}# untranslated command (#{cmd.code} : #{param})")
        end
        return index
      end

      def translate_erase_picture(io, param)
        io.puts("#{' ' * @indent}picture_num = #{param[0]} + ($game_temp.in_battle ? 50 : 0)") if @last_pic_number != param[0]
        @last_pic_number = param[0]
        io.puts("#{' ' * @indent}$game_screen.pictures[picture_num].erase")
      end

      def translate_picture_tone_change(io, param)
        io.puts("#{' ' * @indent}picture_num = #{param[0]} + ($game_temp.in_battle ? 50 : 0)") if @last_pic_number != param[0]
        @last_pic_number = param[0]
        io.puts("#{' ' * @indent}$game_screen.pictures[picture_num].start_tone_change(Tone.new#{param[1]}, #{param[2]} * 2)")
      end

      def translate_rotate_picture(io, param)
        io.puts("#{' ' * @indent}picture_num = #{param[0]} + ($game_temp.in_battle ? 50 : 0)") if @last_pic_number != param[0]
        @last_pic_number = param[0]
        io.puts("#{' ' * @indent}$game_screen.pictures[picture_num].rotate(#{param[1]})")
      end

      def translate_move_picture(io, param)
        value = param[3] == 0
        x = value ? param[4] : "$game_variables[#{param[4]}]"
        y = value ? param[5] : "$game_variables[#{param[5]}]"
        io.puts("#{' ' * @indent}picture_num = #{param[0]} + ($game_temp.in_battle ? 50 : 0)") if @last_pic_number != param[0]
        @last_pic_number = param[0]
        io.puts("#{' ' * @indent}$game_screen.pictures[picture_num].move(#{param[1]} * 2, #{param[2]}, #{x}, #{y}, #{param[6, 4].join(', ')})")
      end

      def translate_display_picture(io, param)
        value = param[3] == 0
        x = value ? param[4] : "$game_variables[#{param[4]}]"
        y = value ? param[5] : "$game_variables[#{param[5]}]"
        io.puts("#{' ' * @indent}picture_num = #{param[0]} + ($game_temp.in_battle ? 50 : 0)") if @last_pic_number != param[0]
        @last_pic_number = param[0]
        io.puts("#{' ' * @indent}$game_screen.pictures[picture_num].show('#{param[1]}', #{param[2]}, #{x}, #{y}, #{param[6, 4].join(', ')})")
      end

      def translate_screen_tone_change(io, param)
        if param[0] != Yuki::TJN::TONE[3]
          io.puts("#{' ' * @indent}$game_screen.start_tone_change(Tone.new#{param[0]}, #{param[1]} * 2)")
        else
          io.puts("#{' ' * @indent}Yuki::TJN.force_update_tone(0)")
        end
      end

      def translate_map_property_command(io, param)
        case param[0]
        when 0
          io.puts("#{' ' * @indent}$game_map.panorama_name = '#{param[1]}'")
          io.puts("#{' ' * @indent}$game_map.panorama_hue = #{param[2]}")
        when 1
          io.puts("#{' ' * @indent}$game_map.fog_name = '#{param[1]}'")
          io.puts("#{' ' * @indent}$game_map.fog_hue = #{param[2]}")
          io.puts("#{' ' * @indent}$game_map.fog_opacity = #{param[3]}")
          io.puts("#{' ' * @indent}$game_map.fog_blend_type = #{param[4]}")
          io.puts("#{' ' * @indent}$game_map.fog_zoom = #{param[5]}")
          io.puts("#{' ' * @indent}$game_map.fog_sx = #{param[6]}")
          io.puts("#{' ' * @indent}$game_map.fog_sy = #{param[7]}")
        when 2
          io.puts("#{' ' * @indent}$game_map.battleback_name = '#{param[1]}'")
          io.puts("#{' ' * @indent}$game_temp.battleback_name = '#{param[1]}'")
        end
      end

      def translate_map_scroll_command(io, param)
        io.puts("#{' ' * @indent}scroll_map(direction: #{param[0]}, disatance: #{param[1]}, speed: #{param[2]})")
      end

      def translate_displace_command(io, param)
        value = param[1] == 0
        d = value ? param[4] : "$game_variables[#{param[4]}]"
        d = param[4] == 0 ? nil : ", direction: #{d}"
        if param[1] < 2
          x = value ? param[2] : "$game_variables[#{param[2]}]"
          y = value ? param[3] : "$game_variables[#{param[3]}]"
          io.puts("#{' ' * @indent}displace_event(event: #{param[0]}, x: #{x}, y: #{y} #{d})")
        else
          io.puts("#{' ' * @indent}swap_event(event: #{param[0]}, with: #{param[2]} #{d})")
        end
      end

      def translate_warp_command(io, param)
        value = param[0] == 0
        map_id = value ? param[1] : "$game_variables[#{param[1]}]"
        x = value ? param[2] : "$game_variables[#{param[2]}]"
        y = value ? param[3] : "$game_variables[#{param[3]}]"
        d = value ? param[4] : "$game_variables[#{param[4]}]"
        d = param[4] == 0 ? nil : ", direction: #{d}"
        io.puts("#{' ' * @indent}warp_player(map_id: #{map_id}, x: #{x}, y: #{y} #{d}, transition: #{param[5] == 0})")
      end

      def translate_disable_encounter_command(io, param)
        io.puts("#{' ' * @indent}$game_system.encounter_disabled = #{param[0] == 0}")
        io.puts("#{' ' * @indent}$game_player.make_encounter_count") unless param[0] == 0
      end

      def translate_item_gain_command(io, param)
        io.puts("#{' ' * @indent}$bag.add_item(#{param[0]}, amount = #{value = operate_value(*param[1, 3])})")
        socket = GameData::Item[param[0]].socket
        if value.to_i >= 0
          io.puts("#{' ' * @indent}Audio.me_play('#{::Interpreter::ItemGetME[(socket == 3 ? 2 : (socket == 5 ? 1 : 0))]}, 80) if amount > 0")
        end
      end

      def translate_earn_gold_command(io, param)
        io.puts("#{' ' * @indent}$game_party.gain_gold(#{operate_value(*param[0, 3])})")
      end

      # Command that retrieve a value and negate it if wanted
      # @param operation [Integer] if 1 negate the value
      # @param operand_type [Integer] if 0 takes operand, otherwise take the game variable n°operand
      # @param operand [Integer] the value or index
      def operate_value(operation, operand_type, operand)
        # オペランドを取得
        if operand_type == 0
          value = operand
        else
          value = "$game_variables[#{operand}]"
        end
        # 操作が [減らす] の場合は符号を反転
        if operation == 1
          value = "-#{value}"
        end
        # value を返す
        return value
      end

      def translate_timer_command(io, param)
        if param[0] == 0
          io.puts("#{' ' * @indent}$game_system.timer = #{param[1]} * 60")
          io.puts("#{' ' * @indent}$game_system.timer_working = true")
        else
          io.puts("#{' ' * @indent}$game_system.timer_working = false")
        end
      end

      def translate_self_switch_set(io, param)
        io.puts("#{' ' * @indent}set_self_switch(#{param[1] == 0}, '#{param[0]}')")
        io.puts("#{' ' * @indent}$game_map.need_refresh = true")
      end

      def translate_variable_set(io, param)
        value = compute_variable_set_value(param)
        op = compute_variable_set_operation(param)
        if param[0] == param[1]
          if param[2].between?(4, 5)
            io.puts("#{' ' * @indent}variable_value = #{value}")
            io.puts("#{' ' * @indent}$game_variables[#{param[0]}] #{op} variable_value if variable_value != 0 # Prevent from dividing by 0")
          else
            io.puts("#{' ' * @indent}$game_variables[#{param[0]}] #{op} #{value}")
          end
        else
          io.puts("#{' ' * @indent}variable_value = #{value}")
          if param[2].between?(4, 5)
            io.puts("#{' ' * @indent}variable_value = 1 if variable_value == 0 # Prevent from dividing by 0")
          end
          io.puts("#{' ' * @indent}#{param[0]}.upto(#{param[1]}) { |var_id| $game_variables[var_id] #{op} variable_value")
        end
        io.puts("#{' ' * @indent}$game_map.need_refresh = true")
      end

      def compute_variable_set_value(param)
        case param[3]
        when 0 # Defined value
          return param[4]
        when 1 # Variable value
          return "$game_variables[#{param[4]}]"
        when 2 # Random value
          return "#{param[4]} + rand(#{param[5] - param[4] + 1})"
        when 3 # Item quantity
          return "$bag.item_quantity(#{param[4]})"
        when 4 # Actor info (battle)
          actor = "actor = PFM::BattleInterface.get_actor(#{param[4]})"
          case param[5]
          when 0 # Level
            return "(#{actor} and actor.level) or 0"
          when 1 # EXP
            return "(#{actor} and actor.exp) or 0"
          when 2 # HP
            return "(#{actor} and actor.hp) or 0"
          when 4 # Max HP
            return "(#{actor} and actor.max_hp) or 0"
          when 6 # Loyalty
            return "(#{actor} and actor.loyalty) or 0"
          when 7 # Accuracy
            return "(#{actor} and actor.acc_stage) or 0"
          when 8 # Speed
            return "(#{actor} and actor.spd) or 0"
          when 9 # ATS
            return "(#{actor} and actor.ats) or 0"
          when 10 # Attack
            return "(#{actor} and actor.atk) or 0"
          when 11 # Def
            return "(#{actor} and actor.dfe) or 0"
          when 12 # DFS
            return "(#{actor} and actor.dfs) or 0"
          when 13 # Evasion
            return "(#{actor} and actor.eva_stage) or 0"
          end
        when 5 # Enemy info (battle)
          enemy = "enemy = PFM::BattleInterface.get_enemy(#{param[4]})"
          case param[5]
          when 0 # HP
            return "(#{enemy} and enemy.hp) or 0"
          when 2 # Max HP
            return "(#{enemy} and enemy.max_hp) or 0"
          when 4 # Loyalty
            return "(#{enemy} and enemy.loyalty) or 0"
          when 5 # Accuracy
            return "(#{enemy} and enemy.acc_stage) or 0"
          when 6 # Speed
            return "(#{enemy} and enemy.spd) or 0"
          when 7 # ATS
            return "(#{enemy} and enemy.ats) or 0"
          when 8 # Attack
            return "(#{enemy} and enemy.atk) or 0"
          when 9 # Def
            return "(#{enemy} and enemy.dfe) or 0"
          when 10 # DFS
            return "(#{enemy} and enemy.dfs) or 0"
          when 11 # Evasion
            return "(#{enemy} and enemy.eva_stage) or 0"
          end
        when 6 # Character information
          character = "character = get_character(#{param[4]})"
          case param[5]
          when 0 # X position
            return "(#{character} and character.x - ::Yuki::MapLinker.current_OffsetX) or 0"
          when 1 # Y Position
            return "(#{character} and character.y - ::Yuki::MapLinker.current_OffsetY) or 0"
          when 2 # Direction
            return "(#{character} and character.direction) or 0"
          when 3 # Screen X
            return "(#{character} and character.screen_x) or 0"
          when 4 # Screen Y
            return "(#{character} and character.screen_y) or 0"
          when 5 # Terrain tag
            return "(#{character} and character.terrain_tag) or 0"
          end
        when 7 # Special things
          case param[5]
          when 0 # MAP ID
            return "$game_map.map_id"
          when 1 # Party Size
            return "$actors.size"
          when 2 # Money
            return "$pokemon_party.money"
          when 3 # Steps
            return "$pokemon_party.steps"
          when 4 # "Time"
            return "Graphics.frame_count / 60"
          when 5 # Timer value
            return "$game_system.timer / 60"
          when 6 # Save count
            return "$game_system.save_count"
          end
        end
        return '0'
      end

      def compute_variable_set_operation(param)
        case param[2]
        when 0
          return '='
        when 1
          return '+='
        when 2
          return '-='
        when 3
          return '*='
        when 4
          return '/='
        when 5
          return '%='
        end
      end

      def translate_multiple_switch_set(io, param)
        if param[0] == param[1]
          io.puts("#{' ' * @indent}$game_switches[#{param[0]}] = #{param[2] == 0}")
        else
          io.puts("#{' ' * @indent}#{param[0]}.upto(#{param[1]}) { |switch_id| $game_switches[switch_id] = #{param[2] == 0}}")
        end
        io.puts("#{' ' * @indent}$game_map.need_refresh = true")
      end

      def translate_wait_command(io, cmd)
        io.puts("#{' ' * @indent}wait(#{cmd.parameters.first})")
      end

      def translate_wait_input_command(io, cmd)
        io.puts("#{' ' * @indent}wait until Input.trigger?(:#{::Interpreter::RGSS2LiteRGSS_Input[cmd.parameters.first]})")
      end

      def translate_window_setting_command(io, cmd)
        io.puts("#{' ' * @indent}$game_system.message_position = #{cmd.parameters[0]}")
        io.puts("#{' ' * @indent}$game_system.message_frame = #{cmd.parameters[1]}")
      end

      def translate_script_command(io, index)
        current_message_string = @list[index].parameters[0].force_encoding(Encoding::UTF_8)
        loop do
          cmd = @list[index + 1]
          if cmd.code == 655 # Script continuation
            current_message_string << "\n" << cmd.parameters[0].force_encoding(Encoding::UTF_8)
          else
            break
          end
          index += 1
        end

        script = test_condition_eval(current_message_string).gsub("\n", "\n#{' ' * @indent}")
        io.puts("#{' ' * @indent}#{script}")

        index
      end

      def translate_shop_command(io, index)
        goods = [@list[index].parameters]
        loop do
          index += 1
          cmd = @list[index]
          if(cmd.code == 605)
            goods << cmd.parameters
          else
            break
          end
        end

        io.puts("#{' ' * @indent}call_shop(#{goods.inspect[1...-1]})")

        index
      end

      def translate_message_command(io, index)
        linecount = 1
        current_message_string = @list[index].parameters[0].force_encoding(Encoding::UTF_8)
        choice_cancel_type = nil
        choice_list = nil
        loop do
          cmd = @list[index + 1]
          if cmd.code == 401 # Message continuation
            current_message_string << "\n" << cmd.parameters[0].force_encoding(Encoding::UTF_8)
            linecount += 1
          elsif cmd.code == 102 # Choice
            choice_cancel_type = cmd.parameters[1]
            choice_list = cmd.parameters[0].clone.collect { |s| s.force_encoding(Encoding::UTF_8) }
          elsif cmd.code == 103 # Input number
            translate_input_number_command(io, index + 1, linecount)
          else
            break
          end
          index += 1
        end

        if choice_list
          io.puts("#{' ' * @indent}choice#{cmd.indent} = show_choice(#{current_message_string.inspect}, #{choice_list.inspect[1...-1]}, cancel_type: #{choice_cancel_type})")
        else
          io.puts("#{' ' * @indent}show_message(#{current_message_string.inspect})")
        end

        index
      end

      def translate_choice_command(io, cmd)
        choice_cancel_type = cmd.parameters[1]
        choice_list = cmd.parameters[0].clone.collect { |s| s.force_encoding(Encoding::UTF_8) }
        io.puts("#{' ' * @indent}choice#{cmd.indent} = show_choice('Choose.', #{choice_list.inspect[1...-1]}, cancel_type: #{choice_cancel_type})")
      end

      def translate_input_number_command(io, index, linecount = 0)
        cmd = @list[index]
        io.puts("#{' ' * @indent}$game_temp.num_input_start = #{line_count}")
        io.puts("#{' ' * @indent}$game_temp.num_input_variable_id = #{cmd.parameters[0]}")
        io.puts("#{' ' * @indent}$game_temp.num_input_digits_max = #{@list[@index].parameters[1]}")
        io.puts("#{' ' * @indent}show_message('Enter a number')") if linecount == 0
      end

      def write_event_condition(io, cmd, current_list)
        @last_pic_number = nil
        internal_labels = @labels.keys - current_list[:internal_labels]
        internal_labels = internal_labels.collect { |label| "g#{@labels[label]}" }
        condition_string = translate_condition(cmd)
        if internal_labels.empty?
          io.puts("#{' ' * @indent}if #{condition_string}")
        else
          io.puts("#{' ' * @indent}if (#{condition_string}) or #{internal_labels.join(' or ')}")
        end
        @indent += 2
      end

      def translate_condition(cmd)
        param = cmd.parameters
        case param.first
        when 0 # Switch condition
          return "$game_switches[#{param[1]}] == #{param[2] == 0}"
        when 1 # Variable condition
          value1 = "$game_variables[#{param[1]}]"
          value2 = param[2] != 0 ? "$game_variables[#{param[3]}]" : param[2]
          case param[4]
          when 0
            return "#{value1} == #{value2}"
          when 1
            return "#{value1} >= #{value2}"
          when 2
            return "#{value1} <= #{value2}"
          when 3
            return "#{value1} > #{value2}"
          when 4
            return "#{value1} < #{value2}"
          when 5
            return "#{value1} != #{value2}"
          end
        when 2 # local switch condition
          return param[2] == 0 ? "get_self_switch('#{param[1]}')" : "not get_self_switch('#{param[1]}')"
        when 3 # Timer condition
          if param[2] == 0
            return "$game_system.timer_working and ($game_system.timer / 60) >= #{param[1]}"
          else
            return "$game_system.timer_working and ($game_system.timer / 60) <= #{param[1]}"
          end
        when 4 # Actor condition (battle)
          actor = "actor = PFM::BattleInterface.get_actor(#{param[1]})"
          case param[2]
          when 0 # In party && alive
            return "#{actor} and !actor.dead?"
          when 1 # Name
            return "#{actor} and actor.given_name == #{param[3].inspect}"
          when 2 # Skill learnt
            return "#{actor} and actor.skill_learnt?(#{param[3]}, true)"
          when 3 # Item holding
            return "#{actor} and actor.item_holding == #{param[3]}"
          when 4 # Ability
            return "#{actor} and actor.current_ability == #{param[3]}"
          when 5 # Status
            return "#{actor} and actor.status == #{param[3]}"
          end
        when 5 # Enemy condition (battle)
          enemy = "enemy = PFM::BattleInterface.get_enemy(#{param[1]})"
          case param[2]
          when 0 # Alive
            return "#{enemy} and !enemy.dead?"
          when 1 # Status
            return "#{enemy} and enemy.status == #{param[3]}"
          end
        when 6 # Character direction
          character = "character = get_character(#{param[1]})"
          return "#{character} and character.direction == #{param[2]}"
        when 7 # Money
          if param[2] == 0
            return "$pokemon_party.money >= #{param[1]}"
          else
            return "$pokemon_party.money <= #{param[1]}"
          end
        when 8 # Item stored
          return "$bag.contain_item?(#{param[1]})"
        when 11 # Key pressed
          return "Input.press?(:#{::Interpreter::RGSS2LiteRGSS_Input[param[1]]})"
        when 12 # Script condition
          return test_condition_eval(param[1])
        end

        return 'false'
      end

      def test_condition_eval(script)
        RubyVM::InstructionSequence.compile(script)
        return script
      rescue SyntaxError
        puts 'Une erreur de syntaxe a été détectée dans la condition de script suivante : '
        puts script
        puts "Merci de bien vouloir corriger vos évènements avant de relancer ce script\n"
        raise
      end

      def write_event_choice(io, cmd, current_list)
        @last_pic_number = nil
        internal_labels = @labels.keys - current_list[:internal_labels]
        internal_labels = internal_labels.collect { |label| "g#{@labels[label]}" }
        condition_string = "some_choice"
        if @choices.last == cmd.indent && internal_labels.empty?
          io.print("#{' ' * (@indent - 2)}els")
          indent_str = nil
        elsif @choices.last == cmd.indent
          write_end(io)
          indent_str = ' ' * @indent
        else
          @choices << cmd.indent
          indent_str = ' ' * @indent
        end
        if internal_labels.empty?
          io.puts("#{indent_str}if #{condition_string}")
        else
          io.puts("#{indent_str}if (#{condition_string}) or #{internal_labels.join(' or ')}")
        end
        @indent += 2 if indent_str
        io.puts(cmd.code == 403 ? "#{' ' * @indent}# Cancel option" : "#{' ' * @indent}# Choice #{cmd.parameters.first}")
      end

      BATTLE_RESULT_SYM = { 601 => :victory, 602 => :escape, 603 => :defeat }
      def write_event_battle_result_conditions(io, cmd, current_list)
        @last_pic_number = nil
        internal_labels = @labels.keys - current_list[:internal_labels]
        internal_labels = internal_labels.collect { |label| "g#{@labels[label]}" }
        condition_string = "battle_result == :#{BATTLE_RESULT_SYM[cmd.code]}"
        if @choices.last == cmd.indent && internal_labels.empty?
          io.print("#{' ' * (@indent - 2)}els")
          indent_str = nil
        elsif @choices.last == cmd.indent
          write_end(io)
          indent_str = ' ' * @indent
        else
          @choices << cmd.indent
          indent_str = ' ' * @indent
        end
        if internal_labels.empty?
          io.puts("#{indent_str}if #{condition_string}")
        else
          io.puts("#{indent_str}if (#{condition_string}) or #{internal_labels.join(' or ')}")
        end
        @indent += 2 if indent_str
      end

      def is_skipable_list(current_list)
        if current_list[:begin] == current_list[:end]
          code = @list[current_list[:end]].code
          return true if code == 112 || code == 413 || code == 0
        end
        return false
      end
    end
  end
end
