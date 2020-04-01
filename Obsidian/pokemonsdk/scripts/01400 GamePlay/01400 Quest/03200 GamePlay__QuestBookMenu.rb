#encoding: utf-8

module GamePlay
  # Menu to choose which list of quest to show
  class QuestBookMenu < Base
    include UI #Add the UI functions to the current interface
    include Text::Util #Add the text functions to the interface
    # Create a new QuestBookMenu
    def initialize
      super() # Call the Base initialize method ignoring the argument of the current initialize
      @viewport = Viewport.create(:main, 1000) # Viewport that holds the sprites of the interface
      init_text(0, @viewport) # Initialize the add_text function
      @is_showing_failed = isf = $quests.failed_quests.size > 0 # Testing if we show failed quest or not
      # Showing the background
      Sprite.new(@viewport).set_bitmap(isf ? "quest/quest_bg_1" : "quest/quest_bg_1_2", :interface)
      # Showing the texts
      add_text(0, isf ? 39 : 53, 320, 23, ext_text(9000, 48), 1, 1).load_color(9) # "Quêtes principales"
      add_text(0, isf ? 84 : 106, 320, 23, ext_text(9000, 49), 1, 1).load_color(9) # "Quêtes secondaires"
      # "Quêtes échouées"
      add_text(0, 129, 320, 23, ext_text(9000, 50), 1, 1).load_color(9) if isf # If set after "quitter", there will be error with index
      add_text(0, isf ? 174 : 159, 320, 23, ext_text(9000, 26), 1, 1).load_color(9)
      # Showing the selector
      @index = 0
      @selector = Sprite.new(@viewport)
        .set_position(0, @texts[@index].y + FOY) # FOY is a factor of ajustment stored in Text::Util
        .set_bitmap("quest/quest_selector", :interface)
    end

    # Updates the interface
    def update
      return unless super # The update method from base tells if the update can continue or not (message display)
      max_index = @is_showing_failed ? 3 : 2
      if index_changed(:@index, :UP, :DOWN, max_index) # Check the user input affecting the index
        @selector.set_position(0, @texts[@index].y + FOY) # Adjust the selector position
      end
      if Input.trigger?(:A)
        return @running = false if @index == max_index
        # Start the quest list scene according to the index
        call_scene(QuestBookList, [:primary, :secondary, :failed][@index])
      end
      @running = false if Input.trigger?(:B)
    end

    def create_graphics
      # Skipped to prevent glitches
    end
  end
end
