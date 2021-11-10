#encoding: utf-8

module GamePlay
  # Show the quest info
  class QuestBookQuest < Base
    include Text::Util #Add the text functions to the interface
    # Create a new QuestBookList
    # @param id [Integer] Id of the quest to show
    # @param index [Integer] Index of last scene
    # @param quests_id [Array<Integer>] List of quest ids
    def initialize(id, index, quests_id)
      super() # Call the Base initialize method ignoring the argument of the current initialize
      @index = index
      @id = id
      @quests_id = quests_id
      @viewport = Viewport.create(:main, 1000) # Viewport that holds the sprites of the interface
      @viewport2 = Viewport.create(4, 115, 312, 64, 1001)
      init_text(0, @viewport) # Initialize the add_text function
      # Showing the background
      Sprite.new(@viewport).set_bitmap("quest/quest_bg_2", :interface)
      # Showing the selector
      @selector = Sprite.new(@viewport2)
        .set_position(0, 0)
        .set_bitmap("quest/quest_selector", :interface)
      @objective_index = 0
      @selector.src_rect.height = 16
      @selector.z = 1
      # Showing the texts
      @quest_name = add_text(5, 24, 310, 23, nil.to_s, 1)
      @quest_descr = add_text(5, 49, 310, 16, nil.to_s).load_color(9)
      @quest_earnings = Array.new(4) do |i|
        add_text(5 + 156 * (i % 2), 181 + 16 * (i / 2), 154, 16, nil.to_s)
      end
      @objective_stack = UI::SpriteStack.new(@viewport2)
      show_quest
    end

    # Updates the interface
    def update
      return unless super # The update method from base tells if the update can continue or not (message display)
      max_index = @quests_id.size - 1
      if index_changed(:@objective_index, :UP, :DOWN, @objective_max) # Check the user input affecting the index
        @selector.set_position(0, @objective_index * 16) # Adjust the selector position
        adjust_viewport
      end
      if index_changed(:@index, :LEFT, :RIGHT, max_index) # Check the user input affecting the index
        @id = @quests_id[@index]
        show_quest
      end
      @running = false if Input.trigger?(:B)
    end

    # Show the quest info
    def show_quest
      return unless GameData::Quest.id_valid?(@id)
      quest = GameData::Quest.get(@id)
      @quest_name.text = text_get(45, @id)
      @quest_name.load_color($quests.finished?(@id) ? 11 : ($quests.failed?(@id) ? 12 : 9))
      @quest_descr.multiline_text = text_get(46, @id)
      @objective_stack.dispose
      show_objective(quest)
      color = $quests.earnings_got?(@id) ? 12 : 18
      @quest_earnings.each_with_index do |text, i|
        if earning = quest.earnings[i]
          show_earning(text, earning)
          text.load_color(color)
        else
          text.visible = false
        end
      end
    end

    # Show an earning
    # @param text [Text] a text object
    # @param earning [Hash] earning data
    def show_earning(text, earning)
      if earning[:money]
        text.text = "#{earning[:money]}$"
      elsif earning[:item]
        text.text = "#{earning[:item_amount]} #{text_get(12, earning[:item])}"
      end
      text.visible = true
    end

    # Show the objective of a quest
    # @param quest_data [GameData::Quest]
    def show_objective(quest_data)
      order = quest_data.goal_order
      stack = @objective_stack
      stack.dispose
      index = 0
      quest = $quests.active_quests.fetch(@id, nil)
      quest = $quests.finished_quests.fetch(@id, nil) unless quest
      quest = $quests.failed_quests.fetch(@id, nil) unless quest
      order.each_with_index do |type, i|
        next unless $quests.goal_shown?(@id, i)
        y = index * 16
        index_in_table = $quests.get_goal_data_index(@id, i)
        case type
        when :items
          undone = (nb = quest[:items][index_in_table]) < (amount = quest_data.item_amount[index_in_table])
          text = format(ext_text(9000, 52), 
            amount: amount, 
            item_name: text_get(12, quest_data.items[index_in_table]),
            found: nb)
        when :speak_to
          undone = !quest[:spoken][index_in_table]
          text = format(ext_text(9000, 53), name: quest_data.speak_to[index_in_table])
        when :see_pokemon
          undone = quest[:pokemon_seen][index_in_table]
          text = format(ext_text(9000, 54), name: text_get(0, quest_data.see_pokemon[index_in_table]))
        when :beat_pokemon
          undone = (nb = quest[:pokemon_beaten][index_in_table]) < (amount = quest_data.beat_pokemon_amount[index_in_table])
          text = format(ext_text(9000, 55), 
            amount: amount, 
            name: text_get(0, quest_data.beat_pokemon[index_in_table]),
            found: nb)
        when :catch_pokemon
          undone = (nb = quest[:pokemon_catch][index_in_table]) < (amount = quest_data.catch_pokemon_amount[index_in_table])
          text = format(ext_text(9000, 56), 
            amount: amount, 
            name: _convert_catch(quest_data.catch_pokemon[index_in_table]),
            found: nb)
        when :beat_npc
          undone = (nb = quest[:npc_beaten][index_in_table]) < (amount = quest_data.beat_npc_amount[index_in_table])
          if amount > 1
            text = format(ext_text(9000, 57), 
              amount: amount, 
              name: quest_data.beat_npc[index_in_table],
              found: nb)
          else
            text = format(ext_text(9000, 58), name: quest_data.beat_npc[index_in_table])
          end
        when :get_egg_amount
          undone = (nb = quest[:egg_counter]) < (amount = quest_data.number_of_egg_to_find)
          if amount > 1
            text = format(ext_text(9000, 59), amount: amount, found: nb)
          else
            text = ext_text(9000, 60)
          end
        when :hatch_egg_amount
          undone = (nb = quest[:egg_hatched]) < (amount = quest_data.number_of_egg_to_hatch)
          if amount > 1
            text = format(ext_text(9000, 61), amount: amount, found: nb)
          else
            text = ext_text(9000, 62)
          end
        else
          next
        end
        stack.add_text(1, y, 310, 16, text).load_color(undone ? 18 : 11)
        index += 1
      end
      @objective_index = 0
      @objective_max = index - 1
      @objective_max = 0 if index < 0
      @selector.set_position(0, 0)
      @viewport2.oy = 0
      @viewport2.sort_z
    end
    # Fonction de conversion en message de l'objectif de capture
    # @param data [Integer, Hash]
    # @return [String]
    def _convert_catch(data)
      if data.is_a?(Integer)
        return text_get(0, data)
      end
      str = "Pokémon"
      if id = data[:type]
        str << format(ext_text(9000, 63), GameData::Type[id].name) # " de type #{GameData::Type[id].name}"
      end
      if id = data[:nature]
        str << format(ext_text(9000, 64), text_get(8, id)) # " ayant la nature #{text_get(8, id)}"
      end
      if id = data[:min_level]
        str << format(ext_text(9000, 66), id) # " de niveau #{id} minimum"
        if id = data[:max_level]
          str << format(ext_text(9000, 67), id) # " et de niveau #{id} maximum"
        end
      elsif id = data[:max_level]
        str << format(ext_text(9000, 68), id) # " de niveau #{id} maximum"
      end
      if id = data[:level]
        str << format(ext_text(9000, 65), id) # " au niveau #{id}"
      end
      return str
    end
    # Adjust the viewport position
    def adjust_viewport
      return if @objective_max < 4
      if @objective_index >= 3
        @viewport2.oy = (@objective_index - 3) * 16
      elsif @objective_index < 4
        @viewport2.oy = 0
      end
    end

    def create_graphics
      # Skipped to prevent glitches
    end
  end
end
