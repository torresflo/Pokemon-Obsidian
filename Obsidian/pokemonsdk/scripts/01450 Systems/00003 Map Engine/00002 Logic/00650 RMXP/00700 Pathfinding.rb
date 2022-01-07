# Pathfinding (PSDK) by Leikt
# Module that handle the automatic pathfinding system.
# Djikstra Algorithm and optimized to be performance friendly.
# If you are experimenting performance issue while the algorithm is running, down the NODE_PER_FRAME value.
# You can customize the cost of each tag in TAGS_WEIGHT.

module Pathfinding
  # Amount of node to calculate in one frame (OPTIMISATION)
  OPERATION_PER_FRAME = 150
  # Amount of node by requests in one frame (OPTIMISATION)
  OPERATION_PER_REQUEST = 50
  # Cost of the reload
  COST_RELOAD = 15
  # Cost of the watch
  COST_WATCH = 9
  # Cost of the wait
  COST_WAIT = 1

  # Obstacle detection range
  OBSTACLE_DETECTION_RANGE = 9
  # Amount of try count
  TRY_COUNT = 5
  # Number of frame before two path search when the first one fail
  TRY_DELAY = 60

  # Directions to check
  PATH_DIRS = [1, 2, 3, 4]
  # Move route when waiting for a new path
  WAITING_ROUTE = RPG::MoveRoute.new
  WAITING_ROUTE.list.unshift(RPG::MoveCommand.new(15, 1))

  # Weight of the tags, the higher is the cost, the more the path will avoid it
  TAGS_WEIGHT = {
    GameData::SystemTags::Road => 2,          # Tag of the main road
    GameData::SystemTags::TSand => 4,         # Tag of the road
    GameData::SystemTags::SwampBorder => 20,  # Avoid swamp if possible
    GameData::SystemTags::DeepSwamp => 30,    # Avoid deep swamp whatever it takes
    GameData::SystemTags::MachBike => 1000,   # Prevent bug
    GameData::SystemTags::TGrass => 20
  }
  TAGS_WEIGHT.default = 10 # Grass, ...
  # module that contains the tags weight for path calculation
  module TagsWeight
    include GameData::SystemTags

    # Default tags weight
    DEFAULT = Pathfinding::TAGS_WEIGHT

    # Test tage weight
    WILD_POKEMON = Hash.new(10)
    WILD_POKEMON[TGrass] = 2
    WILD_POKEMON[Road] = 100
    WILD_POKEMON[TSand] = 100
  end

  # Default save state
  DEFAULT_SAVE = []

  # Initialisation
  # List of requests looking for a path
  @requests = []
  # Amount of operation per frame
  @operation_per_frame = OPERATION_PER_FRAME
  # Last updated researching request
  @last_request_id = 0

  PRESET_COMMANDS = Array.new(5) { |i| RPG::MoveCommand.new(i) }.method(:[])

  # Add the request to the system list and start looking for path
  # @param character [Game_Character] the character looking for a path
  # @param target [Game_Character, Array<Integer>] character or coords to reach
  # @param tries [Integer] the number of tries before giving up the path research. :infinity for infinite try count.
  # @param tags [Symbol] the name of the Pathfinding::TagsWeight constant to use to calcultate the node weight
  # @return [Boolean] if the request is successfully submitted
  def self.add_request(character, target, tries, tags)
    remove_request(character)
    @requests.push Request.new(character, Target.get(*target), tries, tags)
    return true
  end

  # Remove the request from the system list and return true if the request has been popped out.
  # @param character [Game_Character] the character to pop out
  # @return [Boolean] if the request has been popped out
  def self.remove_request(character)
    debug_clear(character.id)
    old_length = @requests.length
    @requests.delete_if { |e| e.character == character }
    @last_request_id = 0 # Reset the request id to prevent problems
    return (old_length > @requests.length)
  end

  # CLear all the requests
  def self.clear
    debug_clear
    @requests.clone.each { |request| remove_request(request.character) }
  end

  # Set the number of operation per frame. By default it's 150, be careful with the performance issues.
  # @param value [Integer] the new amount of operation allowed per frame
  def self.operation_per_frame=(value)
    @operation_per_frame = value
  end

  # Update the pathfinding system
  def self.update
    debug_update
    return if @requests.empty?

    # Initialize
    request_id = @last_request_id # Get the last updates where it's stop
    operation_counter = 0         # Count the amount of operation in this update
    first_update = true           # Indicate if the update is called in the first loop or not
    need_update = true            # When go false for a all loop => stop update
    # Loop while remains operation left and requests
    while operation_counter < @operation_per_frame
      # Update the request and calculate the new operation counter
      operation_counter += (current_request = @requests[request_id]).update(operation_counter, first_update)
      need_update ||= current_request.need_update # Need update to true if the request needs update
      current_request.character.stop_path if current_request.finished? # Delete the finished requests

      # When end of the requests list
      next unless (request_id += 1) >= @requests.length

      request_id = 0 # Go to the first request
      break if !need_update or @requests.empty? # Stop everything if update no longer needed

      first_update = false      # At this point it can't be the first update
      need_update = false       # No first update, reset the need_update to false, it will be turned to true if update is needed
    end
    @last_request_id = request_id # Save the last update position
  end

  # Create an savable array of the current requests
  # @return [Array<Pathfinding::Request>]
  def self.save
    PFM.game_state.pathfinding_requests = @requests.collect(&:save)
  end

  # Load the data from the Game State
  def self.load
    return unless Game_Map::PATH_FINDING_ENABLED

    data = PFM.game_state.pathfinding_requests
    @requests = data.collect { |d| Request.load(d) }
    @requests.delete(nil) # Prevent loading error
  end

  @debug = false
  def self.debug=(value)
    @debug = value
    if value && @debug_viewport.nil?
      @debug_viewport = Viewport.create(:main, 50_000)
      @debug_sprites = {}
      @debug_bitmap = RPG::Cache.animation('pathfinding_debug', 0)
      @debug_sprites_pool = []
    end
    if !value && @debug_viewport
      debug_clear
      @debug_sprites_pool.each(&:dispose)
      @debug_sprites_pool = []
      @debug_viewport.dispose
      @debug_viewport = nil
    end
  end

  # Clear the pathfinding debug data
  # @param from [Integer, nil] the id of the caracter to clear, if nil, clear all
  def self.debug_clear(from = nil)
    return unless @debug

    if from.nil?
      @debug_sprites.values.flatten.each do |s|
        s.visible = false
        @debug_sprites_pool.push s
      end
      @debug_sprites.clear
    elsif @debug_sprites.key?(from)
      @debug_sprites[from].each do |s|
        s.visible = false
        @debug_sprites_pool.push s
      end
      @debug_sprites.delete(from)
    end
  end

  # Update the pathfinding display debug
  def self.debug_update
    return unless @debug

    @debug_viewport.ox = $game_map.display_x / 8 - 24
    @debug_viewport.oy = $game_map.display_y / 8 - 16
  end

  # Add a path to display
  # @param from [Game_Character] the character who follow the path
  # @param cursor [Cursor] the cursor used to calculate the path
  # @param path [Array<Integer>] the list of moveroute command
  def self.debug_add(from, cursor, path)
    return unless @debug

    # Initialisation
    debug_clear(from.id)
    sprites = []
    x = from.x
    y = from.y
    z = from.z
    # Run all the path and place markers
    path.each_with_index do |dir, index|
      code = [dir - 1, 0, 4, 3]
      code = [dir - 1, 1, 4, 3] if index == 0
      sprites.push s = (@debug_sprites_pool.pop ||
        Sprite.new(@debug_viewport).set_bitmap(@debug_bitmap))
        .set_rect_div(*code).set_position(x * 16 - 24, y * 16 - 16)
      s.visible = true

      cursor.sim_move?(x, y, z, dir)
      x = cursor.x
      y = cursor.y
      z = cursor.z
    end
    # Place en marker and store
    sprites.push s = (@debug_sprites_pool.pop ||
      Sprite.new(@debug_viewport).set_bitmap(@debug_bitmap))
      .set_rect_div(0, 2, 4, 3).set_position(x * 16 - 24, y * 16 - 16)
    s.visible = true
    @debug_sprites[from.id] = sprites
  end

  #-------------------------------------------
  # Class that describe a pathfinding request
  #   A request has three caracteristics :
  #   - Character : the character summonning the request
  #   - Target : the target to reach
  #   - Priority : The priority of the request between others
  #
  # Algorithm steps
  # 1st step : Initialization
  #   Creation of the variables (#initialize)
  # 2nde step: Search
  #   Calculate NODES_PER_FRAME nodes per frame to optimize the process (#update_search)
  #   Nodes are calculated in #calculate_node with A* algorithm
  #   Once a path is found, or all possibilies are studied, the request start watching
  # 3rd step : Watch
  #   The Request look for obstacles on the path and restart the search (reload) if there is one
  class Request
    # The character which needs a path
    # @return [Game_Character]
    attr_reader :character
    # Indicate if the request needs update or not
    # @return [Boolean]
    attr_reader :need_update

    # Create the request
    # @param character [Game_Character] the character to give a path
    # @param target [Target] the target data
    # @param tries [Integer, Symbol] the amount of tries allowed before fail, use :infinity to have unlimited tries
    # @param tags [Symbol] the name of the Pathfinding::TagsWeight constant to use to calcultate the node weight
    def initialize(character, target, tries, tags)
      log_debug "Character ##{character.id} request created."
      @character = character
      @target = target
      @state = :search
      @cursor = Cursor.new(character)
      @open = [[0, character.x, character.y, character.z, @cursor.state, -1]]
      @closed = Table32.new($game_map.width, $game_map.height, 7)
      @character.path = :pending # @character.force_move_route(WAITING_ROUTE)
      @remaining_tries = @original_remaining_tries = tries
      @need_update = true
      @tags = tags
      @tags_weight = (Pathfinding::TagsWeight.const_defined?(tags) ?
        Pathfinding::TagsWeight.const_get(tags) : Pathfinding::TagsWeight::DEFAULT)
      Pathfinding.debug_clear(character.id)
    end

    # Indicate if the request is search for path
    # @return [Boolean]
    def searching?
      return @state == :search
    end

    # Indicate if the request is watching for obstacle
    # @return [Boolean]
    def waiting?
      return @state == :wait
    end

    # Inidicate if the request is waiting for new try
    # @return [Boolean]
    def watching?
      return @state == :watch
    end

    # Indicate if the request is to reload
    # @return [Boolean]
    def reload?
      return @state == :reload
    end

    # Indicate if the request is ended
    # @return [Boolean]
    def finished?
      return @character.path.nil?
    end

    # Update the requests and return the number of performed actions
    # @param operation_counter [Integer] the amount of operation left
    # @param is_first_update [Boolean] indicate if it's the first update of the frame
    # @return [Integer]
    def update(operation_counter, is_first_update)
      @need_update ||= is_first_update # Need update forced to true if it's the first update
      case @state
      when :search then return update_search(operation_counter)
      when :watch then return update_watch(is_first_update)
      when :reload then return update_reload(is_first_update)
      when :wait then return update_wait(is_first_update)
      else
        return 1
      end
    end

    # Update the request search and return the new remaining node count
    # @param node_counter [Integer] the amount of node per frame remaining
    # @return [Integer]
    def update_search(operation_counter)
      # Check target already reached
      if @target.reached?(@character.x, @character.y, @character.z)
        @state = :watch
        return 1
      elsif @target.check_move(@character.x, @character.y)
        @state = :reload
        return 1
      end
      # Initialize
      nodes = 0
      nodes_max = operation_counter > OPERATION_PER_REQUEST ? OPERATION_PER_REQUEST : operation_counter
      result = nil
      # Main loop : calculate a certain amount of node to get a result
      while nodes < nodes_max && !result
        result = calculate_node
        nodes += 1
      end
      # Process the result
      process_result(result)
      return nodes + 1
    end

    # Process the result of the node calculation
    # @param result [Array<Integer>, nil, Symbol] the result value
    def process_result(result)
      if result == :not_found
        # If result not found, it start waiting before retrying
        if @remaining_tries == :infinity || (@remaining_tries -= 1) > 0
          log_debug "Character ##{@character.id} fail to found path. Retrying..."
          @state = :wait
          @retry_countdown = TRY_DELAY
        else
          # If no more chances : the path finding end here
          log_debug "Character ##{@character.id} fail to found path"
          @character.stop_path
        end
      # A path is found : throw it to the character
      elsif result
        # Reset the try counter
        @remaining_tries = @original_remaining_tries
        # Start watching for obstacles
        @state = :watch
        send_path(result)
      end
    end

    # Update the request when looking for obstacles
    def update_watch(is_first_update)
      # Check first update
      return 1 unless is_first_update

      # Optimization : Detect stuckness and target mouvement only if the character is on one tile
      if @character.real_x % 128 + @character.real_y % 128 == 0
        # Check target movement
        if @target.check_move(@character.x, @character.y)
          log_debug "Character ##{@character.id}'s target has moved"
          @state = :reload
          return 1
        end
        # Check if the character is stucked
        if stucked?
          log_debug "Character ##{@character.id} is stucked"
          @state = :reload
        # Detect if the target is already reached (player passing next to the event, etc)
        elsif @target.reached?(@character.x, @character.y, @character.z)
          log_debug "Character ##{@character.id} reached the target"
          @character.stop_path
        end
      end
      # Return default cost of a watch update
      @need_update = false
      return COST_WATCH
    end

    # Update the request when waiting before retrying to find path
    def update_wait(is_first_update)
      # Check first update
      return 1 unless is_first_update

      # Update the count_down
      @retry_countdown -= 1
      @state = :reload if @retry_countdown <= 0
      @need_update = false
      return COST_WAIT
    end

    # Reload the request
    def update_reload(is_first_update)
      # Check first update
      return 1 unless is_first_update

      log_debug "Character ##{@character.id} reload request"
      @character.path = :pending # @character.force_move_route(WAITING_ROUTE)
      @open.clear
      @open.push [0, character.x, character.y, character.z, @cursor.state, -1]
      @closed.resize(0, 0, 0) # Clear the table
      @closed.resize($game_map.width, $game_map.height, 7)
      @state = :search
      return COST_RELOAD
    end

    # Make the character following the found path
    # @param path [Array<Integer>] The path, list of move direction
    def send_path(path)
      log_debug "Character ##{@character.id} found a path"
      Pathfinding.debug_add(@character, @cursor, path)
      @character.define_path((path << 0).collect(&PRESET_COMMANDS))
      # @character.force_move_route(Pathfinding.path_to_route(path))
    end

    # Detect if the character is stucked
    # @return [Boolean]
    def stucked?
      # Get the data
      route = @character.path
      return true unless route.is_a?(Array)

      route_index = @character.move_route_index
      x = @character.x
      y = @character.y
      z = @character.z
      b = @character.__bridge

      # Iterate commands to the last one, which is Lentgh - 2 (considering the empty command at end)
      route[route_index..[route.length - 2, route_index + OBSTACLE_DETECTION_RANGE - 1].min]&.each do |command|
        return true unless @cursor.sim_move?(x, y, z, command.code, b)

        x = @cursor.x
        y = @cursor.y
        z = @cursor.z
        b = @cursor.__bridge
      end
      return false
    end

    # Calculate a node and return it if a path is found
    # @return [Object]
    def calculate_node
      # Check for empty list
      return :not_found if (open = @open).empty?

      # Initialize
      target = @target
      cursor = @cursor
      game_map = $game_map
      tags_weight = @tags_weight

      # Get next node
      node = open.shift

      # Closing the selected open node
      (closed = @closed)[node[1], node[2], node[3]] = node[5]

      # Open each side nodes
      PATH_DIRS.each do |direction|
        next unless cursor.sim_move?(node[1], node[2], node[3], direction, *node[4])

        # Check target
        if target.reached?(kx = cursor.x, ky = cursor.y, kz = cursor.z)
          closed[kx, ky, kz] = direction | node[1] << 4 | node[2] << 14 | node[3] << 24
          return backtrace(kx, ky, kz)
        end

        # Open the node and store the backtrace
        next unless closed[kx, ky, kz] == 0 && open.select { |a| a[1] == kx && a[2] == ky && a[3] == kz }.empty?

        # Cost calculation : start with last node cost
        # Add the weight of the tag
        # Retrieve the straight direction (we prefer straight lines)
        cost = node.first + tags_weight[game_map.system_tag(kx, ky)] - ((node[5] & 0xF) == direction ? 1 : 0)
        backtrace_move = direction | node[1] << 4 | node[2] << 14 | node[3] << 24
        # Sort and insert the new node
        unless open.empty?
          index = 0
          index += 1 while index < open.length and open[index].first < cost
          open.insert(index, [cost, kx, ky, kz, cursor.state, backtrace_move])
        else
          open[0] = [cost, kx, ky, kz, cursor.state, backtrace_move]
        end
      end
      # Target not found
      return nil
    end

    # Calculate the path from the given node
    # @param x [Object] the node
    # @return [Array<Integer>] the path
    def backtrace(tx, ty, tz)
      x = tx
      y = ty
      z = tz
      closed = @closed
      path = []
      code = closed[x, y, z]
      until code == -1
        path.unshift code & 0xF # Direction
        x = (code >> 4) & 0x3FF
        y = (code >> 14) & 0x3FF
        z = (code >> 24) & 0xF
        code = closed[x, y, z]
      end
      return path
    end

    # Gather the data ready to be saved
    # @return [Array<Object>]
    def save
      return [@character.id, @target.save, @original_remaining_tries, @tags]
    end

    # (Class method) Load the requests from the given argument
    # @param data [Array<Object>] the data generated by the save method
    def self.load(data)
      character = $game_map.events[data[0]]
      target    = Target.load(data[1])
      tries     = data[2]
      tags      = data[3] || :DEFAULT
      return nil unless character && target && tries # Prevent loading error : when map change

      return Request.new(character, target, tries, tags)
    end
  end
end
