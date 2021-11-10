# Describe an Event during the Map display process
class Game_Event < Game_Character
  # Tag inside an event that put it in the surfing state
  SURFING_TAG = 'surf_'
  # If named like this, this event is an invisible object
  INVISIBLE_EVENT_NAME = 'OBJ_INVISIBLE'
  # Tag that sets the event in an invisible state (not triggerd unless in front of it)
  INVISIBLE_EVENT_TAG = 'invisible_'
  # Tag that tells the event to always take the character_name of the first page when page change
  AUTO_CHARSET_TAG = '$'
  # Tag that tells the event not to push particles when it moves
  PARTICLE_OFF_TAG = '[particle=off]'
  # Tag that detect offset_screen_y
  OFFSET_Y_TAG = /\[offset_y=([0-9\-]+)\]/
  # Tag that forbid the creation of a Sprite_Character for this event
  NO_SPRITE_TAG = '[sprite=off]'
  # Tag that give the event an symbol alias
  SYMBOL_ALIAS_TAG = /\[alias=([a-z\-0-9\-_]+)\]/
  # Tag enabling reflection
  REFLECTION_TAG = '[reflection=on]'
  # @return [Integer, nil] Type of trigger for the event (0: Action key, 1: Player contact, 2: Event contact, 3: Autorun, 4: Parallel process)
  attr_reader :trigger
  # @return [Array<RPG::EventCommand>] list of commands that should be executed
  attr_reader :list
  # @return [Boolean] if the event wants to start
  attr_reader :starting
  # @return [RPG::Event] the event data from the MAP
  attr_reader :event
  # @return [Boolean] if the event is an invisible event (should be in front of the event to trigger it when it doesn't have a character_name)
  attr_reader :invisible_event
  # @return [Boolean] if the event was erased (needs to be removed from the view)
  attr_reader :erased
  # @return [Integer] Original id of the event
  attr_reader :original_id
  # @return [Integer] Original map id of the event
  attr_reader :original_map
  # @return [Symbol, nil] The symbol alias of the event
  attr_reader :sym_alias
  # Initialize the Game_Event with its map_id and its RPG::Event data
  # @param map_id [Integer] id of the map where the event is instanciated
  # @param event [RPG::Event] data of the event
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @original_map = event.original_map || map_id
    @original_id = event.original_id || @id
    @erased = false
    @starting = false
    @through = true
    @can_parallel_execute = @original_map == map_id
    initialize_parse_name
    moveto(@event.x, @event.y)
    refresh
  end

  # Parse the event name in order to setup the event particularity
  def initialize_parse_name
    return unless (name = @event.name)
    @particles_disabled = name.include?(PARTICLE_OFF_TAG) || @event.name.include?(NO_SPRITE_TAG)
    @autocharset = name.include?(AUTO_CHARSET_TAG)
    name.sub(OFFSET_Y_TAG) { @offset_screen_y = $1.to_i }
    @surfing = name.include?(SURFING_TAG)
    @invisible_event = (name == INVISIBLE_EVENT_NAME || name.include?(INVISIBLE_EVENT_TAG))
    name.sub(SYMBOL_ALIAS_TAG) { @sym_alias = $1.to_sym }
    @reflection_enabled = name.include?(REFLECTION_TAG)
  end

  # Tell if the event can execute in parallel process or automatic process
  # @return [Boolean]
  def can_parallel_execute?
    return @can_parallel_execute
  end

  # Tell if the event can have a sprite or not
  def can_be_shown?
    return !@event.name.include?(NO_SPRITE_TAG)
  end

  # Sets @starting to false allowing the event to move with its default move route
  def clear_starting
    @starting = false
  end

  # Tells if the Event cannot start
  # @return [Boolean]
  def over_trigger?
    return false if !@character_name.empty? && !@through || @invisible_event
    return false unless $game_map.passable?(@x, @y, 0)

    return true
  end

  # Starts the event if possible
  def start
    @starting = true unless @list.empty?
  end

  # Remove the event from the map
  def erase
    @erased = true
    @x = -10
    @y = -10
    @opacity = 0
    $game_map.event_erased = true
    refresh
  end

  # Refresh the event : check if an other page is valid and if so, refresh the graphics and command list
  def refresh
    new_page = nil
    unless @erased
      @event.pages.reverse_each do |page|
        next unless page.condition.valid?(@original_map, @original_id)

        new_page = page
        break
      end
    end
    return if new_page == @page
    return unless refresh_page(new_page) && can_parallel_execute?

    @interpreter = Interpreter.new if @trigger == 4
    check_event_trigger_auto
  end

  # Check if the event touch the player and start it if so
  # @param x [Integer] the x position to check
  # @param y [Integer] the y position to check
  def check_event_trigger_touch(x, y)
    return if $game_system.map_interpreter.running?
    return unless @trigger == 2 && $game_player.contact?(x, y, @z) # and x == $game_player.x and y == $game_player.y
    start unless jumping? && over_trigger?
  end

  # Check if the event starts automaticaly and start if so
  def check_event_trigger_auto
    if @trigger == 2 && $game_player.contact?(@x, @y, @z) && !$game_temp.player_transferring
      start if !jumping? and over_trigger?
    end
    start if @trigger == 3
  end

  # Update the Game_Character and its internal Interpreter
  def update
    super
    check_event_trigger_auto
    return unless @interpreter
    @interpreter.setup(@list, @event.id) unless @interpreter.running?
    @interpreter.update
  end
  
  def find_path(**kwargs)
    super(**kwargs) if Yuki::MapLinker.from_center_map?(self)
  end

  # Check if the character is activate. Useful to make difference between event without active page and others.
  # @return [Boolean]
  def activated?
    return !@page.nil?
  end
  
  private

  # Refresh all the information of the event according to the new page
  # @param new_page [RPG::Event::Page]
  # @return [Boolean] if the refresh function can continue
  def refresh_page(new_page)
    @page = new_page
    clear_starting
    if @page.nil?
      @tile_id = 0
      set_appearance(nil.to_s)
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      return false
    end
    @tile_id = @page.graphic.tile_id
    # Patch auto charset
    if @autocharset
      set_appearance(@event.pages[0].graphic.character_name, @event.pages[0].graphic.character_hue)
    else
      set_appearance(@page.graphic.character_name, @page.graphic.character_hue)
    end

    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end

    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end

    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    self.move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    return true
  end
end
