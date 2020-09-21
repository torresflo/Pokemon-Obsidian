class TMXConverter
  # Interpret an add command
  # @param cmd [Array] list of commands for the add command
  def interpret_add_command(cmd)
    case cmd.first
    when 'tileset'
      if @project_data[:tilesets][cmd[1]]
        puts 'This tileset already exists'
      else
        if !cmd[2] || cmd[2].empty?
          puts 'No PNG filename...'
          return
        end
        @project_data[:tilesets][cmd[1]] = cmd[2]
        @project_tilesets[cmd[1]] = TMX_Tileset.new(cmd[1])
        puts 'Done'
      end
    when 'map'
      interpret_map_add_command(cmd[1..-1])
    end
  end

  # Interpret add map command
  # @param cmd [Array] list of parameters
  def interpret_map_add_command(cmd)
    if File.exist?(cmd.first)
      if @project_data[:tilesets][cmd[1]]
		if(cmd.last.to_i < 2)
			puts 'You cannot assign the ID 0 or 1 to a map.'
			return
		else
			@project_data[:maps][cmd.first] = { id: cmd.last.to_i, tileset: cmd[1] }
			puts 'WARNING - Check the ID of your map and recreate it if necessary!'
			puts 'Done'
			return
		end
      end
      puts 'The choosen tileset doesn\'t exist!'
      return
    end
    puts 'The tmx file doesn\'t exist!'
  end

  # Interpret a reset command
  # @param cmd [Array] list of commands for the add command
  def interpret_reset_command(cmd)
    return if cmd.first != 'tileset'
    if @project_data[:tilesets][cmd[1]]
      puts 'Done'
      return @project_tilesets[cmd[1]] = TMX_Tileset.new
    end
    puts 'This tileset doesn\'t exist!'
  end

  # Interpret a del command
  # @param cmd [Array] list of commands for the add command
  def interpret_del_command(cmd)
    case cmd.first
    when 'tileset'
      interpret_del_tileset_command(cmd[1..-1])
    when 'map'
      if @project_data[:maps][cmd[1]]
        @project_data[:maps].delete(cmd[1])
        puts 'Done'
      else
        puts 'This map doesn\'t exist!'
      end
    end
  end

  # Interpret a tileset delete command
  # @param cmd [Array]
  def interpret_del_tileset_command(cmd)
    if @project_data[:tilesets][cmd.first]
      if @project_data[:maps].any? { |*, map| map[:tileset] == cmd.first }
        puts 'This tileset is still being used.'
        return
      end
      @project_data[:tilesets].delete(cmd.first)
      puts 'Done'
      return
    end
    puts 'This tileset doesn\'t exist!'
  end

  # Interpret a convert command
  # @param cmd [Array] list of commands for the add command
  def interpret_convert_command(cmd)
    if cmd.first == '*'
      @project_data[:maps].each_key do |map_name|
        convert_map(map_name)
      end
    else
      unless @project_data[:maps][cmd.first]
        puts 'This map doesn\'t exist!'
        return
      end
      convert_map(cmd.first)
    end
    puts 'Done'
  end

  # Interpret a list command
  # @param cmd [Array] list of commands for the add command
  def interpret_list_command(cmd)
    case cmd.first
    when 'map'
      @project_data[:maps].each do |tmx_name, data|
        puts format('  %<tmx_name>s : Tileset=%<tileset>s MapID=%<map_id>s', tmx_name: tmx_name, tileset: data[:tileset], map_id: data[:id])
      end
    when 'tileset'
      @project_data[:tilesets].each do |tileset_name, png_filename|
        tile_count = @project_tilesets[tileset_name].tile_count
        puts format('  %<tileset_name>s : PNG=%<png_filename>s TileCount=%<tile_count>s/16384',
                    tileset_name: tileset_name,
                    png_filename: png_filename,
                    tile_count: tile_count)
      end
    end
  end
end
