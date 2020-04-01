#encoding: utf-8

module GamePlay
  # Menu to choose which quest to show
  class QuestBookList < Base
    include Text::Util #Add the text functions to the interface
    # Create a new QuestBookList
    # @param type [Symbol] type of the list to show
    def initialize(type)
      super() # Call the Base initialize method ignoring the argument of the current initialize
      @viewport = Viewport.create(:main, 1000) # Viewport that holds the sprites of the interface
      @viewport2 = Viewport.create(80, 24, 160, 189, 1001)
      init_text(0, @viewport2) # Initialize the add_text function
      # Showing the background
      Sprite.new(@viewport).set_bitmap("quest/quest_bg_list", :interface)
      __get_quests(type)
      @type = type
      # Showing the texts
      @quests_name.each_with_index do |name, i|
        add_text(1, i * 23, 160, 23, name).load_color($quests.finished?(@quests_id[i]) ? 11 : 9)
      end
      add_text(0, @quests_name.size * 23, 160, 23, ext_text(9000, 51), 1).load_color(9)
      # Showing the selector
      @index = 0
      @selector = Sprite.new(@viewport2)
        .set_position(0, 0)
        .set_bitmap("quest/quest_selector_list", :interface)
    end

    # Updates the interface
    def update
      return unless super # The update method from base tells if the update can continue or not (message display)
      max_index = @quests_name.size
      if index_changed(:@index, :UP, :DOWN, max_index) # Check the user input affecting the index
        @selector.set_position(0, @index * 23) # Adjust the selector position
        adjust_viewport
      end
      if Input.trigger?(:A)
        return @running = false if @index == max_index
        call_scene(QuestBookQuest, @quests_id[@index], @index, @quests_id)
      end
      @running = false if Input.trigger?(:B)
    end

    # Adjust the viewport position
    def adjust_viewport
      return if @quests_name.size < 8
      if @index >= 4 and @index < @quests_name.size - 4
        @viewport2.oy = (@index - 3) * 23
      elsif @index < 4
        @viewport2.oy = 0
      else
        @viewport2.oy = (@quests_name.size - 7) * 23
      end
    end

    # Get the quests to list
    # @param type [Symbol] type of the list to show
    def __get_quests(type)
      case type
      when :primary
        @quests_id =
          ($quests.active_quests.keys + $quests.finished_quests.keys).select { |id| GameData::Quest.primary?(id) }
      when :secondary
        @quests_id =
          ($quests.active_quests.keys + $quests.finished_quests.keys).reject { |id| GameData::Quest.primary?(id) }
      when :failed
        @quests_id = $quests.failed_quests.keys
      end
      @quests_name = @quests_id.collect { |id| text_get(45, id) }
    end

    # Change the viewport visibility of the scene
    # @param v [Boolean]
    def visible=(v)
      @viewport2.visible = v
      super
    end

    def create_graphics
      # Skipped to prevent glitches
    end
  end
end
